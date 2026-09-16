/**
 * AgenteOpenAI - proveedor mencionado explicitamente en el documento
 * de requerimientos. Se incluye para demostrar que la capa adaptadora
 * permite intercambiar proveedores sin tocar el controlador.
 */
const { AgenteIA, SYSTEM_PROMPT, SIN_INFORMACION } = require('./AgenteIA');

class AgenteOpenAI extends AgenteIA {
  constructor() {
    super();
    this.apiKey = process.env.OPENAI_API_KEY;
    this.modelo = process.env.OPENAI_MODEL || 'gpt-4o-mini';
    this.maxTokens = Number(process.env.IA_MAX_TOKENS || 300);
  }

  get nombre() { return `openai (${this.modelo})`; }

  async responder({ pregunta, contexto }) {
    if (!contexto || !contexto.trim()) return { texto: SIN_INFORMACION, tokens: 0 };
    if (!this.apiKey) throw new Error('Falta OPENAI_API_KEY en el archivo .env');

    const res = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify({
        model: this.modelo,
        temperature: 0.1,
        max_tokens: this.maxTokens,
        messages: [
          { role: 'system', content: SYSTEM_PROMPT },
          { role: 'user', content: `CONTEXTO:\n${contexto}\n\nPREGUNTA DEL ESTUDIANTE: ${pregunta}` },
        ],
      }),
    });
    if (!res.ok) throw new Error(`OpenAI respondió ${res.status}: ${await res.text()}`);
    const data = await res.json();
    return {
      texto: (data.choices?.[0]?.message?.content || SIN_INFORMACION).trim(),
      tokens: data.usage?.total_tokens || 0,
    };
  }
}

module.exports = AgenteOpenAI;
