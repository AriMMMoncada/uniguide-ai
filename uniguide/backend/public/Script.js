/* =====================================================================
   UniGuide AI - Cliente web
   Ingeniería de Software II - UPSLP

   Cambios respecto a la versión inicial:
     - Se conecta al backend real (POST /api/preguntar) en vez de usar
       respuestas quemadas en el código.
     - Se elimina la vulnerabilidad de XSS: el texto del usuario y del bot
       ya no se inserta con innerHTML sin escapar.
     - Indicador "Escribiendo..."            -> RS 1.4
     - Límite de 500 caracteres con contador -> RS 1.2
     - Renderizado del mapa                  -> RS 3.5
     - Historial temporal de la sesión       -> RF3 Módulo 1
   ===================================================================== */

'use strict';

const LIMITE_CARACTERES = 500;

const input = document.getElementById('questionInput');
const button = document.getElementById('sendButton');
const chatMessages = document.getElementById('chatMessages');
const contador = document.getElementById('charCounter');

/* ------------------------------------------------------------------ */
/* Sesión: identifica el chat actual para el historial del backend.     */
/* Se guarda en sessionStorage, así que se borra al cerrar la pestaña   */
/* (el requerimiento pide historial TEMPORAL, no persistente).          */
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
/* Seguridad: escapa cualquier texto antes de mostrarlo.                */
/* Sin esto, una pregunta como <img src=x onerror=alert(1)> ejecuta     */
/* código en el navegador de quien use la página.                       */
/* ------------------------------------------------------------------ */
function escapar(texto) {
  const div = document.createElement('div');
  div.textContent = texto;
  return div.innerHTML;
}

function horaActual() {
  return new Date().toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' });
}

/* ------------------------------------------------------------------ */
/* Construcción de burbujas                                             */
/* ------------------------------------------------------------------ */
function crearBurbuja({ texto, esUsuario, mapa, fuentes }) {
  const mensaje = document.createElement('div');
  mensaje.className = 'message ' + (esUsuario ? 'user-message' : 'bot-message');

  const avatar = document.createElement('div');
  avatar.className = 'bot-avatar';
  avatar.textContent = esUsuario ? '👤' : '🤖';

  const contenedor = document.createElement('div');

  const burbuja = document.createElement('div');
  burbuja.className = 'message-bubble';
  burbuja.textContent = texto;   // textContent = inmune a inyección de HTML

  contenedor.appendChild(burbuja);

  // RS 3.5: si el backend devolvió coordenadas, se muestra el mapa.
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

  // Trazabilidad del grounding: de dónde salió la respuesta.
  if (fuentes && fuentes.length) {
    const pie = document.createElement('div');
    pie.className = 'fuentes';
    pie.textContent = 'Fuente: ' + fuentes.map((f) => f.titulo).join(' · ');
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

/* ------------------------------------------------------------------ */
/* RS 1.4: indicador "Escribiendo..."                                   */
/* ------------------------------------------------------------------ */
function mostrarEscribiendo() {
  const el = document.createElement('div');
  el.className = 'message bot-message';
  el.id = 'typingIndicator';
  el.innerHTML =
    '<div class="bot-avatar">🤖</div>' +
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

    // Útil durante la demo: deja ver intención, motor y tiempo de respuesta.
    if (datos.ms !== undefined) {
      console.log('[UniGuide]', {
        intencion: datos.intencion,
        motor: datos.motor,
        ms: datos.ms,
        tokens: datos.tokens,
      });
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

/* ------------------------------------------------------------------ */
/* RS 1.2: contador de caracteres                                       */
/* ------------------------------------------------------------------ */
function actualizarContador() {
  if (!contador) return;
  const usados = input.value.length;
  contador.textContent = usados + ' / ' + LIMITE_CARACTERES;
  contador.classList.toggle('limite', usados >= LIMITE_CARACTERES);
}

/* ------------------------------------------------------------------ */
/* Limpiar chat                                                         */
/* ------------------------------------------------------------------ */
function limpiarChat() {
  chatMessages.innerHTML = '';
  sessionStorage.removeItem('uniguide_sesion');
  agregarMensaje({
    texto: '¡Hola! Soy UniGuide AI. Puedo ayudarte a encontrar información sobre la universidad: ubicaciones, trámites, horarios y servicios.',
    esUsuario: false,
  });
}

/* ------------------------------------------------------------------ */
/* Accesos rápidos del menú lateral y las tarjetas                      */
/* ------------------------------------------------------------------ */
const PREGUNTAS_RAPIDAS = {
  ubicaciones: '¿Dónde está la biblioteca?',
  tramites: '¿Qué necesito para solicitar una constancia de estudios?',
  horarios: '¿Cuál es el horario de la biblioteca?',
  servicios: '¿Qué servicios ofrece la universidad?',
  preguntas: '¿Qué carreras ofrece la UPSLP?',
  ayuda: '¿Dónde está Servicios Escolares?',
};

function mostrarCategoria(categoria) {
  input.value = PREGUNTAS_RAPIDAS[categoria] || '';
  actualizarContador();
  input.focus();

  document.querySelectorAll('.menu-item').forEach((el) => el.classList.remove('active'));
  const boton = document.querySelector('[data-categoria="' + categoria + '"]');
  if (boton) boton.classList.add('active');
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

// Aviso temprano si el backend no está levantado (ayuda mucho en la demo).
fetch('/api/salud')
  .then((r) => r.json())
  .then((d) => console.log('[UniGuide] salud:', d))
  .catch(() => console.warn('[UniGuide] El backend no responde. ¿Corriste "npm start"?'));

const botonLimpiar = document.getElementById('clearButton');
if (botonLimpiar) botonLimpiar.addEventListener('click', limpiarChat);
