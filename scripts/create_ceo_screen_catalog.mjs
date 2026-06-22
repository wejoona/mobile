import fs from 'node:fs';
import crypto from 'node:crypto';
import path from 'node:path';
import zlib from 'node:zlib';

const projectRoot = path.resolve(new URL('..', import.meta.url).pathname);
const sourceDir = path.resolve(
  projectRoot,
  process.argv[2] ?? 'build/screenshots/korido_live_visual_sweep',
);
const outputDir = path.resolve(
  projectRoot,
  process.argv[3] ?? 'artifacts/ceo-screen-catalog-latest',
);
const canonicalLiveSourceDir = path.resolve(
  projectRoot,
  'build/screenshots/korido_live_visual_sweep',
);

if (
  sourceDir !== canonicalLiveSourceDir &&
  process.env.KORIDO_ALLOW_EXTERNAL_SCREEN_SOURCE !== 'true'
) {
  console.error(
    [
      `Refusing non-live screenshot source: ${sourceDir}`,
      `Expected live simulator source: ${canonicalLiveSourceDir}`,
      'Run `./scripts/codex_mobile.sh ceo-screen-catalog` to capture real app screens first.',
      'Set KORIDO_ALLOW_EXTERNAL_SCREEN_SOURCE=true only for an audited real screenshot directory.',
    ].join('\n'),
  );
  process.exit(65);
}

function walk(dir) {
  if (!fs.existsSync(dir)) return [];
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const filePath = path.join(dir, entry.name);
    if (entry.isDirectory()) return walk(filePath);
    return entry.name.endsWith('.png') ? [filePath] : [];
  });
}

function titleFromName(fileName) {
  return fileName
    .replace(/^\d+_?/, '')
    .replace(/\.png$/, '')
    .replaceAll('_', ' ')
    .replace(/\b\w/g, (char) => char.toUpperCase());
}

function sequenceFor(filePath) {
  const match = path.basename(filePath).match(/^(\d+)/);
  return match ? Number(match[1]) : Number.MAX_SAFE_INTEGER;
}

function sha256(filePath) {
  return crypto.createHash('sha256').update(fs.readFileSync(filePath)).digest('hex');
}

function pngDimensions(filePath) {
  const buffer = fs.readFileSync(filePath);
  if (buffer.length < 24 || buffer.toString('ascii', 1, 4) !== 'PNG') {
    return null;
  }

  return {
    width: buffer.readUInt32BE(16),
    height: buffer.readUInt32BE(20),
    bytes: buffer.length,
  };
}

function isNearBlankPng(filePath) {
  try {
    const buffer = fs.readFileSync(filePath);
    let offset = 8;
    let width = 0;
    let height = 0;
    let bitDepth = 0;
    let colorType = 0;
    const idat = [];

    while (offset < buffer.length) {
      const length = buffer.readUInt32BE(offset);
      const type = buffer.toString('ascii', offset + 4, offset + 8);
      const start = offset + 8;
      const end = start + length;
      if (type === 'IHDR') {
        width = buffer.readUInt32BE(start);
        height = buffer.readUInt32BE(start + 4);
        bitDepth = buffer[start + 8];
        colorType = buffer[start + 9];
      } else if (type === 'IDAT') {
        idat.push(buffer.subarray(start, end));
      } else if (type === 'IEND') {
        break;
      }
      offset = end + 4;
    }

    const channels = colorType === 6 ? 4 : colorType === 2 ? 3 : colorType === 0 ? 1 : 0;
    const sampleBytes = bitDepth === 16 ? 2 : bitDepth === 8 ? 1 : 0;
    if (!width || !height || sampleBytes === 0 || channels === 0) return false;

    const raw = zlib.inflateSync(Buffer.concat(idat));
    const bytesPerPixel = channels * sampleBytes;
    const stride = width * bytesPerPixel;
    let pos = 0;
    let previous = Buffer.alloc(stride);
    let visiblePixels = 0;
    let sampledPixels = 0;

    for (let y = 0; y < height; y++) {
      const filter = raw[pos++];
      const row = Buffer.from(raw.subarray(pos, pos + stride));
      pos += stride;

      for (let x = 0; x < stride; x++) {
        const left = x >= bytesPerPixel ? row[x - bytesPerPixel] : 0;
        const up = previous[x] ?? 0;
        const upLeft = x >= bytesPerPixel ? previous[x - bytesPerPixel] ?? 0 : 0;
        if (filter === 1) row[x] = (row[x] + left) & 0xff;
        if (filter === 2) row[x] = (row[x] + up) & 0xff;
        if (filter === 3) row[x] = (row[x] + Math.floor((left + up) / 2)) & 0xff;
        if (filter === 4) row[x] = (row[x] + paeth(left, up, upLeft)) & 0xff;
      }

      for (let x = 0; x < width; x += 4) {
        const i = x * bytesPerPixel;
        const r = row[i];
        const g = channels === 1 ? r : row[i + sampleBytes];
        const b = channels === 1 ? r : row[i + sampleBytes * 2];
        sampledPixels++;
        if (Math.max(r, g, b) > 42) visiblePixels++;
      }
      previous = row;
    }

    return visiblePixels / Math.max(sampledPixels, 1) < 0.01;
  } catch (_) {
    return false;
  }
}

