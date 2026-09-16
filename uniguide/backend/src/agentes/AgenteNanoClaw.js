/**
 * AgenteNanoClaw - adaptador hacia NanoClaw.
 *
 * QUE ES NANOCLAW
 * NanoClaw lo creo Gavriel Cohen como respuesta a las preocupaciones de
 * seguridad que genero OpenClaw. Su diferencia central es el aislamiento:
 * cada agente corre en su propio contenedor (Docker o Apple Container),
 * los contenedores son efimeros (se crean en cada invocacion y se destruyen
 * despues), el agente corre como usuario sin privilegios y solo ve los
 * directorios montados explicitamente. El limite lo impone el sistema
 * operativo, no la aplicacion. Su base de codigo es de menos de 4,000
 * lineas, auditable en pocas horas.
 *
 * POR QUE IMPORTA PARA UNIGUIDE AI
 * El sistema maneja informacion institucional y credenciales de base de
 * datos. Si en el futuro se le da al agente capacidad de ESCRITURA sobre
 * la base de conocimiento (RF3 Modulo 3), el aislamiento por contenedor
 * deja de ser un lujo. Por eso NanoClaw se documenta como la opcion
 * recomendada para un despliegue institucional real, y OpenClaw como la
 * opcion recomendada para la Prueba de Concepto (mas integraciones listas).
 */
const { AgenteIA, SYSTEM_PROMPT, SIN_INFORMACION } = require('./AgenteIA');

class AgenteNanoClaw extends AgenteIA {
  constructor() {
    super();
    this.url = process.env.NANOCLAW_URL || 'http://localhost:8787';
    this.token = process.env.NANOCLAW_TOKEN || '';
    this.maxTokens = Number(process.env.IA_MAX_TOKENS || 300);
  }

  get nombre() { return `nanoclaw (contenedor ${this.url})`; }

  async responder({ pregunta, contexto, intencion }) {
    if (!contexto || !contexto.trim()) return { texto: SIN_INFORMACION, tokens: 0 };

    const ctrl = new AbortController();
    const timeout = setTimeout(() => ctrl.abort(), 8000);
    try {
      const res = await fetch(`${this.url}/invoke`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(this.token ? { Authorization: `Bearer ${this.token}` } : {}),
        },
        body: JSON.stringify({
          agent: 'uniguide',
          systemPrompt: SYSTEM_PROMPT,
          input: `CONTEXTO:\n${contexto}\n\nINTENCION: ${intencion}\nPREGUNTA: ${pregunta}`,
          maxTokens: this.maxTokens,
        }),
        signal: ctrl.signal,
      });
      if (!res.ok) throw new Error(`NanoClaw respondió ${res.status}`);
      const data = await res.json();
      return {
        texto: (data.output || data.reply || SIN_INFORMACION).trim(),
        tokens: data.tokens || 0,
      };
    } finally {
      clearTimeout(timeout);
    }
  }
}

module.exports = AgenteNanoClaw;
