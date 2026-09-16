// Genera un hash bcrypt para el usuario administrador.
// Uso: node scripts/hash.js "miPasswordSegura"
const bcrypt = require('bcryptjs');

const password = process.argv[2];
if (!password) {
  console.error('Uso: node scripts/hash.js "miPasswordSegura"');
  process.exit(1);
}
console.log(bcrypt.hashSync(password, 12));
