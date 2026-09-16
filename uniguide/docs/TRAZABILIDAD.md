# Matriz de trazabilidad de requerimientos

Universidad Politécnica de San Luis Potosí — Ingeniería de Software II
Proyecto: **UniGuide AI** · Entregable: Prueba de Concepto

Leyenda: ✅ implementado y verificable · 🟡 implementado parcialmente · ⬜ trabajo futuro documentado

---

## Módulo 1 — Interfaz de Usuario (Web y Telegram)

| ID | Requerimiento | Estado | Dónde se verifica |
|----|---------------|--------|-------------------|
| RF1 | Preguntas en lenguaje natural vía chat web | ✅ | `backend/public/index.html`, `Script.js` → `POST /api/preguntar` |
| RF2 | Consultas y respuestas vía Telegram | ✅ | `backend/src/telegram.js` (long polling) y, como alternativa, `openclaw/` |
| RF3 | Historial temporal del chat de la sesión | ✅ | `sessionStorage` en el cliente + tablas `sesion_chat` / `historial_chat` |
| RNF1 | Interfaz responsiva (móvil y escritorio) | ✅ | `style.css`, breakpoints en 1100 / 800 / 600 px |
| RNF2 | Respuesta en menos de 5 segundos | ✅ | Campo `ms` en la respuesta JSON; `console.log` del cliente. Timeout duro de 8 s en los agentes |
| RNF3 | Comunicación cifrada con HTTPS | ✅ | Redirección 301 forzada en producción (`server.js`) + TLS del proveedor de hosting |

**Nota sobre RNF2:** en el plan gratuito de Render el servicio se suspende por
inactividad y el primer request tras la suspensión puede tardar ~50 s. No es
tiempo de procesamiento del sistema, es arranque en frío de la plataforma.
Mitigación documentada en `DESPLIEGUE.md` (ping periódico de mantenimiento).

---

## Módulo 2 — Motor de Inteligencia Artificial

| ID | Requerimiento | Estado | Dónde se verifica |
|----|---------------|--------|-------------------|
| RF1 | Interpretar la intención (trámite / ubicación / servicio / horario) | ✅ | `src/intencion.js`; la intención viaja en la respuesta JSON |
| RF2 | Generar respuestas usando únicamente el contexto de la BD | ✅ | `SYSTEM_PROMPT` en `src/agentes/AgenteIA.js` + inyección de contexto en `server.js` |
| RF3 | Mensaje predeterminado cuando no hay información | ✅ | Corto-circuito en `responderPregunta()`: sin fragmentos, no hay llamada a la IA |
| RNF1 | Tasa de alucinaciones prácticamente nula (grounding) | ✅ | Doble candado: (a) corto-circuito sin contexto, (b) `temperature: 0.1` + prompt restrictivo |
| RNF2 | Tolerar faltas de ortografía menores | ✅ | Normalización de acentos + distancia de Levenshtein ≤ 1 en `intencion.js`; FULLTEXT en modo lenguaje natural |
| RNF3 | Límite máximo de tokens por respuesta | ✅ | `IA_MAX_TOKENS` aplicado en los tres agentes generativos; consumo registrado en `historial_chat.tokens_consumidos` |

**Evidencia del RNF1.** El diseño hace la alucinación estructuralmente
imposible en el peor caso: si la búsqueda en la base de conocimiento no
devuelve nada, el modelo **nunca se invoca**. No es una instrucción que el
modelo pueda desobedecer; es una rama del código.

---

## Módulo 3 — Base de Conocimiento y Mapas

| ID | Requerimiento | Estado | Dónde se verifica |
|----|---------------|--------|-------------------|
| RF1 | Buscar y recuperar información de la BD | ✅ | `src/baseConocimiento.js` (FULLTEXT + respaldo LIKE) |
| RF2 | Recuperar coordenadas y generar enlace/mapa incrustado | ✅ | `extraerLugar()` + renderizado de `iframe` en `Script.js`; botón inline en Telegram |
| RF3 | Mecanismo para que administradores actualicen la BD sin tocar el código de la IA | 🟡 | Tabla `usuario_admin` con bcrypt, script `scripts/hash.js` y separación total entre datos y lógica. **El panel web de administración queda como trabajo futuro** |
| RNF1 | Disponibilidad del 99.9% en horario de clases | 🟡 | Endpoint `/api/salud` para monitoreo + pool de conexiones + degradación elegante al agente de respaldo. La cifra no es medible en un plan gratuito |
| RNF2 | Consultas internas en menos de 1 segundo | ✅ | Índices `FULLTEXT` sobre `base_conocimiento`, `tramite`, `servicio`, `lugar` y `pregunta_frecuente` |
| RNF3 | Modelo de datos migrable y escalable | ✅ | InnoDB + utf8mb4 + llaves foráneas; sin datos de la UPSLP incrustados en el código |

---

## Resumen

| Módulo | Requerimientos | ✅ | 🟡 | ⬜ |
|--------|----------------|-----|-----|-----|
| Módulo 1 | 6 | 6 | 0 | 0 |
| Módulo 2 | 6 | 6 | 0 | 0 |
| Módulo 3 | 6 | 4 | 2 | 0 |
| **Total** | **18** | **16** | **2** | **0** |

## Deuda técnica declarada

1. **Panel de administración (RF3 Módulo 3).** Existe el modelo de datos y la
   autenticación, falta la interfaz CRUD. Estimado: 6–8 horas.
2. **Medición formal de disponibilidad (RNF1 Módulo 3).** Requiere hosting de
   pago y una herramienta de monitoreo externo.
3. **Búsqueda semántica con embeddings.** La búsqueda actual es léxica
   (FULLTEXT). Con embeddings mejoraría el recall en preguntas parafraseadas.
4. **Pruebas automatizadas.** No hay suite de pruebas unitarias.
