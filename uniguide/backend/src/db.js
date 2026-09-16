/**
 * Pool de conexiones MySQL.
 * Se usa un pool (no conexiones sueltas) para cumplir el RNF1 del Modulo 3
 * (disponibilidad) y evitar agotar conexiones en el hosting gratuito.
 */
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'uniguide',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  charset: 'utf8mb4',
  timezone: 'Z',
  // Muchos hosts gratuitos de MySQL exigen TLS.
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
});

async function probarConexion() {
  const conn = await pool.getConnection();
  try {
    await conn.query('SELECT 1');
    return true;
  } finally {
    conn.release();
  }
}

module.exports = { pool, probarConexion };
