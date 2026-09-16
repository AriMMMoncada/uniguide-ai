/**
 * Recuperacion de contexto desde la base de conocimiento (RF1 - Modulo 3).
 *
 * Estrategia hibrida en dos pasos, pensada para MySQL sin extensiones:
 *   1. Busqueda FULLTEXT en modo lenguaje natural sobre base_conocimiento.
 *      El indice FULLTEXT es lo que permite cumplir el RNF2 (<1 s).
 *   2. Si el FULLTEXT no devuelve nada (pasa con preguntas muy cortas o con
 *      palabras muy frecuentes), se cae a una busqueda LIKE por palabras
 *      clave. Es mas lenta pero cubre el hueco.
 *
 * Si ninguna de las dos devuelve resultados, se retorna un arreglo vacio y
 * el controlador NI SIQUIERA llama a la IA (RS 2.4), devolviendo el mensaje
 * predeterminado. Ese corto-circuito es lo que garantiza el RNF1 del
 * Modulo 2: si no hay contexto, no hay generacion, por lo tanto no hay
 * alucinacion posible.
 */
const { pool } = require('./db');
const { normalizar } = require('./intencion');

const UMBRAL_RELEVANCIA = 0.15;
const MAX_FRAGMENTOS = 4;

/** Palabras vacias del espanol que no aportan a la busqueda. */
const VACIAS = new Set([
  'el','la','los','las','un','una','unos','unas','de','del','al','a','en','y','o','que',
  'es','son','me','mi','se','su','sus','por','para','con','como','donde','cual','cuales',
  'cuanto','cuanta','esta','este','hay','tiene','necesito','quiero','puedo','favor','hola',
]);

function terminos(pregunta) {
  return normalizar(pregunta)
    .split(' ')
    .filter((p) => p.length >= 3 && !VACIAS.has(p));
}

async function buscarFulltext(pregunta) {
  const consulta = terminos(pregunta).join(' ');
  if (!consulta) return [];

  const [filas] = await pool.query(
    `SELECT bc.id_conocimiento, bc.titulo, bc.contenido, bc.palabras_clave,
            c.clave AS categoria,
            l.nombre AS lugar_nombre, l.latitud, l.longitud, l.url_mapa,
            t.titulo AS tramite_titulo, t.requisitos, t.costo, t.area_responsable,
            MATCH(bc.titulo, bc.contenido, bc.palabras_clave)
              AGAINST (? IN NATURAL LANGUAGE MODE) AS relevancia
       FROM base_conocimiento bc
       JOIN categoria c ON c.id_categoria = bc.id_categoria
       LEFT JOIN lugar   l ON l.id_lugar   = bc.id_lugar
       LEFT JOIN tramite t ON t.id_tramite = bc.id_tramite
      WHERE bc.activo = 1
        AND MATCH(bc.titulo, bc.contenido, bc.palabras_clave)
              AGAINST (? IN NATURAL LANGUAGE MODE)
      ORDER BY relevancia DESC
      LIMIT ?`,
    [consulta, consulta, MAX_FRAGMENTOS]
  );
  return filas.filter((f) => Number(f.relevancia) >= UMBRAL_RELEVANCIA);
}

async function buscarLike(pregunta) {
  const palabras = terminos(pregunta).slice(0, 5);
  if (!palabras.length) return [];

  const condiciones = palabras
    .map(() => '(bc.titulo LIKE ? OR bc.contenido LIKE ? OR bc.palabras_clave LIKE ?)')
    .join(' OR ');
  const parametros = palabras.flatMap((p) => [`%${p}%`, `%${p}%`, `%${p}%`]);

  const [filas] = await pool.query(
    `SELECT bc.id_conocimiento, bc.titulo, bc.contenido, bc.palabras_clave,
            c.clave AS categoria,
            l.nombre AS lugar_nombre, l.latitud, l.longitud, l.url_mapa,
            t.titulo AS tramite_titulo, t.requisitos, t.costo, t.area_responsable,
            1 AS relevancia
       FROM base_conocimiento bc
       JOIN categoria c ON c.id_categoria = bc.id_categoria
       LEFT JOIN lugar   l ON l.id_lugar   = bc.id_lugar
       LEFT JOIN tramite t ON t.id_tramite = bc.id_tramite
      WHERE bc.activo = 1 AND (${condiciones})
      LIMIT ?`,
    [...parametros, MAX_FRAGMENTOS]
  );
  return filas;
}

/**
 * Recupera los fragmentos de contexto relevantes para una pregunta.
 * @returns {Promise<Array>} fragmentos (vacio si no hay nada relevante)
 */
async function recuperarContexto(pregunta) {
  let fragmentos = [];
  try {
    fragmentos = await buscarFulltext(pregunta);
  } catch (err) {
    console.warn('[KB] FULLTEXT fallo, se usa LIKE:', err.message);
  }
  if (!fragmentos.length) {
    fragmentos = await buscarLike(pregunta);
  }
  return fragmentos;
}

/** Arma el bloque de texto que se inyecta como contexto en el prompt (RS 2.2). */
function formatearContexto(fragmentos) {
  return fragmentos
    .map((f, i) => {
      const partes = [`[${i + 1}] ${f.titulo}`, f.contenido];
      if (f.requisitos) partes.push(`Requisitos: ${f.requisitos}`);
      if (f.costo != null && Number(f.costo) > 0) partes.push(`Costo: $${Number(f.costo).toFixed(2)} MXN`);
      if (f.area_responsable) partes.push(`Área responsable: ${f.area_responsable}`);
      if (f.lugar_nombre) partes.push(`Lugar: ${f.lugar_nombre}`);
      return partes.join('\n');
    })
    .join('\n\n');
}

/** Extrae el primer lugar con coordenadas para el RF2 del Modulo 3. */
function extraerLugar(fragmentos) {
  const conLugar = fragmentos.find((f) => f.lugar_nombre && f.latitud != null);
  if (!conLugar) return null;
  const lat = Number(conLugar.latitud);
  const lng = Number(conLugar.longitud);
  return {
    nombre: conLugar.lugar_nombre,
    latitud: lat,
    longitud: lng,
    url: conLugar.url_mapa || `https://maps.google.com/?q=${lat},${lng}`,
    embed: `https://www.google.com/maps?q=${lat},${lng}&hl=es&z=18&output=embed`,
  };
}

async function listarFaq(limite = 10) {
  const [filas] = await pool.query(
    'SELECT pregunta, respuesta FROM pregunta_frecuente ORDER BY orden ASC LIMIT ?',
    [limite]
  );
  return filas;
}

module.exports = { recuperarContexto, formatearContexto, extraerLugar, listarFaq };
