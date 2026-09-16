# Documento de arquitectura — UniGuide AI

Universidad Politécnica de San Luis Potosí · Ingeniería de Software II

---

## 1. Vista general

```
┌──────────────┐   ┌──────────────┐   ┌──────────────────┐
│  Navegador   │   │   Telegram   │   │ OpenClaw Gateway │
│    (web)     │   │   (bot)      │   │  (Node ≥ 22)     │
└──────┬───────┘   └──────┬───────┘   └────────┬─────────┘
       │ POST             │ long polling       │ skill "uniguide"
       │ /api/preguntar   │                    │ POST /api/kb/buscar
       └──────────┬───────┴────────────────────┘
                  ▼
        ┌─────────────────────────────────────┐
        │   Backend UniGuide (Node + Express) │
        │                                     │
        │  1. detectarIntencion()   RF1 M2    │
        │  2. recuperarContexto()   RF1 M3    │
        │  3. ¿vacío? → mensaje     RS 2.4    │
        │  4. AgenteIA.responder()  RF2 M2    │
        │  5. extraerLugar()        RF2 M3    │
        └───────────────┬─────────────────────┘
                        ▼
              ┌───────────────────┐
              │  MySQL  `uniguide`│
              │  InnoDB + utf8mb4 │
              │  índices FULLTEXT │
              └───────────────────┘
```

## 2. Decisiones de arquitectura (ADR resumidos)

### ADR-1 · Node.js + Express para el backend

**Contexto.** El documento de requerimientos admite Python 3.10+ o Node 18+.
**Decisión.** Node.js.
**Razones.** (a) OpenClaw exige Node ≥ 22, así que el runtime ya es
obligatorio en el proyecto; usar otro lenguaje significaría mantener dos.
(b) `fetch` nativo elimina dependencias HTTP. (c) Despliegue gratuito directo
en Render/Railway.
**Consecuencia.** Se requiere Node 18+ para el backend y Node 22+ en la
máquina que hospede el agente.

### ADR-2 · Recuperación léxica (FULLTEXT) en vez de embeddings

**Contexto.** El RNF2 del Módulo 3 exige consultas en menos de 1 segundo y el
proyecto no tiene presupuesto.
**Decisión.** Índices FULLTEXT de MySQL en modo lenguaje natural, con respaldo
`LIKE` cuando FULLTEXT no devuelve nada.
**Razones.** Cero costo, cero infraestructura adicional, latencia de
milisegundos, y el corpus es pequeño (decenas de registros).
**Consecuencia.** El recall baja con preguntas muy parafraseadas. Registrado
como deuda técnica.

### ADR-3 · Capa adaptadora de agente (patrón Strategy)

**Contexto.** Los requerimientos mencionan OpenAI, NanoClaw y OpenClaw como
opciones intercambiables.
**Decisión.** Una interfaz `AgenteIA` con cinco implementaciones
(`mock`, `gemini`, `openai`, `openclaw`, `nanoclaw`), seleccionadas por la
variable de entorno `AGENTE`.
**Razones.** Inversión de dependencias: el controlador no conoce ningún
proveedor concreto. Cambiar de motor no toca código.
**Consecuencia.** Una capa de indirección extra, justificada porque el
requerimiento explícito es la intercambiabilidad.

### ADR-4 · Corto-circuito antes de llamar al modelo

**Contexto.** El RNF1 del Módulo 2 exige alucinación prácticamente nula.
**Decisión.** Si la búsqueda en la base de conocimiento no devuelve
fragmentos, el modelo **no se invoca**; se devuelve el mensaje predeterminado.
**Razones.** Un *system prompt* es una instrucción que el modelo puede
desobedecer. Una rama del código no lo es. Además ahorra tokens.
**Consecuencia.** El sistema es conservador: prefiere decir "no sé" a
arriesgar una respuesta inventada. Para un asistente institucional eso es
exactamente lo deseable.

### ADR-5 · Agente `mock` como implementación por defecto

**Contexto.** El equipo no dispone de API key al momento de la entrega.
**Decisión.** `AGENTE=mock` por defecto: redacta con plantillas
determinísticas sobre el contexto recuperado de la BD.
**Razones.** El flujo completo (captura → intención → recuperación →
respuesta → mapa → historial) queda demostrable sin credenciales ni costo.
Por construcción tiene alucinación cero, lo que lo hace además una línea base
útil para comparar contra los motores generativos.
**Consecuencia.** Las respuestas son menos fluidas que las de un LLM. Se
cambia a `AGENTE=gemini` con una sola línea del `.env`.

### ADR-6 · OpenClaw para la PoC, NanoClaw para producción

Ver `openclaw/README.md` para la comparación detallada y las razones de
seguridad.

## 3. Modelo de datos

Diez tablas. Los datos institucionales (`lugar`, `tramite`, `servicio`,
`horario`, `base_conocimiento`, `pregunta_frecuente`, `categoria`) están
completamente separados de la lógica: no hay ningún dato de la UPSLP
incrustado en el código. Eso es lo que hace realizable el RNF3 del Módulo 3
(migrar a otra universidad = cambiar los INSERT).

Las tablas operativas (`sesion_chat`, `historial_chat`) dan soporte al RF3 del
Módulo 1 y permiten auditar consumo de tokens y tiempos de respuesta.

`usuario_admin` soporta el RF3 del Módulo 3.

## 4. Seguridad

| Amenaza | Mitigación | Dónde |
|---------|------------|-------|
| XSS en el chat | `textContent` en vez de `innerHTML` para todo texto de usuario o modelo | `Script.js` |
| Inyección SQL | Consultas parametrizadas (`mysql2` prepared statements) en el 100% de las consultas | `baseConocimiento.js`, `server.js` |
| Tráfico en claro | Redirección forzada a HTTPS en producción | `server.js` |
| Abuso del endpoint | `express-rate-limit`: 30 peticiones por minuto por IP | `server.js` |
| Costo descontrolado de la API | `IA_MAX_TOKENS` + corto-circuito sin contexto | agentes |
| Credenciales filtradas | `.env` fuera del repositorio; `.env.example` sin secretos | `.gitignore` |
| Agente sobre-permisionado | `exec`, `browser` y `file` deshabilitados; gateway en `127.0.0.1` | `openclaw.json` |
| Contraseñas en claro | bcrypt con factor de costo 12 | `scripts/hash.js` |

## 5. Flujo detallado de una consulta (RS 2.1 – 2.4)

1. El cliente envía `{ pregunta, sesion }` por `POST /api/preguntar`.
2. El backend trunca a 500 caracteres (RS 1.2) y resuelve la sesión.
3. `detectarIntencion()` clasifica en una de seis categorías (RS 2.1).
4. `recuperarContexto()` busca en la base de conocimiento (RF1 M3).
5. **Si no hay fragmentos:** se responde el mensaje predeterminado sin llamar
   a la IA (RS 2.4) y se registra en el historial.
6. **Si hay fragmentos:** se formatean e inyectan como contexto en el prompt
   (RS 2.2) junto al `SYSTEM_PROMPT` restrictivo (RS 2.3).
7. Si la intención es `UBICACION`, se adjuntan coordenadas y URL de mapa
   (RS 3.1 – 3.4).
8. El cliente renderiza la burbuja, el `iframe` del mapa y las fuentes
   consultadas (RS 3.5, RS 1.5).
9. Pregunta y respuesta quedan en `historial_chat` con intención, tokens y
   milisegundos.
