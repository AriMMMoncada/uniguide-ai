# UniGuide AI

Asistente inteligente para orientación universitaria
**Universidad Politécnica de San Luis Potosí — Ingeniería de Software II**

Ximena Ortiz Barrientos · Diego Jareth Saldaña Ortiz · Ari Maximiliano Muñiz Moncada
Docente: Rafael Llamas Contreras

---

## Qué hace

Responde preguntas de estudiantes sobre ubicaciones, trámites, horarios,
servicios y oferta académica de la UPSLP, por página web y por Telegram.
Responde **únicamente** con información de la base de conocimiento
institucional: si no la tiene, lo dice en lugar de inventarla.

## Estructura

```
uniguide/
├── database/uniguide.sql        Esquema + datos (InnoDB, utf8mb4, FULLTEXT)
├── backend/
│   ├── src/
│   │   ├── server.js            API Express y caso de uso principal
│   │   ├── db.js                Pool MySQL
│   │   ├── intencion.js         Clasificador de intención (RF1 Módulo 2)
│   │   ├── baseConocimiento.js  Recuperación de contexto (RF1 Módulo 3)
│   │   ├── telegram.js          Bot por long polling (RF2 Módulo 1)
│   │   └── agentes/             Capa adaptadora del motor de IA
│   │       ├── AgenteIA.js      Interfaz + system prompt restrictivo
│   │       ├── AgenteMock.js    Sin API key, alucinación cero
│   │       ├── AgenteGemini.js  Google AI Studio (key gratuita)
│   │       ├── AgenteOpenAI.js  OpenAI
│   │       ├── AgenteOpenClaw.js
│   │       └── AgenteNanoClaw.js
│   ├── public/                  Frontend (index.html, style.css, Script.js)
│   └── scripts/hash.js          Generador de hash bcrypt
├── openclaw/                    Config + skill del agente, y guía de instalación
└── docs/
    ├── ARQUITECTURA.md          Decisiones de diseño (ADR) y seguridad
    ├── TRAZABILIDAD.md          Matriz requerimiento → implementación
    └── DESPLIEGUE.md            Cómo subirlo para que el profesor entre
```

## Arranque rápido

```bash
cd backend
cp .env.example .env
npm install
mysql -u root -p uniguide < ../database/uniguide.sql
npm start          # http://localhost:3000
```

Funciona sin API key (`AGENTE=mock`). Ver `docs/DESPLIEGUE.md` para el resto.

## Preguntas de prueba

- ¿Dónde está el laboratorio de redes? → respuesta + mapa
- ¿Qué necesito para una constancia? → requisitos y costo
- ¿A qué hora abre la biblioteca? → horario
- ¿Qué carreras ofrece la UPSLP? → oferta académica
- ¿Cuándo es el examen de cálculo? → mensaje predeterminado (no está en la BD)
- `<img src=x onerror=alert(1)>` → se muestra como texto, no ejecuta nada
