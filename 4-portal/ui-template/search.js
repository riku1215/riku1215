/* Captain Portal search.js — 統合検索 + Cytoscape graph
 *
 * ~/Portal/indexes/*.json を fetch して
 *   - fuzzy search (タイトル / ハッシュタグ / ファイル名)
 *   - visibility フィルタ
 *   - ハッシュタグ cloud
 *   - Skills / Rules / Issues タブ
 *   - Cytoscape.js force-graph
 * を提供。
 *
 * No external framework (vanilla JS)、Cytoscape のみ CDN。
 */

const INDEX_BASE = './indexes';
const state = {
  files: [], hashtags: [], skills: [], rules: [], issues: [], graph: null,
  cy: null, currentTab: 'results', query: '', visibility: 'all',
};

// === Fuzzy match (シンプル subseq + score) ===
function fuzzyScore(query, text) {
  if (!query) return 0.001;
  const q = query.toLowerCase();
  const t = (text || '').toLowerCase();
  if (t.includes(q)) return 100 + (1 - t.indexOf(q) / Math.max(t.length, 1)) * 50;
  // 部分一致なし → subseq
  let qi = 0;
  for (let ti = 0; ti < t.length && qi < q.length; ti++) {
    if (t[ti] === q[qi]) qi++;
  }
  return qi === q.length ? qi / t.length * 50 : 0;
}

