/**
 * UniGuide AI - servidor principal (Express).
 * Ingenieria de Software II - UPSLP
 */
require('dotenv').config();

const path = require('path');
const express = require('express');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const { pool, probarConexion } = require('./db');
const { detectarIntencion } = require('./intencion');
const {
  recuperarContexto, formatearContexto, extraerLugar, listarFaq,
} = require('./baseConocimiento');
const { crearAgenteConRespaldo, SIN_INFORMACION } = require('./agentes');

const app = express();
const PUERTO = Number(process.env.PORT || 3000);
const LIMITE_CARACTERES = 500; // RS 1.2
const agente = crearAgenteConRespaldo();

// --------------------------------------------------------------------
// Middlewares
// --------------------------------------------------------------------
app.set('trust proxy', 1);
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", 'https://fonts.googleapis.com'],
      fontSrc: ["'self'", 'https://fonts.gstatic.com'],
      imgSrc: ["'self'", 'data:', 'https:'],
      frameSrc: ["'self'", 'https://www.google.com', 'https://maps.google.com'],
      connectSrc: ["'self'"],
    },
  },
}));

// RNF3 Modulo 1: fuerza HTTPS en produccion (Render/Railway terminan TLS
// en el proxy y mandan x-forwarded-proto).
app.use((req, res, next) => {
  if (process.env.NODE_ENV === 'production' && req.headers['x-forwarded-proto'] === 'http') {
    return res.redirect(301, `https://${req.headers.host}${req.originalUrl}`);
  }
  next();
});

app.use(express.json({ limit: '16kb' }));
app.use(express.static(path.join(__dirname, '..', 'public')));

const limitador = rateLimit({
  windowMs: 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Demasiadas preguntas seguidas. Espera un momento.' },
});

// --------------------------------------------------------------------
// Helpers de sesion (RF3 Modulo 1: historial de la sesion actual)
// --------------------------------------------------------------------
async function obtenerOCrearSesion({ origen, tokenSesion, telegramChatId }) {
  if (tokenSesion) {
    const [filas] = await pool.query(
      'SELECT id_sesion FROM sesion_chat WHERE token_sesion = ? LIMIT 1', [tokenSesion]
    );
    if (filas.length) return filas[0].id_sesion;
  }
  if (telegramChatId) {
    const [filas] = await pool.query(
      'SELECT id_sesion FROM sesion_chat WHERE telegram_chat_id = ? ORDER BY id_sesion DESC LIMIT 1',
      [telegramChatId]
    );
    if (filas.length) return filas[0].id_sesion;
  }
  const [res] = await pool.query(
    'INSERT INTO sesion_chat (origen, telegram_chat_id, token_sesion) VALUES (?, ?, ?)',
    [origen, telegramChatId || null, tokenSesion || null]
  );
  return res.insertId;
}

