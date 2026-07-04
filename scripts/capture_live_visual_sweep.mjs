#!/usr/bin/env node
import { mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { spawn, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const screenshotDir = resolve(
  repoRoot,
  'build/screenshots/korido_live_visual_sweep',
);
const manifestPath = resolve(screenshotDir, 'capture-manifest.json');
const deviceId = process.env.KORIDO_SIM_UDID;
const apiUrl =
  process.env.KORIDO_API_URL ?? 'https://korido-api.joonalabs.com/api/v1';
const env = process.env.KORIDO_ENV ?? 'staging';
const extraFlutterArgs = process.argv.slice(2);

if (!deviceId) {
  console.error('KORIDO_SIM_UDID is required for live visual capture.');
  process.exit(64);
}

rmSync(screenshotDir, { recursive: true, force: true });
mkdirSync(screenshotDir, { recursive: true });

const captureStartedAt = new Date().toISOString();
const capturedScreenshots = [];

const flutterArgs = [
  'test',
  '-d',
  deviceId,
  `--dart-define=ENV=${env}`,
  `--dart-define=API_URL=${apiUrl}`,
  '--dart-define=KORIDO_SCREENSHOT_MARKERS=true',
  'integration_test/flows/live_api_visual_sweep_test.dart',
  ...extraFlutterArgs,
];

const child = spawn('flutter', flutterArgs, {
  cwd: repoRoot,
  env: process.env,
  stdio: ['ignore', 'pipe', 'pipe'],
});

let stdoutBuffer = '';
let stderrBuffer = '';

child.stdout.on('data', (chunk) => {
  process.stdout.write(chunk);
  stdoutBuffer = processLines(stdoutBuffer + chunk.toString('utf8'));
});

child.stderr.on('data', (chunk) => {
  process.stderr.write(chunk);
  stderrBuffer = processLines(stderrBuffer + chunk.toString('utf8'));
});

child.on('exit', (code, signal) => {
  processLines(`${stdoutBuffer}\n`);
  processLines(`${stderrBuffer}\n`);
  writeCaptureManifest({ exitCode: code ?? 1, signal });
  if (signal) {
    process.kill(process.pid, signal);
    return;
  }
  process.exit(code ?? 1);
});

function processLines(buffer) {
  const lines = buffer.split(/\r?\n/);
  const partial = lines.pop() ?? '';
  for (const line of lines) {
    const match = line.match(/KORIDO_SCREENSHOT_MARKER::([A-Za-z0-9_.-]+)/);
    if (match) {
      captureScreenshot(match[1]);
    }
  }
  return partial;
}

function captureScreenshot(rawName) {
  const safeName = rawName.replace(/[^a-zA-Z0-9_.-]/g, '_');
  const outputPath = resolve(screenshotDir, `${safeName}.png`);
  const result = spawnSync(
    'xcrun',
    ['simctl', 'io', deviceId, 'screenshot', outputPath],
    {
      cwd: repoRoot,
      encoding: 'utf8',
    },
  );

  if (result.status !== 0) {
    console.error(
      `[visual-capture] failed ${safeName}: ${result.stderr || result.error}`,
    );
    return;
  }

  capturedScreenshots.push({
    name: rawName,
    file: `${safeName}.png`,
    dimensions: pngDimensions(outputPath),
    capturedAt: new Date().toISOString(),
  });
  console.error(`[visual-capture] captured ${safeName}`);
}

function writeCaptureManifest({ exitCode, signal }) {
  writeFileSync(
    manifestPath,
    `${JSON.stringify({
      captureType: 'ios-simulator-framebuffer',
      generator: 'scripts/capture_live_visual_sweep.mjs',
      source: 'xcrun simctl io screenshot',
      app: 'korido',
      deviceId,
      env,
      apiUrl,
      startedAt: captureStartedAt,
      finishedAt: new Date().toISOString(),
      exitCode,
      signal,
      screenCount: capturedScreenshots.length,
      screens: capturedScreenshots,
    }, null, 2)}\n`,
  );
}

function pngDimensions(filePath) {
  const buffer = readFileSync(filePath);
  if (buffer.length < 24 || buffer.toString('ascii', 1, 4) !== 'PNG') {
    return null;
  }

  return {
    width: buffer.readUInt32BE(16),
    height: buffer.readUInt32BE(20),
    bytes: buffer.length,
  };
}
