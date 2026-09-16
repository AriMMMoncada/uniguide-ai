/**
 * Clasificador de intencion (RF1 - Modulo 2).
 *
 * Es deliberadamente simple y deterministico: clasifica por palabras clave
 * sobre el texto normalizado. Ventajas para este proyecto:
 *   - No consume tokens ni depende de la API (RNF3 Modulo 2).
 *   - Es auditable y explicable ante el docente.
 *   - Tolera faltas de ortografia menores (RNF2 Modulo 2) porque
 *     normaliza acentos y usa distancia de Levenshtein acotada.
 */

const CATEGORIAS = ['UBICACION', 'TRAMITE', 'SERVICIO', 'HORARIO', 'ACADEMICO', 'GENERAL'];

const SENALES = {
  UBICACION: ['donde', 'ubicacion', 'ubicado', 'ubica', 'edificio', 'salon', 'aula',
              'laboratorio', 'lab', 'mapa', 'llegar', 'encuentro', 'queda', 'piso', 'campus'],
  HORARIO:   ['horario', 'hora', 'abre', 'cierra', 'abierto', 'cerrado', 'atienden',
              'atencion', 'disponible', 'cuando'],
  TRAMITE:   ['tramite', 'constancia', 'kardex', 'credencial', 'inscripcion', 'reinscripcion',
              'baja', 'titulacion', 'servicio social', 'requisito', 'requisitos', 'papeles',
              'documento', 'solicitar', 'costo', 'cuesta', 'pago', 'ficha'],
  SERVICIO:  ['servicio', 'biblioteca', 'prestamo', 'cafeteria', 'comedor', 'deporte',
              'tutoria', 'tutorias', 'computo', 'internet', 'wifi', 'enfermeria'],
  ACADEMICO: ['carrera', 'carreras', 'ingenieria', 'licenciatura', 'materia', 'materias',
              'plan de estudios', 'oferta', 'cuatrimestre', 'creditos', 'maestria'],
};

/** Quita acentos, pasa a minusculas y colapsa espacios. */
function normalizar(texto) {
  return String(texto)
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9ñ\s]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

/** Distancia de Levenshtein (para tolerar faltas de ortografia menores). */
function levenshtein(a, b) {
  const m = a.length, n = b.length;
  if (Math.abs(m - n) > 2) return 99;
  let prev = Array.from({ length: n + 1 }, (_, j) => j);
  for (let i = 1; i <= m; i++) {
    const cur = [i];
    for (let j = 1; j <= n; j++) {
      cur[j] = Math.min(
        prev[j] + 1,
        cur[j - 1] + 1,
        prev[j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1)
      );
    }
    prev = cur;
  }
  return prev[n];
}

/** ¿La palabra del usuario coincide con la senal, permitiendo 1 error? */
function coincide(palabra, senal) {
  if (senal.includes(' ')) return false;
  if (palabra === senal) return true;
  if (palabra.length >= 5 && senal.length >= 5 && levenshtein(palabra, senal) <= 1) return true;
  return false;
}

/**
 * @param {string} pregunta
 * @returns {{intencion: string, confianza: number, puntajes: object}}
 */
function detectarIntencion(pregunta) {
  const texto = normalizar(pregunta);
  const palabras = texto.split(' ').filter(Boolean);
  const puntajes = {};

  for (const categoria of CATEGORIAS) {
    const senales = SENALES[categoria] || [];
    let puntaje = 0;
    for (const senal of senales) {
      if (senal.includes(' ')) {
        if (texto.includes(senal)) puntaje += 2;
        continue;
      }
      if (palabras.some((p) => coincide(p, senal))) puntaje += 1;
    }
    puntajes[categoria] = puntaje;
  }

  const ordenadas = CATEGORIAS
    .map((c) => [c, puntajes[c]])
    .sort((a, b) => b[1] - a[1]);

  const [mejor, puntajeMejor] = ordenadas[0];
  const segundo = ordenadas[1][1];

  if (puntajeMejor === 0) {
    return { intencion: 'GENERAL', confianza: 0, puntajes };
  }
  const confianza = Math.min(1, (puntajeMejor - segundo + puntajeMejor) / (puntajeMejor * 2 || 1));
  return { intencion: mejor, confianza: Number(confianza.toFixed(2)), puntajes };
}

module.exports = { detectarIntencion, normalizar, CATEGORIAS };