function escapeHtml(s) {
  return (s || '').replace(/[&<>"']/g, c =>
    ({ '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;' }[c]));
}

function highlight(text, query) {
  if (!query) return escapeHtml(text);
  const safe = escapeHtml(text);
  const q = query.toLowerCase();
  const lower = safe.toLowerCase();
  const idx = lower.indexOf(q);
  if (idx < 0) return safe;
  return safe.slice(0, idx) + '<mark>' + safe.slice(idx, idx + q.length) + '</mark>' + safe.slice(idx + q.length);
}

// === Index loading ===
async function loadIndex(name) {
  try {
    const res = await fetch(`${INDEX_BASE}/${name}.json`);
    if (!res.ok) throw new Error(`${name}: ${res.status}`);
    return await res.json();
  } catch (e) {
    console.warn(`Failed to load ${name}:`, e);
    return [];
  }
}

async function loadAll() {
  setStatus('インデックス読込中…');
  const [files, hashtags, skills, rules, issues, graph] = await Promise.all([
    loadIndex('files'),
    loadIndex('hashtags'),
    loadIndex('skills'),
    loadIndex('rules'),
    loadIndex('issues'),
    loadIndex('graph'),
  ]);
  state.files = Array.isArray(files) ? files : [];
  state.hashtags = Array.isArray(hashtags) ? hashtags : [];
  state.skills = Array.isArray(skills) ? skills : [];
  state.rules = Array.isArray(rules) ? rules : [];
  state.issues = Array.isArray(issues) ? issues : [];
  state.graph = graph && graph.nodes ? graph : { nodes: [], edges: [] };
  setStatus(`✓ ${state.files.length} files / ${state.hashtags.length} tags / ${state.skills.length} skills / ${state.rules.length} rules / ${state.issues.length} issues`);
}

function setStatus(msg) {
  const el = document.getElementById('status');
  if (el) el.textContent = msg;
}

// === Filtering ===
function visibilityMatch(file) {
  if (state.visibility === 'all') return true;
  return (file.visibility || 'local-only') === state.visibility;
}

// === Render: results tab ===
function renderResults() {
  const list = document.getElementById('results-list');
  const q = state.query.trim();
  let items;
  if (!q) {
    items = state.files.filter(visibilityMatch)
      .sort((a, b) => (b.mtime || '').localeCompare(a.mtime || ''))
      .slice(0, 100);
  } else {
    items = state.files.filter(visibilityMatch).map(f => {
      const titleScore = fuzzyScore(q, f.title);
      const pathScore = fuzzyScore(q, f.path) * 0.5;
      const tagScore = (f.tags || []).reduce((s, t) => Math.max(s, fuzzyScore(q, t)), 0) * 0.7;
      return { f, score: Math.max(titleScore, pathScore, tagScore) };
    }).filter(x => x.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, 100)
      .map(x => x.f);
  }
  list.innerHTML = items.map(f => fileRow(f, q)).join('') ||
    '<div class="hint">該当なし</div>';
}

function fileRow(f, q) {
  const tags = (f.tags || []).slice(0, 6).map(t =>
    `<span class="badge tag">#${escapeHtml(t)}</span>`).join('');
  const vis = `<span class="badge ${f.visibility || 'local-only'}">${f.visibility || 'local-only'}</span>`;
  const status = f.status ? `<span class="badge ${f.status}">${f.status}</span>` : '';
  return `<div class="list-item" onclick="openFile('${escapeHtml(f.path)}')">
    <div class="item-title">${highlight(f.title, q)}</div>
    <div class="item-meta">${vis} ${status}<span>${escapeHtml(f.path)}</span><span>${escapeHtml(f.mtime || '')}</span></div>
    ${tags ? `<div class="item-tags">${tags}</div>` : ''}
  </div>`;
}

window.openFile = function(path) {
  // path は ~/... 形式。Captain Windows では file:/// パスへ変換するヒントを status に表示
  setStatus(`📂 ${path} — エクスプローラで開く: ${path.replace('~', 'C:\\Users\\m').replace(/\//g, '\\')}`);
};

// === Render: hashtags tab ===
function renderHashtags() {
  const el = document.getElementById('hashtags-list');
  const max = Math.max(...state.hashtags.map(t => t.count || 1), 1);
  el.innerHTML = state.hashtags.map(t => {
    const size = 11 + (t.count / max) * 8;
    return `<span class="tag" style="font-size:${size}px" onclick="filterByTag('${escapeHtml(t.tag)}')">#${escapeHtml(t.tag)}<span class="count">${t.count}</span></span>`;
  }).join('');
}

window.filterByTag = function(tag) {
  state.query = tag;
  document.getElementById('search').value = tag;
  switchTab('results');
  renderResults();
};

// === Render: skills tab ===
function renderSkills() {
  const el = document.getElementById('skills-list');
  el.innerHTML = state.skills.map(s => `<div class="card">
    <div class="card-title">${escapeHtml(s.name)}</div>
    <div class="card-desc">${escapeHtml(s.description || '(no description)')}</div>
    <div class="item-tags">${(s.tags || []).map(t => `<span class="badge tag">#${escapeHtml(t)}</span>`).join('')}</div>
  </div>`).join('') || '<div class="hint">~/.agents/skills/ にスキル未配置</div>';
}

// === Render: rules tab ===
function renderRules() {
  const el = document.getElementById('rules-list');
  el.innerHTML = state.rules.map(r => `<div class="list-item">
    <div class="item-title"><span class="badge tag">${escapeHtml(r.id)}</span> ${escapeHtml(r.title)}</div>
    <div class="item-meta"><span>${escapeHtml(r.source || '')}</span></div>
  </div>`).join('') || '<div class="hint">PROFILE.md から R-rules を抽出できませんでした</div>';
}

// === Render: issues tab ===
function renderIssues() {
  const el = document.getElementById('issues-list');
  el.innerHTML = state.issues.map(i => {
    const labels = (i.labels || []).map(l => `<span class="badge tag">${escapeHtml(l)}</span>`).join('');
    return `<div class="list-item" onclick="window.open('${escapeHtml(i.url)}','_blank')">
      <div class="item-title">#${i.number} ${escapeHtml(i.title)}</div>
      <div class="item-meta"><span>${escapeHtml(i.repo)}</span><span>${escapeHtml(i.updated || '')}</span></div>
      ${labels ? `<div class="item-tags">${labels}</div>` : ''}
    </div>`;
  }).join('') || '<div class="hint">~/.kb/issues/ から Issue を取得できませんでした</div>';
}

// === Render: graph tab (Cytoscape) ===
function renderGraph() {
  if (!state.graph || !state.graph.nodes) return;
  const elements = [
    ...state.graph.nodes.map(n => ({ data: n.data, classes: n.data.type })),
    ...state.graph.edges.map(e => ({ data: e.data })),
  ];
  if (state.cy) state.cy.destroy();
  state.cy = cytoscape({
    container: document.getElementById('cy'),
    elements,
    style: [
      { selector: 'node', style: {
        'label': 'data(label)', 'font-size': 9, 'color': '#e8e8ec',
        'background-color': '#3B82F6', 'width': 14, 'height': 14,
        'text-outline-color': '#0a0a0f', 'text-outline-width': 1,
      }},
      { selector: 'node.tag', style: {
        'background-color': '#8B5CF6', 'shape': 'round-rectangle',
        'width': 'mapData(weight, 1, 50, 16, 60)',
        'height': 'mapData(weight, 1, 50, 10, 30)',
        'font-size': 11,
      }},
      { selector: 'node.file', style: {
        'background-color': '#10B981', 'shape': 'ellipse',
      }},
      { selector: 'edge', style: {
        'width': 0.7, 'line-color': '#2a2a35', 'curve-style': 'bezier', 'opacity': 0.55,
      }},
      { selector: 'node:selected', style: {
        'border-width': 2, 'border-color': '#F59E0B',
      }},
    ],
    layout: { name: 'cose', animate: false, nodeRepulsion: 5000, idealEdgeLength: 60, nodeOverlap: 8 },
    minZoom: 0.2, maxZoom: 3,
  });
  state.cy.on('tap', 'node', evt => {
    const d = evt.target.data();
    const detail = document.getElementById('graph-detail');
    if (d.type === 'file') {
      detail.innerHTML = `<b>📄 ${escapeHtml(d.label)}</b><br><span class="badge ${d.visibility}">${d.visibility || ''}</span> <code>${escapeHtml(d.path)}</code>`;
    } else if (d.type === 'tag') {
      detail.innerHTML = `<b>🏷 #${escapeHtml(d.label.replace(/^#/, ''))}</b> — weight ${d.weight}`;
    }
  });
}

// === Tab switching ===
function switchTab(name) {
  state.currentTab = name;
  document.querySelectorAll('.tab').forEach(b => b.classList.toggle('active', b.dataset.tab === name));
  document.querySelectorAll('.tab-pane').forEach(p => p.classList.toggle('active', p.id === `tab-${name}`));
  if (name === 'graph' && state.cy === null) renderGraph();
}

// === Event wiring ===
document.addEventListener('DOMContentLoaded', async () => {
  document.querySelectorAll('.tab').forEach(b => {
    b.addEventListener('click', () => switchTab(b.dataset.tab));
  });
  document.getElementById('search').addEventListener('input', e => {
    state.query = e.target.value;
    if (state.currentTab === 'results') renderResults();
  });
  document.getElementById('vis-filter').addEventListener('change', e => {
    state.visibility = e.target.value;
    renderResults();
  });

  await loadAll();
  renderResults();
  renderHashtags();
  renderSkills();
  renderRules();
  renderIssues();
});
