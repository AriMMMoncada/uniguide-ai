/**
 * Bot de Telegram por long polling (RF2 - Modulo 1).
 *
 * Se usa polling y no webhooks a proposito: el polling NO requiere una URL
 * publica con HTTPS, asi que el bot funciona desde la laptop de cualquier
 * integrante o desde el hosting, sin configuracion extra.
 *
 * Este bot reutiliza el MISMO caso de uso que la web (responderPregunta),
 * asi que ambos canales comparten grounding, intencion e historial.
 *
 * Alternativa documentada: dejar que OpenClaw sea el canal de Telegram y
 * que consuma /api/kb/buscar. Ver /openclaw/README.md.
 */
require('dotenv').config();
const { responderPregunta } = require('./server');

const TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const API = `https://api.telegram.org/bot${TOKEN}`;
let offset = 0;

if (!TOKEN) {
  console.error('Falta TELEGRAM_BOT_TOKEN en .env. Consíguelo con @BotFather.');
  process.exit(1);
}

async function enviar(chatId, texto, urlMapa) {
  const cuerpo = {
    chat_id: chatId,
    text: texto,
    parse_mode: 'HTML',
    disable_web_page_preview: false,
  };
  if (urlMapa) {
    cuerpo.reply_markup = {
      inline_keyboard: [[{ text: '📍 Ver ubicación en el mapa', url: urlMapa }]],
    };
  }
  await fetch(`${API}/sendMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(cuerpo),
  });
}

async function escribiendo(chatId) {
  await fetch(`${API}/sendChatAction`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ chat_id: chatId, action: 'typing' }),
  });
}

async function manejar(mensaje) {
  const chatId = mensaje.chat.id;
  const texto = (mensaje.text || '').trim();
  if (!texto) return;

  if (texto === '/start') {
    return enviar(chatId,
      '¡Hola! Soy <b>UniGuide AI</b> 🤖\n\n' +
      'Pregúntame sobre ubicaciones, trámites, horarios y servicios de la UPSLP.\n\n' +
      'Ejemplo: <i>¿Dónde está el laboratorio de redes?</i>');
  }
  if (texto === '/ayuda') {
    return enviar(chatId, 'Escribe tu pregunta en lenguaje natural. Solo respondo con información registrada en la base de conocimiento institucional.');
  }

  await escribiendo(chatId);
  try {
    const r = await responderPregunta({
      pregunta: texto,
      origen: 'TELEGRAM',
      telegramChatId: chatId,
    });
    await enviar(chatId, r.respuesta, r.mapa?.url);
  } catch (err) {
    console.error('[TG]', err);
    await enviar(chatId, 'Ocurrió un problema al procesar tu pregunta. Intenta de nuevo.');
  }
}

async function sondear() {
  try {
    const res = await fetch(`${API}/getUpdates?timeout=30&offset=${offset}`);
    const data = await res.json();
    for (const upd of data.result || []) {
      offset = upd.update_id + 1;
      if (upd.message) await manejar(upd.message);
    }
  } catch (err) {
    console.error('[TG] polling:', err.message);
    await new Promise((r) => setTimeout(r, 3000));
  }
  sondear();
}

console.log('Bot de Telegram iniciado (long polling).');
sondear();
