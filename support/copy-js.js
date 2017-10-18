const fs = require('fs');

const source = process.argv[2];
const target = process.argv[3];

fs.writeFileSync(target, fs.readFileSync(source, 'utf-8'), 'utf-8');