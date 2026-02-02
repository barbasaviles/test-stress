const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

const environment = process.argv[2] || 'smoke';
const artilleryBin = path.join(__dirname, 'node_modules', '.bin', 'artillery.cmd');

console.log(`[Launcher] Iniciando prueba en entorno: ${environment}`);
console.log(`[Launcher] Ejecutable: ${artilleryBin}`);

// HACK: Eliminar undici anidado en cheerio/otros que requiere Node 18
const offendingUndici = path.join(__dirname, 'node_modules', 'cheerio', 'node_modules', 'undici');
if (fs.existsSync(offendingUndici)) {
    console.log('[Launcher] Eliminando versión incompatible de undici anidada...');
    try {
        fs.rmSync(offendingUndici, { recursive: true, force: true });
    } catch (e) {
        console.warn('[Launcher] No se pudo eliminar undici anidado:', e.message);
    }
}

const out = fs.openSync('test.log', 'w');
const err = fs.openSync('test.log', 'a');

const args = ['run', '--config', 'artillery.yml', '--environment', environment];

const child = spawn(artilleryBin, args, {
    stdio: ['ignore', out, err],
    env: process.env,
    shell: true
});

child.on('close', (code) => {
    console.log(`[Launcher] Artillery finalizó con código: ${code}`);
    process.exit(code);
});

child.on('error', (err) => {
    console.error('[Launcher] Error al iniciar Artillery:', err);
});
