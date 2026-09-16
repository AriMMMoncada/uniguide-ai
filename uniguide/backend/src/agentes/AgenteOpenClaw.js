/**
 * AgenteOpenClaw - adaptador hacia un gateway OpenClaw autohospedado.
 *
 * QUE ES OPENCLAW
 * OpenClaw es un agente de IA de codigo abierto que se autohospeda en una
 * maquina propia y recibe comandos desde apps de mensajeria (Telegram,
 * WhatsApp, Discord, Signal...). Requiere Node.js >= 22 y una API key de
 * un proveedor soportado (Anthropic, OpenAI o Google).
 *
 * COMO ENCAJA EN UNIGUIDE AI
 * OpenClaw NO reemplaza a este backend: lo consume. La arquitectura es:
 *
 *   Estudiante --(Telegram)--> OpenClaw Gateway --(skill uniguide)-->
 *        --> POST /api/kb/buscar de ESTE backend --> MySQL
 *
 * Es decir, OpenClaw aporta el canal y el bucle agentico; UniGuide aporta
 * la base de conocimiento y el grounding. La skill de OpenClaw que hace
 * esa llamada esta en /openclaw/skills/uniguide/.
 *
 * Esta clase cubre el sentido inverso: cuando se quiere que la PAGINA WEB
 * tambien use el agente de OpenClaw como motor de razonamiento, el backend
 * le envia la pregunta y el contexto ya recuperado por HTTP local.
 *
 * NOTA DE SEGURIDAD: el gateway se expone solo en localhost o en la red
 * interna, nunca publicamente. Un OpenClaw accesible desde internet es un
 * riesgo real de ejecucion remota.
 */
const { AgenteIA, SYSTEM_PROMPT, SIN_INFORMACION } = require('./AgenteIA');

class AgenteOpenClaw extends AgenteIA {
  constructor() {
    super();
    this.url = process.env.OPENCLAW_URL || 'http://localhost:18789';
    this.token = process.env.OPENCLAW_TOKEN || '';
    this.maxTokens = Number(process.env.IA_MAX_TOKENS || 300);
  }

  get nombre() { return `openclaw (gateway ${this.url})`; }

  async responder({ pregunta, contexto, intencion }) {
    if (!contexto || !contexto.trim()) return { texto: SIN_INFORMACION, tokens: 0 };

    const ctrl = new AbortController();
    const timeout = setTimeout(() => ctrl.abort(), 8000);
    try {
      const res = await fetch(`${this.url}/api/message`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(this.token ? { Authorization: `Bearer ${this.token}` } : {}),
        },
        body: JSON.stringify({
          agent: 'uniguide',
          system: SYSTEM_PROMPT,
          message: `CONTEXTO:\n${contexto}\n\nINTENCION: ${intencion}\nPREGUNTA: ${pregunta}`,
          maxTokens: this.maxTokens,
        }),
        signal: ctrl.signal,
      });
      if (!res.ok) throw new Error(`OpenClaw respondió ${res.status}`);
      const data = await res.json();
      return {
        texto: (data.reply || data.text || SIN_INFORMACION).trim(),
        tokens: data.usage?.totalTokens || 0,
      };
    } finally {
      clearTimeout(timeout);
    }
  }
}

module.exports = AgenteOpenClaw;
