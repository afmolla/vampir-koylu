const fs = require('fs');
const path = require('path');
const healthPath = path.join(__dirname, 'src', 'routes', 'health.js');
const text = fs.readFileSync(healthPath, 'utf8');
const m = text.match(/SERVER_BUILD\s*=\s*'([^']+)'/);
process.stdout.write(m ? m[1] : '');