async function registrarMensaje(idSesion, emisor, mensaje, intencion, tokens, ms) {
  try {
    await pool.query(
      `INSERT INTO historial_chat
         (id_sesion, emisor, mensaje, intencion_detectada, tokens_consumidos, ms_respuesta)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [idSesion, emisor, mensaje, intencion || null, tokens || 0, ms || null]
    );
  } catch (err) {
    // El historial es auxiliar: si falla, la respuesta al estudiante no debe romperse.
    console.warn('[HIST] No se pudo registrar el mensaje:', err.message);
  }
}

// --------------------------------------------------------------------
// Caso de uso central: responder una pregunta
// Implementa el flujo completo del Modulo 2 (RS 2.1 a 2.4).
// --------------------------------------------------------------------
async function responderPregunta({ pregunta, origen, tokenSesion, telegramChatId }) {
  const inicio = Date.now();

  // RS 1.2 - limite de longitud
  const texto = String(pregunta || '').trim().slice(0, LIMITE_CARACTERES);
  if (!texto) {
    return { respuesta: 'Escribe una pregunta para poder ayudarte.', intencion: 'GENERAL', mapa: null, ms: 0 };
  }

  const idSesion = await obtenerOCrearSesion({ origen, tokenSesion, telegramChatId });
  const { intencion, confianza } = detectarIntencion(texto);          // RS 2.1 / RF1 Mod.2
  const fragmentos = await recuperarContexto(texto);                   // RF1 Mod.3

  await registrarMensaje(idSesion, 'USUARIO', texto, intencion, 0, null);

  // RS 2.4 - corto-circuito: sin contexto NO se llama a la IA.
  if (!fragmentos.length) {
    const ms = Date.now() - inicio;
    await registrarMensaje(idSesion, 'SISTEMA', SIN_INFORMACION, intencion, 0, ms);
    return { respuesta: SIN_INFORMACION, intencion, confianza, mapa: null, fuentes: [], ms, motor: 'ninguno (sin contexto)' };
  }

  const contexto = formatearContexto(fragmentos);                      // RS 2.2
  const { texto: respuesta, tokens, motor: motorUsado } = await agente.responder({ pregunta: texto, contexto, intencion });

  // RF2 / RS 3.1-3.4 Modulo 3: adjuntar mapa si la intencion es de ubicacion.
  const mapa = intencion === 'UBICACION' ? extraerLugar(fragmentos) : null;

  const ms = Date.now() - inicio;
  await registrarMensaje(idSesion, 'IA', respuesta, intencion, tokens, ms);

  return {
    respuesta,
    intencion,
    confianza,
    mapa,
    fuentes: fragmentos.map((f) => ({ id: f.id_conocimiento, titulo: f.titulo })),
    tokens,
    ms,
    motor: motorUsado,
  };
}

// --------------------------------------------------------------------
// Rutas publicas
// --------------------------------------------------------------------
app.post('/api/preguntar', limitador, async (req, res) => {
  try {
    const { pregunta, sesion } = req.body || {};
    const resultado = await responderPregunta({
      pregunta,
      origen: 'WEB',
      tokenSesion: sesion,
    });
    res.json(resultado);
  } catch (err) {
    console.error('[API] /api/preguntar:', err);
    res.status(500).json({
      respuesta: 'Ocurrió un problema al procesar tu pregunta. Intenta de nuevo en un momento.',
      error: process.env.NODE_ENV === 'production' ? undefined : err.message,
    });
  }
});

app.get('/api/faq', async (_req, res) => {
  try {
    res.json({ preguntas: await listarFaq() });
  } catch (err) {
    res.status(500).json({ error: 'No se pudo consultar las preguntas frecuentes.' });
  }
});

// --------------------------------------------------------------------
// Endpoint para agentes externos (OpenClaw / NanoClaw)
// Esta es la puerta por la que la skill de OpenClaw consulta la base de
// conocimiento. Devuelve SOLO datos, sin generar texto: el agente externo
// es quien redacta, pero con material que sale de la BD institucional.
// --------------------------------------------------------------------
app.post('/api/kb/buscar', async (req, res) => {
  const clave = req.headers['x-api-key'];
  if (!process.env.AGENT_API_KEY || clave !== process.env.AGENT_API_KEY) {
    return res.status(401).json({ error: 'Clave de agente inválida.' });
  }
  try {
    const consulta = String(req.body?.consulta || '').slice(0, LIMITE_CARACTERES);
    const fragmentos = await recuperarContexto(consulta);
    const { intencion } = detectarIntencion(consulta);
    res.json({
      intencion,
      encontrado: fragmentos.length > 0,
      mensaje_si_vacio: SIN_INFORMACION,
      contexto: formatearContexto(fragmentos),
      lugar: extraerLugar(fragmentos),
      fragmentos: fragmentos.map((f) => ({
        titulo: f.titulo, contenido: f.contenido, categoria: f.categoria,
      })),
    });
  } catch (err) {
    console.error('[API] /api/kb/buscar:', err);
    res.status(500).json({ error: 'Error al consultar la base de conocimiento.' });
  }
});

// Salud del servicio (para el monitoreo del RNF1 Modulo 3)
app.get('/api/salud', async (_req, res) => {
  try {
    await probarConexion();
    res.json({ estado: 'ok', bd: 'conectada', motor: agente.nombre, ts: new Date().toISOString() });
  } catch (err) {
    res.status(503).json({ estado: 'degradado', bd: 'sin conexión', error: err.message });
  }
});

// --------------------------------------------------------------------
// Solo se levanta el servidor HTTP cuando este archivo se ejecuta
// directamente. Asi telegram.js puede importar responderPregunta() sin
// abrir un segundo puerto.
if (require.main === module) {
  app.listen(PUERTO, async () => {
    console.log(`\n  UniGuide AI escuchando en http://localhost:${PUERTO}`);
    console.log(`  Motor de IA: ${agente.nombre}`);
    try {
      await probarConexion();
      console.log('  Base de datos: conectada\n');
    } catch (err) {
      console.error(`  Base de datos: ERROR -> ${err.message}\n`);
    }
  });
}

module.exports = { app, responderPregunta };
