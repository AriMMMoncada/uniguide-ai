# Guía de despliegue — que el profesor pueda entrar desde su casa

Tiempo estimado: **40–60 minutos**. Háganlo en este orden.

---

## Paso 0 — Probar en local primero (10 min)

```bash
cd backend
cp .env.example .env          # editar DB_PASSWORD si su MySQL tiene contraseña
npm install
```

Importar la base de datos (con XAMPP/MySQL corriendo):

```bash
mysql -u root -p -e "CREATE DATABASE uniguide CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p uniguide < ../database/uniguide.sql
```

O desde phpMyAdmin: crear la base `uniguide` con cotejamiento
`utf8mb4_unicode_ci` e importar el archivo.

```bash
npm start
```

Abrir `http://localhost:3000` y preguntar *"¿Dónde está el laboratorio de
redes?"*. Debe responder y mostrar el mapa. Si sale el mensaje de "no cuento
con información suficiente" para todo, revisen que el `.env` apunte a la base
correcta y que `/api/salud` devuelva `bd: "conectada"`.

---

## Paso 1 — Base de datos MySQL en la nube (15 min)

El backend en la nube no puede hablar con el MySQL de su laptop. Necesitan una
base gestionada. Opciones con capa gratuita:

| Servicio | Notas |
|----------|-------|
| **Aiven for MySQL** | Plan gratuito, exige TLS → pongan `DB_SSL=true` |
| **Railway** | Crédito de prueba, muy rápido de configurar |
| **Clever Cloud** | Plan gratuito pequeño, suficiente para esta base |
| **TiDB Cloud Serverless** | Compatible con MySQL, capa gratuita generosa |

Pasos comunes:

1. Crear la instancia y anotar host, puerto, usuario, contraseña y nombre de
   la base.
2. Importar `database/uniguide.sql` con MySQL Workbench, phpMyAdmin o:
   ```bash
   mysql -h HOST -P PUERTO -u USUARIO -p NOMBRE_BD < database/uniguide.sql
   ```
3. Verificar que las tablas tengan los datos:
   ```sql
   SELECT COUNT(*) FROM base_conocimiento;   -- debe dar 15
   ```

> **Aviso sobre FULLTEXT.** Si el proveedor no soporta índices FULLTEXT, el
> código cae automáticamente a la búsqueda `LIKE` y todo sigue funcionando,
> solo un poco más lento. No hay que cambiar nada.

---

## Paso 2 — Backend en Render (15 min)

1. Subir el proyecto a GitHub (**verifiquen que `.env` NO esté incluido**).
2. En [render.com](https://render.com) → *New* → *Web Service* → conectar el repo.
3. Configuración:
   - **Root Directory:** `backend`
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Instance Type:** Free
4. En *Environment* agregar las variables (copiadas de `.env.example`):

```
NODE_ENV=production
DB_HOST=...
DB_PORT=...
DB_USER=...
DB_PASSWORD=...
DB_NAME=uniguide
DB_SSL=true
AGENTE=mock
IA_MAX_TOKENS=300
AGENT_API_KEY=<una cadena larga y aleatoria>
```

5. Desplegar. Render les da una URL tipo
   `https://uniguide-ai.onrender.com` **con HTTPS incluido** → RNF3 del
   Módulo 1 cumplido sin trabajo extra.
6. Verificar: `https://su-url.onrender.com/api/salud`

### Arranque en frío

El plan gratuito de Render suspende el servicio tras 15 minutos de
inactividad, y la primera petición después puede tardar ~50 segundos. Eso
choca visualmente con el RNF2 (5 segundos).

Dos mitigaciones:

- **Antes de la revisión:** abran la URL 2 minutos antes para "despertarla".
- **Permanente:** configuren un monitor gratuito en
  [uptimerobot.com](https://uptimerobot.com) que haga ping a
  `/api/salud` cada 10 minutos.

Documenten esto en el reporte. Es una limitación del proveedor, no del
sistema, y mencionarla proactivamente habla bien del análisis del equipo.

---

## Paso 3 — API key de IA (opcional pero recomendado, 5 min)

Con `AGENTE=mock` todo funciona. Para respuestas generadas:

1. Entrar a [aistudio.google.com](https://aistudio.google.com) con cuenta
   Google → *Get API key*. Es **gratuito y sin tarjeta**.
2. En Render, agregar:
   ```
   AGENTE=gemini
   GEMINI_API_KEY=<la key>
   GEMINI_MODEL=gemini-2.0-flash
   ```
3. Redesplegar. `/api/salud` debe mostrar el motor `gemini`.

Si la API falla en plena demo, el backend cae solo al agente `mock` y sigue
respondiendo. No se rompe delante del profesor.

---

## Paso 4 — Bot de Telegram (10 min)

1. En Telegram, hablar con **@BotFather** → `/newbot` → seguir instrucciones.
2. Copiar el token.
3. Opción A (simple, corre en una laptop):
   ```bash
   # en backend/.env
   TELEGRAM_BOT_TOKEN=<token>
   npm run telegram
   ```
   Usa long polling, así que **no necesita URL pública**.
4. Opción B (con OpenClaw): ver `openclaw/README.md`.

> La laptop debe estar encendida para que el bot responda. Si quieren que
> funcione siempre, creen un segundo *Background Worker* en Render con
> Start Command `npm run telegram` y las mismas variables de entorno.

---

## Paso 5 — Antes de entregar (checklist)

- [ ] `https://su-url.onrender.com` abre y responde preguntas
- [ ] `/api/salud` devuelve `bd: "conectada"`
- [ ] La pregunta del laboratorio de redes muestra el mapa
- [ ] Una pregunta fuera de la base devuelve el mensaje predeterminado
- [ ] El `.env` **no** está en GitHub (`git log --all -- backend/.env` vacío)
- [ ] El hash de `usuario_admin` fue regenerado con `npm run hash`
- [ ] Probaron la página desde un celular (RNF1)
- [ ] `<img src=x onerror=alert(1)>` en el chat se muestra como texto, no ejecuta nada
- [ ] Las tildes y eñes se ven bien (si no: la base no quedó en utf8mb4)
- [ ] El bot de Telegram responde a `/start`
- [ ] Entregaron `docs/TRAZABILIDAD.md` con el reporte

---

## Problemas comunes

**Los acentos salen como `Ã³`.** La base no quedó en utf8mb4. Recrearla con el
cotejamiento correcto y reimportar.

**`ER_ACCESS_DENIED_ERROR` en Render.** El proveedor de MySQL exige TLS:
agregar `DB_SSL=true`.

**El chat siempre dice "no cuento con información suficiente".**
`SELECT COUNT(*) FROM base_conocimiento;` debe dar 15. Si da 0, el import
falló.

**`Cannot find module 'express'`.** Falta `npm install`, o el *Root Directory*
en Render no quedó en `backend`.

**El mapa no carga.** Revisen la consola del navegador: si el error es de CSP,
verifiquen que `frameSrc` en `server.js` incluya `https://www.google.com`.
