/* Captain Portal app.js — GitHub IA 再現 SPA (hash routing)
 *
 * Routes:
 *   #/             → /code にリダイレクト
 *   #/code         → File tree + viewer
 *   #/issues       → Issue list
 *   #/issues/:n    → Issue detail
 *   #/pulls        → PR list
 *   #/actions      → Portal action buttons
 *   #/knowledge    → Hashtags + 検索 (ChromaDB)
 *   #/skills       → 47 skills
 *   #/rules        → R-rules + Section 7
 *   #/insights     → Cytoscape graph
 *   #/help         → Help
 */

const INDEX_BASE = './indexes';
const state = {
  files: [], hashtags: [], skills: [], rules: [], issues: [], prs: [], graph: null,
  cy: null, query: '', visibility: 'all', currentRoute: 'code', openedFile: null,
};

// === Utils ===
function escapeHtml(s) {
  return (s || '').replace(/[&<>"']/g, c =>
    ({ '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;' }[c]));
}
function highlight(text, query) {
  if (!query) return escapeHtml(text);
  const safe = escapeHtml(text);
  const idx = safe.toLowerCase().indexOf(query.toLowerCase());
  if (idx < 0) return safe;
  return safe.slice(0, idx) + '<mark>' + safe.slice(idx, idx + query.length) + '</mark>' + safe.slice(idx + query.length);
}
function fuzzyScore(query, text) {
  if (!query) return 0.001;
  const q = query.toLowerCase();
  const t = (text || '').toLowerCase();
  if (t.includes(q)) return 100 + (1 - t.indexOf(q) / Math.max(t.length, 1)) * 50;
  let qi = 0;
  for (let ti = 0; ti < t.length && qi < q.length; ti++) {
    if (t[ti] === q[qi]) qi++;
  }
  return qi === q.length ? qi / t.length * 50 : 0;
}
function timeAgo(iso) {
  if (!iso) return '';
  const d = new Date(iso); if (isNaN(d)) return iso;
  const diff = (Date.now() - d.getTime()) / 1000;
  if (diff < 60) return 'just now';
  if (diff < 3600) return `${Math.floor(diff/60)}m ago`;
  if (diff < 86400) return `${Math.floor(diff/3600)}h ago`;
  if (diff < 30*86400) return `${Math.floor(diff/86400)}d ago`;
  return d.toISOString().slice(0,10);
}
function setStatus(msg) {
  const el = document.getElementById('status');
  if (el) el.textContent = msg;
}

// === Index loading ===
async function loadIndex(name) {
  try {
    const res = await fetch(`${INDEX_BASE}/${name}.json`);
    if (!res.ok) throw new Error(`${name}: ${res.status}`);
    return await res.json();
  } catch (e) { return []; }
}
async function loadAll() {
  setStatus('インデックス読込中…');
  const [files, hashtags, skills, rules, issues, prs, graph] = await Promise.all([
    loadIndex('files'), loadIndex('hashtags'), loadIndex('skills'),
    loadIndex('rules'), loadIndex('issues'), loadIndex('prs'), loadIndex('graph'),
  ]);
  state.files = Array.isArray(files) ? files : [];
  state.hashtags = Array.isArray(hashtags) ? hashtags : [];
  state.skills = Array.isArray(skills) ? skills : [];
  state.rules = Array.isArray(rules) ? rules : [];
  state.issues = Array.isArray(issues) ? issues : [];
  state.prs = Array.isArray(prs) ? prs : [];
  state.graph = graph && graph.nodes ? graph : { nodes: [], edges: [] };
  setStatus(`✓ ${state.files.length} files · ${state.hashtags.length} tags · ${state.skills.length} skills · ${state.rules.length} rules · ${state.issues.length} issues · ${state.prs.length} PRs`);
  // tab counters
  const setCnt = (id, n) => { const el = document.getElementById(id); if (el) el.textContent = n; };
  setCnt('cnt-issues', state.issues.length);
  setCnt('cnt-pulls', state.prs.length);
  setCnt('cnt-skills', state.skills.length);
  setCnt('cnt-rules', state.rules.length);
  setCnt('cnt-knowledge', state.hashtags.length);
}

// === Visibility filter ===
function visMatch(file) {
  if (state.visibility === 'all') return true;
  return (file.visibility || 'local-only') === state.visibility;
}

// === Routing ===
function parseRoute() {
  const h = location.hash.replace(/^#\//, '').replace(/^#/, '');
  if (!h) return { route: 'code' };
  const parts = h.split('/');
  return { route: parts[0], param: parts[1] };
}
function go(path) { location.hash = '#/' + path; }

function setActiveTab(route) {
  document.querySelectorAll('.gh-tab').forEach(t => {
    t.classList.toggle('active', t.dataset.route === route);
  });
}

function render() {
  const { route, param } = parseRoute();
  state.currentRoute = route;
  setActiveTab(route);
  const main = document.getElementById('main');
  switch (route) {
    case 'code':       renderCode(main); break;
    case 'issues':     param ? renderIssueDetail(main, param) : renderIssues(main); break;
    case 'pulls':      renderPulls(main); break;
    case 'actions':    renderActions(main); break;
    case 'knowledge':  renderKnowledge(main); break;
    case 'skills':     renderSkills(main); break;
    case 'rules':      renderRules(main); break;
    case 'insights':   renderInsights(main); break;
    case 'help':       renderHelp(main); break;
    default:           renderCode(main);
  }
}

// ============================================
// Code tab: file tree + viewer
// ============================================
function buildTree(files) {
  const root = {};
  for (const f of files) {
    const parts = f.path.split('/');
    let cur = root;
    for (let i = 0; i < parts.length; i++) {
      const part = parts[i];
      if (i === parts.length - 1) {
        cur[part] = { __file: f };
      } else {
        cur[part] = cur[part] || {};
        cur = cur[part];
      }
    }
  }
  return root;
}
function renderTree(node, basePath = '') {
  const entries = Object.entries(node).sort(([a, av], [b, bv]) => {
    const ad = !av.__file, bd = !bv.__file;
    if (ad !== bd) return ad ? -1 : 1;
    return a.localeCompare(b);
  });
  return entries.map(([name, val]) => {
    if (val.__file) {
      const f = val.__file;
      return `<div class="tree-node file" onclick="openFileInViewer('${escapeHtml(f.path)}')">
        <span class="tree-icon">📄</span>
        <span>${escapeHtml(name)}</span>
      </div>`;
    } else {
      const childId = 'tree-' + Math.random().toString(36).slice(2, 9);
      return `<details>
        <summary class="tree-node dir"><span class="tree-icon">📁</span> ${escapeHtml(name)}</summary>
        <div class="tree-children">${renderTree(val, basePath + name + '/')}</div>
      </details>`;
    }
  }).join('');
}
function renderCode(main) {
  const filtered = state.files.filter(visMatch);
  const tree = buildTree(filtered);
  main.innerHTML = `<div class="page-header">
    <h1 class="page-title">Code</h1>
    <span class="badge">${filtered.length} files</span>
  </div>
  <div class="code-layout">
    <div class="file-tree">${renderTree(tree)}</div>
    <div class="file-viewer" id="file-viewer">
      <div class="file-viewer-empty">← 左のツリーからファイルを選択</div>
    </div>
  </div>`;
}
window.openFileInViewer = function(path) {
  const f = state.files.find(x => x.path === path);
  if (!f) return;
  state.openedFile = f;
  const viewer = document.getElementById('file-viewer');
  // path normalize: ~/foo → /home/user/foo or C:\Users\m\foo
  // 実コンテンツは fetch できないので metadata + ヒント表示
  viewer.innerHTML = `<h2 style="margin-top:0">${escapeHtml(f.title)}</h2>
    <div class="detail-meta" style="margin-bottom:16px">
      <code>${escapeHtml(f.path)}</code> · ${timeAgo(f.mtime)} · <span class="badge ${f.visibility}">${f.visibility}</span>
    </div>
    <div class="detail-body">
      <p style="color:var(--fg-muted)">md 内容は portal-api 経由で取得 (port 8765 起動時)。<br>
      または下記コマンドで開く:</p>
      <pre>${escapeHtml('start "" "' + f.path.replace('~', 'C:\\Users\\m').replace(/\//g,'\\') + '"')}</pre>
      <p>タグ: ${(f.tags||[]).map(t => `<a class="badge tag" href="#/knowledge?tag=${encodeURIComponent(t)}">#${escapeHtml(t)}</a>`).join(' ')}</p>
    </div>`;
};

// ============================================
// Issues tab
// ============================================
function renderIssues(main) {
  const q = state.query.trim();
  const filtered = state.issues.filter(i => !q ||
    fuzzyScore(q, i.title) > 0 ||
    fuzzyScore(q, i.repo) > 0 ||
    (i.labels||[]).some(l => fuzzyScore(q, l) > 0)
  );
  main.innerHTML = `<div class="filter-bar">
      <div class="filter-state">
        <a href="#/issues" class="active">⊙ Open <span class="gh-counter">${filtered.length}</span></a>
      </div>
      <div class="filter-spacer"></div>
      <select><option>Author ▼</option></select>
      <select><option>Label ▼</option></select>
      <select><option>Repo ▼</option></select>
      <select><option>Sort: Newest ▼</option></select>
    </div>
    <div class="list">
      ${filtered.map(i => issueRow(i, q)).join('') || '<div style="padding:32px;text-align:center;color:var(--fg-muted)">該当 Issue なし</div>'}
    </div>`;
}
function issueRow(i, q) {
  const labels = (i.labels || []).map(l => `<span class="badge tag">${escapeHtml(l)}</span>`).join('');
  return `<div class="list-item" onclick="go('issues/${i.number}-${encodeURIComponent(i.repo)}')">
    <span class="item-icon">
      <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M8 9.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3Z"/><path d="M8 0a8 8 0 1 1 0 16A8 8 0 0 1 8 0ZM1.5 8a6.5 6.5 0 1 0 13 0 6.5 6.5 0 0 0-13 0Z"/></svg>
    </span>
    <div class="item-body">
      <a class="item-title" onclick="event.stopPropagation();window.open('${escapeHtml(i.url)}','_blank')">${highlight(i.title, q)}</a>
      <span class="item-number">#${i.number}</span>
      ${labels ? `<span class="item-tags">${labels}</span>` : ''}
      <div class="item-meta">
        <span>${escapeHtml(i.repo)}</span>
        <span>updated ${timeAgo(i.updated)}</span>
      </div>
    </div>
  </div>`;
}
function renderIssueDetail(main, idParam) {
  const [num, ...repoParts] = idParam.split('-');
  const repo = decodeURIComponent(repoParts.join('-'));
  const issue = state.issues.find(i => String(i.number) === num && i.repo === repo);
  if (!issue) {
    main.innerHTML = `<p>Issue not found. <a href="#/issues">← back to Issues</a></p>`;
    return;
  }
  const labels = (issue.labels || []).map(l => `<a class="badge tag">${escapeHtml(l)}</a>`).join('') || '<p>None yet</p>';
  main.innerHTML = `<div class="detail-header">
      <h1 class="detail-title">${escapeHtml(issue.title)} <span class="item-number">#${issue.number}</span></h1>
      <div>
        <span class="state-open">Open</span>
        <span class="detail-meta"> · ${escapeHtml(issue.repo)} · updated ${timeAgo(issue.updated)}</span>
      </div>
    </div>
    <div class="detail-view">
      <div>
        <div class="detail-body">
          <p>本 Issue は ~/.kb/issues/${escapeHtml(issue.repo)}.json 由来。<br>
          実本文は <a href="${escapeHtml(issue.url)}" target="_blank">GitHub で見る ↗</a> または<br>
          portal-api (port 8765) 経由で取得可能。</p>
        </div>
      </div>
      <div class="detail-sidebar">
        <div class="sidebar-section">
          <h3>Labels</h3>
          ${labels}
        </div>
        <div class="sidebar-section">
          <h3>Repository</h3>
          <a href="https://github.com/riku1215/${escapeHtml(issue.repo)}" target="_blank">riku1215/${escapeHtml(issue.repo)} ↗</a>
        </div>
        <div class="sidebar-section">
          <h3>Actions</h3>
          <a href="${escapeHtml(issue.url)}" target="_blank">GitHub で開く ↗</a>
          <a href="#/issues">← Issue 一覧</a>
        </div>
      </div>
    </div>`;
}

// ============================================
// Pull requests
// ============================================
function renderPulls(main) {
  main.innerHTML = `<div class="filter-bar">
      <div class="filter-state">
        <a href="#/pulls" class="active">⇄ Open <span class="gh-counter">${state.prs.length}</span></a>
      </div>
    </div>
    <div class="list">${state.prs.length ? state.prs.map(prRow).join('') : '<div style="padding:32px;text-align:center;color:var(--fg-muted)">PR インデックスがありません。<br>build-indexes.ps1 を実行してください</div>'}</div>`;
}
function prRow(p) {
  return `<div class="list-item" onclick="window.open('${escapeHtml(p.url||'#')}','_blank')">
    <span class="item-icon" style="color:var(--success-fg)">
      <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M1.5 3.25a2.25 2.25 0 1 1 3 2.122v5.256a2.251 2.251 0 1 1-1.5 0V5.372A2.25 2.25 0 0 1 1.5 3.25Z"/></svg>
    </span>
    <div class="item-body">
      <a class="item-title">${escapeHtml(p.title||'(no title)')}</a>
      <span class="item-number">#${p.number}</span>
      <div class="item-meta">
        <span>${escapeHtml(p.repo||'')}</span>
        <span>${escapeHtml(p.state||'')}</span>
        <span>updated ${timeAgo(p.updated||'')}</span>
      </div>
    </div>
  </div>`;
}

// ============================================
// Actions tab
// ============================================
function renderActions(main) {
  main.innerHTML = `<div class="page-header">
    <h1 class="page-title">Actions</h1>
  </div>
  <div class="action-grid">
    <div class="action-card">
      <h3>📦 Index 再構築</h3>
      <p>md ファイル / ハッシュタグ / Issue / PR を再 index。</p>
      <pre>.\\4-portal\\build-indexes.ps1</pre>
    </div>
    <div class="action-card">
      <h3>🚀 Portal 全再構築</h3>
      <p>ディレクトリ + symlink + UI + index 一括。</p>
      <pre>.\\4-portal\\portal-init.ps1</pre>
    </div>
    <div class="action-card">
      <h3>🔍 意味検索 API 起動</h3>
      <p>ChromaDB bridge (FastAPI、port 8765)。</p>
      <pre>cd 4-portal &amp;&amp; python portal-api.py</pre>
    </div>
    <div class="action-card">
      <h3>💾 KB 同期</h3>
      <p>~/.kb/ を最新化 (毎朝 09:00 で Task Scheduler 推奨)。</p>
      <pre>.\\1-knowledge\\update-robust.ps1</pre>
    </div>
    <div class="action-card">
      <h3>🤖 Agent route 確認</h3>
      <p>タスクをどの pipeline に流すか dry-run で確認。</p>
      <pre>.\\4-portal\\route.ps1 -DryRun "..."</pre>
    </div>
    <div class="action-card">
      <h3>🔄 KB バックアップ</h3>
      <p>git-bundle 形式で daily backup (30 日 retention)。</p>
      <pre>.\\1-knowledge\\backup.ps1</pre>
    </div>
  </div>`;
}

// ============================================
// Knowledge tab (ハッシュタグ + semantic search)
// ============================================
function renderKnowledge(main) {
  const max = Math.max(...state.hashtags.map(t => t.count || 1), 1);
  main.innerHTML = `<div class="page-header">
    <h1 class="page-title">Knowledge</h1>
    <span class="badge">${state.hashtags.length} hashtags</span>
  </div>
  <div class="tag-cloud" id="tag-cloud">
    ${state.hashtags.map(t => {
      const size = 11 + (t.count / max) * 8;
      return `<a class="tag" style="font-size:${size}px" onclick="filterByTag('${escapeHtml(t.tag)}')">#${escapeHtml(t.tag)}<span class="count">${t.count}</span></a>`;
    }).join('')}
  </div>
  <div id="kn-results" style="margin-top:24px"></div>`;
}
window.filterByTag = function(tag) {
  const files = state.files.filter(f => (f.tags||[]).includes(tag) && visMatch(f));
  const el = document.getElementById('kn-results');
  el.innerHTML = `<h2>#${escapeHtml(tag)} <span class="badge">${files.length}</span></h2>
    <div class="list standalone">${files.map(f => fileRow(f)).join('') || '<div style="padding:32px;text-align:center;color:var(--fg-muted)">該当ファイルなし</div>'}</div>`;
};
function fileRow(f) {
  return `<div class="list-item" onclick="window.open('${escapeHtml(f.path.replace('~', 'file:///'+(navigator.platform.startsWith('Win')?'C:/Users/m':'home'))).replace(/\\\\/g,'/')}','_blank')">
    <div class="item-body">
      <a class="item-title">${escapeHtml(f.title)}</a>
      <div class="item-meta"><span>${escapeHtml(f.path)}</span><span>${timeAgo(f.mtime)}</span></div>
      <div class="item-tags">${(f.tags||[]).slice(0,6).map(t=>`<span class="badge tag">#${escapeHtml(t)}</span>`).join('')}</div>
    </div>
  </div>`;
}

// ============================================
// Skills / Rules
// ============================================
function renderSkills(main) {
  main.innerHTML = `<div class="page-header">
    <h1 class="page-title">Skills</h1>
    <span class="badge">${state.skills.length} installed</span>
  </div>
  <div class="card-grid">${state.skills.map(s => `<div class="card">
    <div class="card-title">${escapeHtml(s.name)}</div>
    <div class="card-desc">${escapeHtml(s.description || '(no description)')}</div>
  </div>`).join('') || '<div style="grid-column:1/-1;text-align:center;padding:32px;color:var(--fg-muted)">~/.agents/skills/ にスキル未配置</div>'}</div>`;
}

function renderRules(main) {
  main.innerHTML = `<div class="page-header">
    <h1 class="page-title">Rules</h1>
    <span class="badge">${state.rules.length} rules</span>
  </div>
  <div class="list standalone">${state.rules.map(r => `<div class="list-item">
    <div class="item-body">
      <div><span class="badge tag">${escapeHtml(r.id)}</span> <span class="item-title">${escapeHtml(r.title)}</span></div>
      <div class="item-meta"><span>${escapeHtml(r.source||'')}</span></div>
    </div>
  </div>`).join('') || '<div style="padding:32px;text-align:center;color:var(--fg-muted)">R-rules 未抽出</div>'}</div>`;
}

// ============================================
// Insights tab (Cytoscape graph)
// ============================================
function renderInsights(main) {
  main.innerHTML = `<div class="page-header">
    <h1 class="page-title">Insights — Knowledge Graph</h1>
    <span class="badge">${state.graph.nodes.length} nodes · ${state.graph.edges.length} edges</span>
  </div>
  <div id="cy"></div>
  <div id="graph-detail" class="detail">ノードをクリックで詳細表示</div>`;
  setTimeout(() => {
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
          'label': 'data(label)', 'font-size': 9, 'color': '#e6edf3',
          'background-color': '#2f81f7', 'width': 14, 'height': 14,
          'text-outline-color': '#0d1117', 'text-outline-width': 1,
        }},
        { selector: 'node.tag', style: {
          'background-color': '#a371f7', 'shape': 'round-rectangle',
          'width': 'mapData(weight, 1, 50, 16, 60)',
          'height': 'mapData(weight, 1, 50, 10, 30)',
          'font-size': 11,
        }},
        { selector: 'node.file', style: {
          'background-color': '#3fb950', 'shape': 'ellipse',
        }},
        { selector: 'edge', style: {
          'width': 0.7, 'line-color': '#30363d', 'curve-style': 'bezier', 'opacity': 0.55,
        }},
        { selector: 'node:selected', style: {
          'border-width': 2, 'border-color': '#d29922',
        }},
      ],
      layout: { name: 'cose', animate: false, nodeRepulsion: 5000, idealEdgeLength: 60 },
      minZoom: 0.2, maxZoom: 3,
    });
    state.cy.on('tap', 'node', evt => {
      const d = evt.target.data();
      const detail = document.getElementById('graph-detail');
      if (d.type === 'file') {
        detail.innerHTML = `<b>📄 ${escapeHtml(d.label)}</b><br><span class="badge ${d.visibility}">${d.visibility||''}</span> <code>${escapeHtml(d.path)}</code>`;
      } else {
        detail.innerHTML = `<b>🏷 ${escapeHtml(d.label)}</b> — weight ${d.weight}`;
      }
    });
  }, 0);
}

// ============================================
// Help tab
// ============================================
function renderHelp(main) {
  main.innerHTML = `<div class="page-header"><h1 class="page-title">Help</h1></div>
  <div class="detail-body"><div class="body-md">
    <h2>Captain Portal — GitHub IA 再現ローカルナレッジハブ</h2>
    <p>46 repo + 1000+ Issue + 47 Skills + R-rules + ハッシュタグを GitHub と同じ操作感で横断検索。</p>

    <h3>キーボードショートカット</h3>
    <ul>
      <li><kbd>/</kbd> — 検索バーフォーカス</li>
      <li><kbd>g</kbd> + <kbd>i</kbd> — Issues タブ</li>
      <li><kbd>g</kbd> + <kbd>p</kbd> — Pull requests タブ</li>
      <li><kbd>g</kbd> + <kbd>c</kbd> — Code タブ</li>
      <li><kbd>g</kbd> + <kbd>k</kbd> — Knowledge タブ</li>
    </ul>

    <h3>ナレッジ化トリガ語 (historian agent)</h3>
    <p>下記語を Claude に発話すると ~/.kb/ + Issue に自動記録 (Phase 2):</p>
    <ul>
      <li>「ナレッジ化して」「記録しておいて」「Issue に残して」</li>
      <li>「これ重要」「後で参照する」「失敗パターン化」</li>
    </ul>

    <h3>更新コマンド</h3>
    <pre>.\\4-portal\\build-indexes.ps1   # index 再生成
.\\4-portal\\portal-init.ps1     # Portal 全再構築
python portal-api.py             # 意味検索 API (port 8765)</pre>

    <h3>関連ファイル</h3>
    <ul>
      <li><code>~/Portal/indexes/*.json</code> — 検索元データ (6 ファイル)</li>
      <li><code>4-portal/agents.yml</code> — 7 役 agent 定義</li>
      <li><code>4-portal/routing.yml</code> — 階層分岐 decision tree</li>
      <li><code>4-portal/agent_profiles.yaml</code> — role 別 retrieval policy</li>
      <li><code>4-portal/protocol.md</code> — オーケストレーション</li>
      <li><code>PROFILE.md</code> — Captain プロフィール + R-rules + Section 7</li>
    </ul>
  </div></div>`;
}

// ============================================
// Search bar (live update)
// ============================================
function onSearch() {
  const v = document.getElementById('search').value;
  state.query = v;
  // 検索結果が見える tab だけ再描画
  if (['issues', 'pulls', 'code', 'knowledge'].includes(state.currentRoute)) {
    render();
  }
}

// ============================================
// Keyboard shortcuts
// ============================================
let lastKey = '';
let lastKeyTime = 0;
document.addEventListener('keydown', e => {
  if (e.target.tagName === 'INPUT' || e.target.tagName === 'SELECT' || e.target.tagName === 'TEXTAREA') {
    if (e.key === 'Escape') { e.target.blur(); }
    return;
  }
  if (e.key === '/') { e.preventDefault(); document.getElementById('search').focus(); return; }
  if (e.key === 'g') { lastKey = 'g'; lastKeyTime = Date.now(); return; }
  if (lastKey === 'g' && Date.now() - lastKeyTime < 1500) {
    const map = { i: 'issues', p: 'pulls', c: 'code', k: 'knowledge', s: 'skills', r: 'rules', a: 'actions', h: 'help' };
    if (map[e.key]) { go(map[e.key]); lastKey = ''; }
  }
});

// ============================================
// Init
// ============================================
document.addEventListener('DOMContentLoaded', async () => {
  document.getElementById('search').addEventListener('input', onSearch);
  document.getElementById('vis-filter').addEventListener('change', e => {
    state.visibility = e.target.value; render();
  });
  window.addEventListener('hashchange', render);
  if (!location.hash) location.hash = '#/code';
  await loadAll();
  render();
});
