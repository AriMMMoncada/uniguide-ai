/**
 * AgenteMock - implementacion sin API key.
 *
 * NO es un "chatbot falso": recibe exactamente el mismo contexto recuperado
 * de la base de datos que los demas agentes y redacta la respuesta con
 * plantillas deterministicas segun la intencion detectada. Por definicion
 * tiene tasa de alucinacion CERO, porque nunca genera texto libre.
 *
 * Sirve para dos cosas:
 *   1. Que la Prueba de Concepto funcione sin costo ni credenciales.
 *   2. Servir de linea base para comparar contra los motores generativos.
 */
const { AgenteIA, SIN_INFORMACION } = require('./AgenteIA');

class AgenteMock extends AgenteIA {
  get nombre() { return 'mock (plantillas sobre contexto, sin LLM)'; }

  async responder({ contexto, intencion }) {
    if (!contexto || !contexto.trim()) {
      return { texto: SIN_INFORMACION, tokens: 0 };
    }

    // Se toma el primer fragmento: es el de mayor relevancia FULLTEXT.
    const primero = contexto.split('\n\n')[0];
    const lineas = primero.split('\n').filter(Boolean);
    const cuerpo = lineas.slice(1).join(' ');

    const prefijos = {
      UBICACION: 'Con gusto te ubico: ',
      HORARIO:   'Este es el horario que tengo registrado: ',
      TRAMITE:   'Sobre ese trámite: ',
      SERVICIO:  'Sobre ese servicio: ',
      ACADEMICO: 'Sobre la oferta académica: ',
      GENERAL:   '',
    };

    return {
      texto: (prefijos[intencion] || '') + cuerpo,
      tokens: 0,
    };
  }
}

module.exports = AgenteMock;