function paeth(left, up, upLeft) {
  const p = left + up - upLeft;
  const pa = Math.abs(p - left);
  const pb = Math.abs(p - up);
  const pc = Math.abs(p - upLeft);
  if (pa <= pb && pa <= pc) return left;
  if (pb <= pc) return up;
  return upLeft;
}

const candidateScreenshots = walk(sourceDir)
  .filter((filePath) => {
    const name = path.basename(filePath).toLowerCase();
    return !name.includes('placeholder') &&
      !name.includes('visual-probe') &&
      !name.includes('auth_entry');
  });

const invalidScreenshots = candidateScreenshots
  .map((filePath) => ({
    filePath,
    dimensions: pngDimensions(filePath),
  }))
  .filter(({ dimensions }) =>
    !dimensions ||
    dimensions.bytes < 40_000 ||
    dimensions.width < 600 ||
    dimensions.height < 1000
  );

if (invalidScreenshots.length > 0) {
  console.error(
    [
      'Refusing to build catalog because some assets are not full simulator screenshots.',
      ...invalidScreenshots.slice(0, 12).map(({ filePath, dimensions }) => {
        const detail = dimensions
          ? `${dimensions.width}x${dimensions.height}, ${dimensions.bytes} bytes`
          : 'not a readable PNG';
        return `- ${path.relative(sourceDir, filePath)} (${detail})`;
      }),
      invalidScreenshots.length > 12
        ? `...and ${invalidScreenshots.length - 12} more`
        : '',
    ].filter(Boolean).join('\n'),
  );
  process.exit(67);
}

const hashCounts = new Map();
for (const filePath of candidateScreenshots) {
  const hash = sha256(filePath);
  hashCounts.set(hash, (hashCounts.get(hash) ?? 0) + 1);
}

const screenshots = candidateScreenshots
  .filter((filePath) => {
    const hash = sha256(filePath);
    const repeated = (hashCounts.get(hash) ?? 0) > 8;
    return !(repeated && isNearBlankPng(filePath));
  })
  .sort((a, b) => sequenceFor(a) - sequenceFor(b) || a.localeCompare(b));
if (screenshots.length === 0) {
  console.error(`No screenshots found in ${sourceDir}`);
  process.exit(66);
}

fs.rmSync(outputDir, { recursive: true, force: true });
fs.mkdirSync(path.join(outputDir, 'screens'), { recursive: true });

const copied = screenshots.map((filePath, index) => {
  const name = path.basename(filePath);
  const safeName = `${String(index + 1).padStart(3, '0')}_${name}`;
  const dest = path.join(outputDir, 'screens', safeName);
  const dimensions = pngDimensions(filePath);
  const displayScale = dimensions?.width && dimensions.width >= 900
    ? 3
    : dimensions?.width && dimensions.width >= 600
      ? 2
      : 1;
  const displayWidth = dimensions?.width
    ? Math.round(dimensions.width / displayScale)
    : 402;
  const displayHeight = dimensions?.height
    ? Math.round(dimensions.height / displayScale)
    : 874;
  fs.copyFileSync(filePath, dest);
  return {
    title: titleFromName(name),
    file: `screens/${safeName}`,
    source: path.relative(sourceDir, filePath),
    width: dimensions?.width,
    height: dimensions?.height,
    displayWidth,
    displayHeight,
    bytes: dimensions?.bytes,
    sha256: sha256(filePath),
  };
});

