import { readdir, writeFile, stat } from 'node:fs/promises';
import path from 'node:path';

const root = path.resolve('public/code');
const output = path.resolve('public/files.json');

// Only include source/text-like files; ignore hidden paths and common secrets.
const allowedExtensions = new Set([
  '.asm', '.s', '.c', '.h', '.cc', '.cpp', '.hpp', '.cxx', '.cs', '.java',
  '.py', '.pyw', '.js', '.jsx', '.mjs', '.cjs', '.ts', '.tsx', '.html', '.htm',
  '.css', '.scss', '.sass', '.less', '.json', '.xml', '.yaml', '.yml', '.toml',
  '.md', '.txt', '.sql', '.sh', '.bash', '.bat', '.cmd', '.ps1', '.go', '.rs',
  '.php', '.rb', '.pl', '.r', '.m', '.mm', '.swift', '.kt', '.kts', '.dart',
  '.lua', '.ex', '.exs', '.erl', '.hrl', '.hs', '.lhs', '.scala', '.sc', '.clj',
  '.cljs', '.cljc', '.edn', '.fs', '.fsx', '.vb', '.vbs', '.pas', '.pp', '.bas',
  '.ino', '.vue', '.svelte', '.graphql', '.gql', '.ipynb', '.makefile', '.dockerfile'
]);
const blockedNames = new Set([
  '.env', '.env.local', '.env.production', 'id_rsa', 'id_ed25519',
  'credentials', 'secrets.json', 'service-account.json'
]);
const blockedExtensions = new Set(['.pem', '.key', '.p12', '.pfx', '.crt', '.cer', '.der', '.jks']);

async function walk(folder, relative = '') {
  let entries;
  try {
    entries = await readdir(folder, { withFileTypes: true });
  } catch (error) {
    if (error.code === 'ENOENT') return [];
    throw error;
  }
  entries.sort((a, b) => a.name.localeCompare(b.name, undefined, { numeric: true, sensitivity: 'base' }));
  const result = [];
  for (const entry of entries) {
    if (entry.name.startsWith('.') || entry.name === 'node_modules' || entry.name === '__pycache__') continue;
    const absolute = path.join(folder, entry.name);
    const rel = path.posix.join(relative, entry.name);
    if (entry.isDirectory()) {
      result.push(...await walk(absolute, rel));
      continue;
    }
    if (!entry.isFile()) continue;
    const lower = entry.name.toLowerCase();
    if (lower === 'add_your_code_files_here.txt') continue;
    const ext = path.extname(lower);
    if (blockedNames.has(lower) || blockedExtensions.has(ext)) continue;
    const noExtensionName = lower === 'makefile' || lower === 'dockerfile';
    if (!allowedExtensions.has(ext) && !noExtensionName) continue;
    const info = await stat(absolute);
    result.push({ path: rel, name: entry.name, size: info.size });
  }
  return result;
}

const files = await walk(root);
await writeFile(output, JSON.stringify(files, null, 2) + '\n', 'utf8');
console.log(`Indexed ${files.length} code/text file(s) into public/files.json`);
