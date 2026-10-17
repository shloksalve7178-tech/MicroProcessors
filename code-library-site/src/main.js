import './style.css';

const treeEl = document.querySelector('#file-tree');
const searchEl = document.querySelector('#search');
const countEl = document.querySelector('#file-count');
const welcomeEl = document.querySelector('#welcome');
const panelEl = document.querySelector('#code-panel');
const emptyEl = document.querySelector('#empty-state');
const breadcrumbsEl = document.querySelector('#breadcrumbs');
const activeFileEl = document.querySelector('#active-file');
const languageChipEl = document.querySelector('#language-chip');
const copyButton = document.querySelector('#copy-button');
const codeMetaEl = document.querySelector('#code-meta');
const codeScrollEl = document.querySelector('#code-scroll');
const lineNumbersEl = document.querySelector('#line-numbers');
const codeContentEl = document.querySelector('#code-content');
const footerFileEl = document.querySelector('#footer-file');
const toastEl = document.querySelector('#toast');

let allFiles = [];
let activePath = null;
let activeText = '';
let toastTimer;

const languageNames = {
  '.asm': '8086 ASM', '.s': 'ASSEMBLY', '.c': 'C', '.h': 'C HEADER', '.cc': 'C++', '.cpp': 'C++', '.hpp': 'C++', '.cxx': 'C++',
  '.cs': 'C#', '.java': 'JAVA', '.py': 'PYTHON', '.pyw': 'PYTHON', '.js': 'JAVASCRIPT', '.jsx': 'JSX', '.mjs': 'JAVASCRIPT', '.cjs': 'JAVASCRIPT',
  '.ts': 'TYPESCRIPT', '.tsx': 'TSX', '.html': 'HTML', '.htm': 'HTML', '.css': 'CSS', '.scss': 'SCSS', '.sass': 'SASS', '.less': 'LESS',
  '.json': 'JSON', '.xml': 'XML', '.yaml': 'YAML', '.yml': 'YAML', '.toml': 'TOML', '.md': 'MARKDOWN', '.txt': 'TEXT', '.sql': 'SQL',
  '.sh': 'SHELL', '.bash': 'SHELL', '.bat': 'BATCH', '.cmd': 'BATCH', '.ps1': 'POWERSHELL', '.go': 'GO', '.rs': 'RUST', '.php': 'PHP', '.rb': 'RUBY',
  '.pl': 'PERL', '.r': 'R', '.m': 'OBJECTIVE-C / MATLAB', '.mm': 'OBJECTIVE-C++', '.swift': 'SWIFT', '.kt': 'KOTLIN', '.kts': 'KOTLIN', '.dart': 'DART',
  '.lua': 'LUA', '.ex': 'ELIXIR', '.exs': 'ELIXIR', '.erl': 'ERLANG', '.hs': 'HASKELL', '.lhs': 'HASKELL', '.scala': 'SCALA', '.sc': 'SCALA',
  '.clj': 'CLOJURE', '.cljs': 'CLOJURESCRIPT', '.cljc': 'CLOJURE', '.edn': 'EDN', '.fs': 'F#', '.fsx': 'F#', '.vb': 'VISUAL BASIC', '.vbs': 'VBScript',
  '.pas': 'PASCAL', '.pp': 'PASCAL', '.bas': 'BASIC', '.ino': 'ARDUINO', '.vue': 'VUE', '.svelte': 'SVELTE', '.graphql': 'GRAPHQL', '.gql': 'GRAPHQL', '.ipynb': 'JUPYTER'
};

