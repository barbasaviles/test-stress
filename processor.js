const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
dotenv.config();

const LOG_FILE = path.join(__dirname, 'responses.log');

// Limpiar log al inicio (opcional, para tener logs frescos por ejecución)
try { fs.writeFileSync(LOG_FILE, ''); } catch (e) { }

function logHeaders(requestParams, context, ee, next) {
  // Asegurar que headers existe
  requestParams.headers = requestParams.headers || {};

  // Inyectar cookie inicial SOLO si no hay cookie ya
  // Leer directamente de process.env (no de context.vars que no persiste entre VUs)
  if (!requestParams.headers['Cookie'] && process.env.AUTH_COOKIE) {
    const cookieValue = process.env.AUTH_COOKIE.replace(/"/g, ''); // Remover comillas
    requestParams.headers['Cookie'] = cookieValue;
  }

  // Inyectar User-Agent si existe en el entorno
  if (process.env.USER_AGENT) {
    requestParams.headers['User-Agent'] = process.env.USER_AGENT.replace(/"/g, '');
  }

  const logEntry = `
==================================================
[REQUEST] ${requestParams.method} ${requestParams.url}
Headers: ${JSON.stringify(requestParams.headers)}
==================================================
`;
  try {
    fs.appendFileSync(LOG_FILE, logEntry);
  } catch (error) {
    console.error('Error escribiendo log:', error);
  }
  return next();
}

function logResponse(requestParams, response, context, ee, next) {
  const logEntry = `
--------------------------------------------------
[RESPONSE] ${requestParams.method} ${requestParams.url}
Status: ${response.statusCode}
Headers: ${JSON.stringify(response.headers)}
Body:
${response.body}
--------------------------------------------------
`;

  try {
    fs.appendFileSync(LOG_FILE, logEntry);
  } catch (error) {
    console.error('Error escribiendo log:', error);
  }

  return next();
}

module.exports = {
  logHeaders,
  logResponse
};
