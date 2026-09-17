/* =====================================================================
   UniGuide AI - Cliente web
   Ingeniería de Software II - UPSLP
   ===================================================================== */

'use strict';

const LIMITE_CARACTERES = 500;

const input = document.getElementById('questionInput');
const button = document.getElementById('sendButton');
const chatMessages = document.getElementById('chatMessages');
const contador = document.getElementById('charCounter');
const clockEl = document.getElementById('statusClock');
const statusDot = document.getElementById('statusDot');
const statusText = document.getElementById('statusText');
const consoleSub = document.getElementById('consoleSub');

/* ------------------------------------------------------------------ */
/* Reloj del encabezado — refuerza la idea de "consola en vivo" y de   */
/* paso confirma visualmente que el JS cargó y la página responde.     */
/* ------------------------------------------------------------------ */
function actualizarReloj() {
  if (!clockEl) return;
  clockEl.textContent = new Date().toLocaleTimeString('es-MX', { hour12: false });
}
actualizarReloj();
setInterval(actualizarReloj, 1000);

/* ------------------------------------------------------------------ */
/* Sesión temporal (se borra al cerrar la pestaña)                     */
/* ------------------------------------------------------------------ */
function obtenerTokenSesion() {
  let token = sessionStorage.getItem('uniguide_sesion');
  if (!token) {
    token = 'web-' + Date.now() + '-' + Math.random().toString(36).slice(2, 10);
    sessionStorage.setItem('uniguide_sesion', token);
  }
  return token;
}

/* ------------------------------------------------------------------ */
/* Seguridad: nunca insertar texto del usuario o del modelo como HTML  */
/* ------------------------------------------------------------------ */
function horaActual() {
  return new Date().toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' });
}

function iconoBot() {
  return '<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8">' +
    '<circle cx="12" cy="12" r="3"></circle><path d="M12 2v4M12 18v4M2 12h4M18 12h4"></path></svg>';
}

const prefiereMenosMovimiento = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

/* Efecto "máquina de escribir" para las respuestas del bot — imita
   una terminal imprimiendo su salida. No retrasa la respuesta real:
   el texto ya llegó completo del backend, esto solo controla cómo
   se REVELA en pantalla, con una duración total acotada (nunca más
   de ~700ms sin importar qué tan largo sea el texto). */
function revelarTexto(elemento, texto) {
  if (prefiereMenosMovimiento || texto.length < 2) {
    elemento.textContent = texto;
    return;
  }

  const DURACION_MS = Math.min(700, 220 + texto.length * 6);
  const pasos = texto.length;
  const intervalo = DURACION_MS / pasos;

  const cursor = document.createElement('span');
  cursor.className = 'escribiendo-cursor';

  let i = 0;
  elemento.textContent = '';
  elemento.appendChild(cursor);

  const timer = setInterval(() => {
    i++;
    elemento.textContent = texto.slice(0, i);
    elemento.appendChild(cursor);
    bajarChat();
    if (i >= pasos) {
      clearInterval(timer);
      cursor.remove();
    }
  }, intervalo);
}

function crearBurbuja({ texto, esUsuario, mapa, fuentes }) {
  const mensaje = document.createElement('div');
  mensaje.className = 'message ' + (esUsuario ? 'user-message' : 'bot-message');

  const avatar = document.createElement('div');
  avatar.className = 'msg-avatar ' + (esUsuario ? 'user-avatar' : 'bot-avatar');
  if (esUsuario) {
    avatar.textContent = 'TÚ';
  } else {
    avatar.innerHTML = iconoBot();
  }

  const contenedor = document.createElement('div');

  const burbuja = document.createElement('div');
  burbuja.className = 'message-bubble';
  contenedor.appendChild(burbuja);

  if (esUsuario) {
    burbuja.textContent = texto;
  } else {
    revelarTexto(burbuja, texto);
  }

  if (mapa && mapa.embed) {
    const caja = document.createElement('div');
    caja.className = 'map-box';

    const iframe = document.createElement('iframe');
    iframe.src = mapa.embed;
    iframe.loading = 'lazy';
    iframe.title = 'Ubicación de ' + mapa.nombre;
    iframe.setAttribute('referrerpolicy', 'no-referrer-when-downgrade');
    caja.appendChild(iframe);

    const enlace = document.createElement('a');
    enlace.className = 'map-link';
    enlace.href = mapa.url;
    enlace.target = '_blank';
    enlace.rel = 'noopener noreferrer';
    enlace.textContent = '📍 Abrir ' + mapa.nombre + ' en Google Maps';
    caja.appendChild(enlace);

    contenedor.appendChild(caja);
  }

  if (fuentes && fuentes.length) {
    const pie = document.createElement('div');
    pie.className = 'fuentes';
    pie.textContent = 'FUENTE · ' + fuentes.map((f) => f.titulo).join(' · ');
    contenedor.appendChild(pie);
  }

  const tiempo = document.createElement('span');
  tiempo.className = 'message-time';
  tiempo.textContent = horaActual();
  contenedor.appendChild(tiempo);

  mensaje.appendChild(avatar);
  mensaje.appendChild(contenedor);
  return mensaje;
}

function agregarMensaje(opciones) {
  chatMessages.appendChild(crearBurbuja(opciones));
  bajarChat();
}

function bajarChat() {
  chatMessages.scrollTop = chatMessages.scrollHeight;
}

