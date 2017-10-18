const fs = require('fs');

const file = process.argv[2];
const text = fs.readFileSync(file, 'utf-8');

fs.writeFileSync(file, '<!DOCTYPE html>\n' + text, 'utf-8');