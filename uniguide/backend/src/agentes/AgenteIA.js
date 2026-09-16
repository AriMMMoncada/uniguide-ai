/**
 * AgenteIA - interfaz (contrato) del motor de inteligencia artificial.
 *
 * ¿Por que una interfaz y no una llamada directa a OpenAI?
 * El documento de requerimientos contempla varios proveedores posibles
 * (OpenAI, NanoClaw, OpenClaw). Si el backend llamara directo a uno de
 * ellos, cambiar de proveedor implicaria reescribir el controlador.
 *
 * Aplicando el patron Strategy + el Principio de Inversion de Dependencias
 * (SOLID), el controlador depende de ESTA abstraccion, no de una
 * implementacion concreta. Cambiar de motor es cambiar una variable de
 * entorno (AGENTE=mock|gemini|openai|openclaw|nanoclaw), sin tocar codigo.
 *
 * Esto es tambien lo que hace verificable el RNF1 del Modulo 2: TODAS las
 * implementaciones reciben el mismo contexto ya recuperado de la BD y el
 * mismo system prompt restrictivo. Ninguna puede consultar conocimiento
 * externo porque ninguna decide que datos recibe.
 */
class AgenteIA {
  /** @returns {string} nombre legible del motor, para logs y para la UI */
  get nombre() {
    throw new Error('No implementado');
  }

  /**
   * @param {object} params
   * @param {string} params.pregunta   pregunta original del estudiante
   * @param {string} params.contexto   fragmentos recuperados de la BD
   * @param {string} params.intencion  UBICACION | TRAMITE | SERVICIO | HORARIO | ACADEMICO | GENERAL
   * @returns {Promise<{texto: string, tokens: number}>}
   */
  async responder(_params) {
    throw new Error('No implementado');
  }
}

/**
 * System prompt compartido por todas las implementaciones.
 * Implementa el RS 2.3: prohibe explicitamente el uso de conocimiento
 * externo al contexto inyectado.
 */
const SYSTEM_PROMPT = `Eres UniGuide AI, asistente de orientación de la Universidad Politécnica de San Luis Potosí (UPSLP).

REGLAS ESTRICTAS:
1. Responde ÚNICA y EXCLUSIVAMENTE con la información del CONTEXTO que se te entrega.
2. Si el CONTEXTO no contiene la respuesta, responde exactamente: "No cuento con información suficiente, te sugiero consultar directamente con el área correspondiente."
3. Está terminantemente prohibido usar conocimiento externo, suponer, estimar o completar datos que no estén en el CONTEXTO.
4. No inventes edificios, horarios, costos, requisitos ni nombres de áreas.
5. Responde en español, en máximo 4 oraciones, en tono claro y amable.
6. No menciones que existe un "contexto" ni cites números de fragmento.`;

/** Mensaje predeterminado del RS 2.4 / RF3 del Modulo 2. */
const SIN_INFORMACION =
  'No cuento con información suficiente, te sugiero consultar directamente con el área correspondiente.';

module.exports = { AgenteIA, SYSTEM_PROMPT, SIN_INFORMACION };