const cards = copied.map(({
  title,
  file,
  source,
  width,
  height,
  displayWidth,
  displayHeight,
}) => [
  '<article class="card">',
  `<a class="shotLink" href="${file}" target="_blank" rel="noopener" style="--shot-width:${displayWidth}px">`,
  `<img src="${file}" loading="lazy" alt="${title}" width="${displayWidth}" height="${displayHeight}">`,
  '</a>',
  '<div class="caption">',
  `<b>${title}</b>`,
  `<span>${width}x${height} raw simulator PNG</span>`,
  `<span>${source}</span>`,
  '</div>',
  '</article>',
].join('')).join('\n');

const html = [
  '<!doctype html>',
  '<html>',
  '<head>',
  '<meta charset="utf-8">',
  '<meta name="viewport" content="width=device-width,initial-scale=1">',
  '<title>Korido Screen Catalog</title>',
  '<style>',
  ':root{color-scheme:dark;--gold:#e2c266;--ink:#08080b;--surface:#14141a}',
  '*{box-sizing:border-box}',
  'body{margin:0;background:#08080b;color:#f7f3ea;font-family:-apple-system,BlinkMacSystemFont,Segoe UI,sans-serif}',
  'header{position:sticky;top:0;z-index:1;background:rgba(8,8,11,.94);backdrop-filter:blur(16px);padding:24px 32px;border-bottom:1px solid rgba(226,194,102,.22)}',
  'h1{margin:0;font-size:28px;letter-spacing:0}p{margin:8px 0 0;color:#b9b2a7;max-width:960px}.meta{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:12px;color:#8f887e}',
  '.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(min(100%,430px),430px));gap:32px;align-items:start;justify-content:center;padding:32px}',
  '.card{background:#14141a;border:1px solid rgba(226,194,102,.30);border-radius:18px;overflow:hidden;box-shadow:0 20px 60px rgba(0,0,0,.35)}',
  '.shotLink{display:block;width:min(100%,var(--shot-width));margin:0 auto;background:#050507;text-decoration:none}',
  '.shotLink img{width:100%;height:auto;display:block;background:#050507}',
  '.caption{display:grid;gap:5px;padding:14px 16px 16px;border-top:1px solid rgba(226,194,102,.18)}',
  '.caption b{text-transform:capitalize;font-size:15px}.caption span{font-size:12px;color:#a9a198;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}',
  '@media (max-width:520px){header{padding:20px}.grid{padding:18px;gap:24px;grid-template-columns:1fr}.card{border-radius:14px}}',
  '</style>',
  '</head>',
  '<body>',
  '<header>',
  '<h1>Korido Screen Catalog</h1>',
  `<p>${copied.length} direct simulator screenshots captured from the live API visual sweep. Images are displayed at phone logical size; click any screen to inspect the raw PNG.</p>`,
  `<p class="meta">Source: ${sourceDir}</p>`,
  '</header>',
  `<main class="grid">${cards}</main>`,
  '</body>',
  '</html>',
].join('\n');

fs.writeFileSync(path.join(outputDir, 'index.html'), html);
fs.writeFileSync(
  path.join(outputDir, 'README.txt'),
  [
    'Korido Screen Catalog',
    `Source: ${sourceDir}`,
    `Screens: ${copied.length}`,
    'Capture type: live simulator framebuffer screenshots',
    'Open index.html to browse the real app screenshots.',
    '',
  ].join('\n'),
);
fs.writeFileSync(
  path.join(outputDir, 'manifest.json'),
  `${JSON.stringify({
    generatedAt: new Date().toISOString(),
    sourceDir,
    captureType: 'live simulator framebuffer screenshots',
    screenCount: copied.length,
    screens: copied,
  }, null, 2)}\n`,
);

console.log(`Created ${copied.length}-screen catalog at ${outputDir}`);