function extOf(filename) {
  const match = filename.toLowerCase().match(/(\.[^.]+)$/);
  return match ? match[1] : '';
}
function langOf(file) {
  const lower = file.name.toLowerCase();
  if (lower === 'makefile') return 'MAKEFILE';
  if (lower === 'dockerfile') return 'DOCKERFILE';
  return languageNames[extOf(file.name)] || 'TEXT';
}
function formatSize(bytes) {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(2)} MB`;
}
function encodeFilePath(filePath) {
  return filePath.split('/').map(encodeURIComponent).join('/');
}
function showToast(message) {
  toastEl.textContent = message;
  toastEl.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toastEl.classList.remove('show'), 2100);
}

function groupFiles(files) {
  const root = { folders: new Map(), files: [] };
  for (const file of files) {
    const parts = file.path.split('/');
    let node = root;
    for (const part of parts.slice(0, -1)) {
      if (!node.folders.has(part)) node.folders.set(part, { folders: new Map(), files: [] });
      node = node.folders.get(part);
    }
    node.files.push(file);
  }
  return root;
}
function renderTree(files) {
  treeEl.replaceChildren();
  if (!files.length) {
    const noFiles = document.createElement('div');
    noFiles.className = 'tree-empty';
    noFiles.textContent = searchEl.value ? 'No matching files.' : 'No code files found yet. Add your files to public/code.';
    treeEl.append(noFiles);
    return;
  }
  const tree = groupFiles(files);
  const ul = document.createElement('div');
  ul.className = 'tree-root';
  renderNode(tree, ul, '', true);
  treeEl.append(ul);
}
function renderNode(node, parent, prefix, isRoot = false) {
  const dirs = [...node.folders.keys()].sort((a, b) => a.localeCompare(b, undefined, { numeric: true, sensitivity: 'base' }));
  for (const dir of dirs) {
    const fullPath = prefix ? `${prefix}/${dir}` : dir;
    const details = document.createElement('details');
    details.className = 'folder-node';
    details.open = Boolean(searchEl.value.trim());
    const summary = document.createElement('summary');
    summary.className = 'folder-label';
    summary.innerHTML = '<span class="chevron">›</span><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3.5 6.5h6l2 2H20a1.5 1.5 0 0 1 1.5 1.5v7A1.5 1.5 0 0 1 20 18.5H4A1.5 1.5 0 0 1 2.5 17V8A1.5 1.5 0 0 1 4 6.5Z"></path></svg>';
    const name = document.createElement('span');
    name.className = 'tree-name';
    name.textContent = dir;
    summary.append(name);
    details.append(summary);
    const inside = document.createElement('div');
    inside.className = 'tree-children';
    renderNode(node.folders.get(dir), inside, fullPath);
    details.append(inside);
    parent.append(details);
  }
  const sortedFiles = [...node.files].sort((a, b) => a.name.localeCompare(b.name, undefined, { numeric: true, sensitivity: 'base' }));
  for (const file of sortedFiles) {
    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'file-link' + (file.path === activePath ? ' active' : '');
    button.title = file.path;
    const icon = document.createElement('span');
    icon.className = 'file-ext ext-' + extOf(file.name).replace('.', '').replace(/[^a-z0-9-]/g, '');
    icon.textContent = extOf(file.name).replace('.', '').slice(0, 3).toUpperCase() || 'TXT';
    const name = document.createElement('span');
    name.className = 'tree-name';
    name.textContent = file.name;
    button.append(icon, name);
    button.addEventListener('click', () => openFile(file));
    parent.append(button);
  }
}

async function openFile(file) {
  activePath = file.path;
  try {
    const response = await fetch(`/code/${encodeFilePath(file.path)}`);
    if (!response.ok) throw new Error(`Could not load this file (${response.status}).`);
    activeText = await response.text();
    welcomeEl.classList.add('hidden');
    emptyEl.classList.add('hidden');
    panelEl.classList.remove('hidden');
    activeFileEl.textContent = file.name;
    activeFileEl.title = file.path;
    breadcrumbsEl.replaceChildren();
    const folderParts = file.path.split('/').slice(0, -1);
    if (folderParts.length === 0) {
      const crumb = document.createElement('span');
      crumb.textContent = 'CODE LIBRARY';
      breadcrumbsEl.append(crumb);
    } else {
      folderParts.forEach((part, index) => {
        if (index > 0) {
          const separator = document.createElement('span');
          separator.className = 'crumb-separator';
          separator.textContent = '/';
          breadcrumbsEl.append(separator);
        }
        const crumb = document.createElement('span');
        crumb.textContent = part;
        breadcrumbsEl.append(crumb);
      });
    }
    languageChipEl.textContent = langOf(file);
    const lines = activeText.split('\n');
    if (lines.length > 1 && lines[lines.length - 1] === '') lines.pop();
    lineNumbersEl.textContent = lines.map((_, index) => index + 1).join('\n');
    codeContentEl.textContent = activeText;
    codeMetaEl.textContent = `${formatSize(new Blob([activeText]).size)}  ·  ${lines.length.toLocaleString()} line${lines.length === 1 ? '' : 's'}`;
    footerFileEl.textContent = file.path;
    copyButton.disabled = false;
    renderTree(getFilteredFiles());
    codeScrollEl.scrollTop = 0;
    codeScrollEl.scrollLeft = 0;
    lineNumbersEl.scrollTop = 0;
  } catch (error) {
    showToast(error.message || 'Could not open that file.');
  }
}

function getFilteredFiles() {
  const query = searchEl.value.trim().toLowerCase();
  if (!query) return allFiles;
  return allFiles.filter(file => file.path.toLowerCase().includes(query));
}
function updateFilter() {
  const filtered = getFilteredFiles();
  countEl.textContent = searchEl.value.trim() ? `${filtered.length} / ${allFiles.length}` : `${allFiles.length} files`;
  renderTree(filtered);
  if (!filtered.length) {
    welcomeEl.classList.add('hidden');
    panelEl.classList.add('hidden');
    emptyEl.classList.remove('hidden');
  } else if (activePath && !filtered.some(file => file.path === activePath)) {
    welcomeEl.classList.add('hidden');
    panelEl.classList.add('hidden');
    emptyEl.classList.remove('hidden');
  } else if (!activePath && !searchEl.value.trim()) {
    emptyEl.classList.add('hidden');
    welcomeEl.classList.remove('hidden');
  } else if (!activePath && searchEl.value.trim()) {
    welcomeEl.classList.add('hidden');
    emptyEl.classList.add('hidden');
  } else {
    emptyEl.classList.add('hidden');
  }
}

searchEl.addEventListener('input', updateFilter);
searchEl.addEventListener('keydown', event => {
  if (event.key === 'Escape') {
    searchEl.value = '';
    updateFilter();
    searchEl.blur();
  }
});
document.addEventListener('keydown', event => {
  if (event.key === '/' && !['INPUT', 'TEXTAREA'].includes(document.activeElement?.tagName)) {
    event.preventDefault();
    searchEl.focus();
  }
});
copyButton.addEventListener('click', async () => {
  if (activePath === null) return;
  try {
    await navigator.clipboard.writeText(activeText);
    copyButton.classList.add('copied');
    copyButton.querySelector('span').textContent = 'Copied!';
    showToast('Code copied to clipboard');
    setTimeout(() => {
      copyButton.classList.remove('copied');
      copyButton.querySelector('span').textContent = 'Copy code';
    }, 1500);
  } catch {
    showToast('Clipboard access was blocked by your browser.');
  }
});
codeScrollEl.addEventListener('scroll', () => { lineNumbersEl.scrollTop = codeScrollEl.scrollTop; });

async function init() {
  try {
    const response = await fetch('/files.json');
    if (!response.ok) throw new Error('Could not read the file index. Try redeploying the site.');
    allFiles = await response.json();
    countEl.textContent = `${allFiles.length} files`;
    updateFilter();
    if (allFiles.length === 0) {
      treeEl.innerHTML = '<div class="tree-empty">No code files found yet.<br><br>Add your files to <code>public/code</code>, then deploy again.</div>';
    }
  } catch (error) {
    countEl.textContent = 'Unavailable';
    treeEl.textContent = error.message || 'Could not load files.';
  }
}

init();
