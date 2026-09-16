/**
 * Fabrica de agentes (patron Factory).
 * Lee la variable de entorno AGENTE y devuelve la implementacion
 * correspondiente de la interfaz AgenteIA. Incluye degradacion elegante:
 * si el motor configurado falla en tiempo de ejecucion, se cae al
 * AgenteMock para que el sistema no deje de responder (RNF1 Modulo 3).
 */
const AgenteMock = require('./AgenteMock');
const AgenteGemini = require('./AgenteGemini');
const AgenteOpenAI = require('./AgenteOpenAI');
const AgenteOpenClaw = require('./AgenteOpenClaw');
const AgenteNanoClaw = require('./AgenteNanoClaw');
const { SIN_INFORMACION } = require('./AgenteIA');

const REGISTRO = {
  mock: AgenteMock,
  gemini: AgenteGemini,
  openai: AgenteOpenAI,
  openclaw: AgenteOpenClaw,
  nanoclaw: AgenteNanoClaw,
};

function crearAgente(clave = process.env.AGENTE || 'mock') {
  const Clase = REGISTRO[String(clave).toLowerCase()];
  if (!Clase) {
    console.warn(`[AGENTE] "${clave}" no existe. Se usa "mock".`);
    return new AgenteMock();
  }
  return new Clase();
}

/** Agente principal + respaldo automatico. */
function crearAgenteConRespaldo() {
  const principal = crearAgente();
  const respaldo = new AgenteMock();

  return {
    get nombre() { return principal.nombre; },
    async responder(params) {
      try {
        return await principal.responder(params);
      } catch (err) {
        console.error(`[AGENTE] ${principal.nombre} falló: ${err.message}. Respaldo: mock.`);
        return respaldo.responder(params);
      }
    },
  };
}

module.exports = { crearAgente, crearAgenteConRespaldo, REGISTRO, SIN_INFORMACION };