/* Indicador "Escribiendo..." */
function mostrarEscribiendo() {
  const el = document.createElement('div');
  el.className = 'message bot-message';
  el.id = 'typingIndicator';
  el.innerHTML =
    '<div class="msg-avatar bot-avatar">' + iconoBot() + '</div>' +
    '<div><div class="message-bubble typing">' +
    '<span></span><span></span><span></span>' +
    '</div></div>';
  chatMessages.appendChild(el);
  bajarChat();
}

function ocultarEscribiendo() {
  const el = document.getElementById('typingIndicator');
  if (el) el.remove();
}

/* ------------------------------------------------------------------ */
/* Envío de la pregunta al backend                                      */
/* ------------------------------------------------------------------ */
async function enviarPregunta() {
  const pregunta = input.value.trim();
  if (!pregunta) return;

  if (pregunta.length > LIMITE_CARACTERES) {
    agregarMensaje({
      texto: 'Tu pregunta excede los ' + LIMITE_CARACTERES + ' caracteres permitidos. Intenta resumirla.',
      esUsuario: false,
    });
    return;
  }

  agregarMensaje({ texto: pregunta, esUsuario: true });
  input.value = '';
  actualizarContador();
  input.disabled = true;
  button.disabled = true;
  mostrarEscribiendo();

  try {
    const res = await fetch('/api/preguntar', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ pregunta, sesion: obtenerTokenSesion() }),
    });

    const datos = await res.json();
    ocultarEscribiendo();
    agregarMensaje({
      texto: datos.respuesta || 'No recibí una respuesta del servidor.',
      esUsuario: false,
      mapa: datos.mapa,
      fuentes: datos.fuentes,
    });

    if (datos.ms !== undefined) {
      console.log('[UniGuide]', { intencion: datos.intencion, motor: datos.motor, ms: datos.ms, tokens: datos.tokens });
    }
  } catch (err) {
    ocultarEscribiendo();
    agregarMensaje({
      texto: 'No pude conectarme con el servidor. Verifica tu conexión a internet e intenta de nuevo.',
      esUsuario: false,
    });
    console.error('[UniGuide]', err);
  } finally {
    input.disabled = false;
    button.disabled = false;
    input.focus();
  }
}

/* Contador de caracteres */
function actualizarContador() {
  if (!contador) return;
  const usados = input.value.length;
  contador.textContent = usados + ' / ' + LIMITE_CARACTERES;
  contador.classList.toggle('limite', usados >= LIMITE_CARACTERES);
}

/* Limpiar chat */
function limpiarChat() {
  chatMessages.innerHTML = '';
  sessionStorage.removeItem('uniguide_sesion');
  agregarMensaje({
    texto: 'Hola, soy UniGuide AI. Puedo ayudarte a encontrar información sobre la universidad: ubicaciones, trámites, horarios y servicios.',
    esUsuario: false,
  });
}

/* ------------------------------------------------------------------ */
/* Accesos rápidos (sidebar + directorio del hero)                      */
/* ------------------------------------------------------------------ */
const PREGUNTAS_RAPIDAS = {
  ubicaciones: '¿Dónde está la biblioteca?',
  tramites: '¿Qué necesito para solicitar una constancia de estudios?',
  horarios: '¿Cuál es el horario de la biblioteca?',
  servicios: '¿Qué servicios ofrece la universidad?',
  preguntas: '¿Qué carreras ofrece la UPSLP?',
};

function marcarActivo(categoria) {
  document.querySelectorAll('.menu-item').forEach((el) => {
    el.classList.toggle('active', el.dataset.categoria === categoria);
  });
}

function mostrarCategoria(categoria) {
  marcarActivo(categoria);

  if (categoria === 'inicio') {
    window.scrollTo({ top: 0, behavior: 'smooth' });
    input.focus();
    return;
  }

  input.value = PREGUNTAS_RAPIDAS[categoria] || '';
  actualizarContador();
  document.querySelector('.chat-console')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  input.focus();
}

/* ------------------------------------------------------------------ */
/* Eventos                                                              */
/* ------------------------------------------------------------------ */
button.addEventListener('click', enviarPregunta);

input.addEventListener('keydown', (evento) => {
  if (evento.key === 'Enter' && !evento.shiftKey) {
    evento.preventDefault();
    enviarPregunta();
  }
});

input.addEventListener('input', actualizarContador);
input.setAttribute('maxlength', String(LIMITE_CARACTERES));
actualizarContador();

document.querySelectorAll('[data-categoria]').forEach((el) => {
  el.addEventListener('click', () => mostrarCategoria(el.dataset.categoria));
});

const botonLimpiar = document.getElementById('clearButton');
if (botonLimpiar) botonLimpiar.addEventListener('click', limpiarChat);

/* ------------------------------------------------------------------ */
/* Estado del sistema — verifica el backend al cargar y refleja el      */
/* resultado en el indicador de la barra superior.                      */
/* ------------------------------------------------------------------ */
fetch('/api/salud')
  .then((r) => r.json())
  .then((d) => {
    console.log('[UniGuide] salud:', d);
    if (statusDot && statusText) {
      const conectado = d.estado === 'ok';
      statusDot.classList.toggle('ok', conectado);
      statusText.textContent = conectado ? 'sistema conectado' : 'base de datos sin conexión';
    }
  })
  .catch(() => {
    if (statusText) statusText.textContent = 'sin conexión con el servidor';
    console.warn('[UniGuide] El backend no responde. ¿Corriste "npm start"?');
  });
