/**
 * AgenteGemini - Google AI Studio (Gemini).
 * Se eligio como motor generativo por defecto porque ofrece una capa
 * gratuita sin tarjeta de credito, lo que se ajusta al presupuesto del
 * proyecto academico y al RNF3 del Modulo 2 (control de costos).
 */
const { AgenteIA, SYSTEM_PROMPT, SIN_INFORMACION } = require('./AgenteIA');

class AgenteGemini extends AgenteIA {
  constructor() {
    super();
    this.apiKey = process.env.GEMINI_API_KEY;
    this.modelo = process.env.GEMINI_MODEL || 'gemini-2.0-flash';
    this.maxTokens = Number(process.env.IA_MAX_TOKENS || 300);
  }

  get nombre() { return `gemini (${this.modelo})`; }

  async responder({ pregunta, contexto }) {
    if (!contexto || !contexto.trim()) return { texto: SIN_INFORMACION, tokens: 0 };
    if (!this.apiKey) throw new Error('Falta GEMINI_API_KEY en el archivo .env');

    const url = `https://generativelanguage.googleapis.com/v1beta/models/${this.modelo}:generateContent?key=${this.apiKey}`;
    const cuerpo = {
      systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
      contents: [{ role: 'user', parts: [{ text: `CONTEXTO:\n${contexto}\n\nPREGUNTA DEL ESTUDIANTE: ${pregunta}` }] }],
      generationConfig: {
        temperature: 0.1,           // baja temperatura = menos invencion
        maxOutputTokens: this.maxTokens, // RNF3: limite de tokens por respuesta
      },
    };

    const ctrl = new AbortController();
    const timeout = setTimeout(() => ctrl.abort(), 8000);
    try {
      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(cuerpo),
        signal: ctrl.signal,
      });
      if (!res.ok) throw new Error(`Gemini respondió ${res.status}: ${await res.text()}`);
      const data = await res.json();
      const texto = data?.candidates?.[0]?.content?.parts?.map((p) => p.text).join('') || SIN_INFORMACION;
      const tokens = data?.usageMetadata?.totalTokenCount || 0;
      return { texto: texto.trim(), tokens };
    } finally {
      clearTimeout(timeout);
    }
  }
}

module.exports = AgenteGemini;
