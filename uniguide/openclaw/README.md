# Integración con OpenClaw y NanoClaw

Este directorio contiene la configuración y la *skill* que conectan un agente
OpenClaw (o NanoClaw) con la base de conocimiento de UniGuide AI.

---

## 1. Qué son y por qué se usan aquí

**OpenClaw** es un agente de IA de código abierto, autohospedado, que recibe
comandos desde aplicaciones de mensajería (Telegram, WhatsApp, Discord,
Signal, Slack, entre otras). Requiere **Node.js ≥ 22** y una API key de un
proveedor soportado (Anthropic, OpenAI o Google). En UniGuide AI aporta el
**canal de Telegram y el bucle agéntico** (RF2 del Módulo 1).

**NanoClaw** nació como respuesta a las preocupaciones de seguridad que generó
OpenClaw. Su diferencia central es el **aislamiento por contenedores**: cada
agente corre en su propio contenedor (Docker o Apple Container), los
contenedores son efímeros —se crean en cada invocación y se destruyen
después—, el agente corre como usuario sin privilegios y solo ve los
directorios montados explícitamente. Su base de código es de menos de 4,000
líneas, auditable en pocas horas.

### Decisión de arquitectura del equipo

| | OpenClaw | NanoClaw |
|---|---|---|
| Instalación | `npm i -g openclaw` | fork del repositorio + Docker |
| Canales listos | Telegram, WhatsApp, Discord, Slack, Signal… | menos integraciones de fábrica |
| Aislamiento | sandbox compartido | un contenedor efímero por agente |
| Tiempo para tener algo corriendo | 15–30 min | más, requiere Docker |

**Decisión:** OpenClaw para la Prueba de Concepto (por velocidad y por el
canal de Telegram ya resuelto); NanoClaw se documenta como la opción
recomendada para un despliegue institucional real, donde el agente podría
tener permisos de escritura sobre la base de conocimiento y el aislamiento
deja de ser opcional.

---

## 2. Principio de diseño: el agente no sustituye al grounding

El agente **no** consulta MySQL directamente ni conoce las credenciales de la
base de datos. Solo puede llamar al endpoint `POST /api/kb/buscar` del backend
de UniGuide, que devuelve fragmentos ya filtrados. Si ese endpoint responde
`encontrado: false`, la skill obliga al agente a devolver el mensaje
predeterminado sin generar texto propio.

Esto es lo que permite sostener el **RNF1 del Módulo 2** (tasa de alucinación
prácticamente nula) incluso cuando el motor es un agente autónomo: el agente
nunca decide qué datos recibe.

```
Estudiante → Telegram → OpenClaw Gateway → skill "uniguide"
                                              ↓ HTTP + X-API-Key
                                     UniGuide Backend /api/kb/buscar
                                              ↓
                                          MySQL (base_conocimiento)
```

---

## 3. Instalación paso a paso

### 3.1 Requisitos

```bash
node --version    # debe ser 22.x o superior (24 es el recomendado)
```

Si tienen Node 18 o 20, instalen Node 24 con `nvm`:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
source ~/.bashrc
nvm install 24 && nvm use 24 && nvm alias default 24
```

En Windows, la ruta recomendada es WSL2 con Ubuntu.

### 3.2 Instalar OpenClaw

```bash
npm install -g openclaw
openclaw --version
```

### 3.3 Onboarding

```bash
openclaw onboard --install-daemon
```

El asistente pide: la API key del modelo (usen la de Google AI Studio,
que es gratuita), el workspace, y opcionalmente los canales.

### 3.4 Conectar Telegram

1. Abrir Telegram y hablar con **@BotFather**.
2. `/newbot` → nombre `UniGuide AI` → usuario `uniguide_upslp_bot`.
3. Copiar el token que devuelve.
4. Pegarlo en la configuración de OpenClaw (canal `telegram`).

### 3.5 Instalar la skill de UniGuide

```bash
mkdir -p ~/.openclaw/skills
cp -r skills/uniguide ~/.openclaw/skills/
cp openclaw.json ~/.openclaw/openclaw.json   # revisar antes de sobrescribir
```

Editen `~/.openclaw/openclaw.json` y pongan la URL pública del backend
desplegado y la misma `AGENT_API_KEY` que está en el `.env` del backend.

### 3.6 Probar

Desde Telegram, escríbanle al bot: *¿Dónde está el laboratorio de redes?*

---

## 4. Variante NanoClaw

```bash
git clone https://github.com/qwibitai/nanoclaw.git uniguide-nanoclaw
cd uniguide-nanoclaw
# NanoClaw sigue una política "fork-and-own": no se instala como paquete,
# se hace fork del repo y se personaliza. Las funciones nuevas se agregan
# como skills dentro de la propia base de código.
```

La misma skill de `skills/uniguide/` sirve de referencia: cambia el formato
del manifiesto, no la lógica, porque toda la lógica de negocio vive en
`/api/kb/buscar`.

---

## 5. Seguridad — leer antes de exponer nada

- **Nunca** expongan el gateway de OpenClaw a internet. Déjenlo en
  `localhost` o detrás de VPN. Un gateway público con la herramienta `exec`
  habilitada es ejecución remota de comandos.
- Deshabiliten las herramientas que UniGuide no necesita (`exec`, `browser`,
  acceso a archivos). La skill solo requiere llamadas HTTP.
- La `AGENT_API_KEY` no va en el repositorio. Va en `.env` y en la config
  local del gateway.
- Hay un antecedente conocido: una investigadora de seguridad de Meta reportó
  que un agente basado en OpenClaw comenzó a borrar correos de su bandeja y no
  se detuvo pese a recibir órdenes de parar. Por eso el principio de mínimo
  privilegio no es opcional aquí.

---

## 6. Verificación

Los formatos de manifiesto de OpenClaw y NanoClaw evolucionan rápido.
Antes de entregar, contrasten `openclaw.json` y `SKILL.md` contra la
documentación oficial vigente en **docs.openclaw.ai** y **nanoclaw.dev**.
