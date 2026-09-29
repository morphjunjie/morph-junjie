const $ = (s) => document.querySelector(s);
const RES = (typeof GetParentResourceName !== 'undefined') ? GetParentResourceName() : 'morph_chat';
const cfg = { timestamps: true, sounds: true, fadeDelay: 12000, maxMessages: 60, emojis: [], locale: {} };
let myName = '';
let templates = {};
let suggestions = [];
let suggShown = [];
let suggSel = -1;
let sent = [];
let histIdx = -1;
let fadeTimer = null;
let inputOpen = false;

function fetchNui(name, data) {
  return fetch(`https://${RES}/${name}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(data || {}) }).catch(() => {});
}
function esc(s) {
  return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}
function loc(k) { return cfg.locale[k] || DEF[k] || k; }
const DEF = { ad: 'ANUNCIO', report: 'REPORT', dm_to: 'to', dm_from: 'from', placeholder: 'Escribe un mensaje...' };

const GTA = ['#ffffff', '#f04b4b', '#69d95c', '#f0d95c', '#5c8bf0', '#77c9e6', '#c47ff0', '#ffffff', '#f0913c', '#9aa0a6'];
function colorize(s) {
  let out = '', open = false;
  s = String(s);
  for (let i = 0; i < s.length; i++) {
    if (s[i] === '^' && /[0-9]/.test(s[i + 1])) {
      if (open) out += '</span>';
      out += `<span style="color:${GTA[+s[i + 1]]}">`; open = true; i++;
    } else { out += esc(s[i]); }
  }
  if (open) out += '</span>';
  return out;
}
function markMentions(html) {
  let hit = false;
  const clean = (myName || '').toLowerCase().replace(/[^a-z0-9_]/gi, '');
  const out = html.replace(/@([A-Za-z0-9_]+)/g, (m, n) => {
    if (clean && n.toLowerCase() === clean) hit = true;
    return '<span class="mn">' + m + '</span>';
  });
  return [out, hit];
}
function ts(m) { return (cfg.timestamps && m.ts) ? `<span class="ts">${m.ts}</span>` : ''; }

let ctx = null, muted = false;
function tone(freq, dur, slide) {
  if (!cfg.sounds || muted) return;
  try {
    if (!ctx) ctx = new (window.AudioContext || window.webkitAudioContext)();
    const o = ctx.createOscillator(), g = ctx.createGain(), t = ctx.currentTime;
    o.type = 'sine'; o.frequency.setValueAtTime(freq, t);
    if (slide) o.frequency.exponentialRampToValueAtTime(slide, t + dur);
    g.gain.setValueAtTime(0.0001, t); g.gain.exponentialRampToValueAtTime(0.04, t + 0.01); g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    o.connect(g).connect(ctx.destination); o.start(t); o.stop(t + dur + 0.02);
  } catch (e) {}
}
const blip = () => tone(560, 0.05);
const ping = () => { tone(660, 0.09, 990); };

function awake() {
  const log = $('#log');
  log.classList.add('awake'); log.classList.remove('dim');
  clearTimeout(fadeTimer);
  if (!inputOpen) fadeTimer = setTimeout(() => { log.classList.remove('awake'); log.classList.add('dim'); }, cfg.fadeDelay);
}
function cap() {
  const log = $('#log');
  while (log.children.length > cfg.maxMessages) log.removeChild(log.firstChild);
}

function addMessage(m) {
  const log = $('#log');
  const el = document.createElement('div');
  if (m && m.jrmy) {
    const t = m.mtype;
    let [body, hit] = markMentions(m.body || '');
    const name = esc(m.name);
    if (t === 'ad') {
      el.className = 'card ad';
      el.innerHTML = `<span class="lead"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 11 18-5v12L3 14v-3z"/><path d="M11.6 16.8a3 3 0 1 1-5.8-1.6"/></svg>${esc(loc('ad'))}</span><span class="body">${body}</span>`;
    } else if (t === 'report') {
      el.className = 'card report';
      el.innerHTML = `${ts(m)}<span class="tag">${esc(loc('report'))}</span><span class="name">${name}</span><span class="body">${body}</span>`;
    } else if (t === 'system') {
      el.className = 'row sys'; el.innerHTML = `${ts(m)}<span class="body">${body}</span>`;
    } else if (t === 'me') {
      el.className = 'row me'; el.innerHTML = `${ts(m)}<span class="body">✿ ${name} ${body}</span>`;
    } else if (t === 'do') {
      el.className = 'row doo'; el.innerHTML = `${ts(m)}<span class="body">✦ ${name} ${body}</span>`;
    } else if (t === 'ooc') {
      el.className = 'row ooc'; el.innerHTML = `${ts(m)}<span class="body">(( ${name}: ${body} ))</span>`;
    } else if (t === 'dm') {
      const dir = m.dmDir === 'to' ? loc('dm_to') : loc('dm_from');
      el.className = 'row dm'; el.innerHTML = `${ts(m)}<span class="tag" style="background:var(--rose-hot)">DM</span><span class="name">${esc(dir)} ${name}</span><span class="body">${body}</span>`;
    } else {
      const tag = m.tag ? `<span class="tag" style="background:${esc(m.tag.color)}">${esc(m.tag.label)}</span>` : '';
      el.className = 'row' + (hit ? ' mention' : '');
      el.innerHTML = `${ts(m)}${tag}<span class="name" style="color:${esc(m.nameColor || '#f6eae6')}">${name}</span><span class="body">${body}</span>`;
    }
    hit ? ping() : blip();
  } else {
    el.className = 'row';
    let html = '';
    if (m.templateId && templates[m.templateId]) {
      html = templates[m.templateId].replace(/\{(\d+)\}/g, (mm, i) => colorize((m.args && m.args[i]) || ''));
    } else {
      const a = (m.args || []).map((x) => colorize(x));
      if (a.length > 1) html = `<span class="name">${a[0]}</span><span class="body">${a.slice(1).join(' ')}</span>`;
      else html = `<span class="body">${a[0] || ''}</span>`;
    }
    el.innerHTML = html;
    blip();
  }
  log.appendChild(el); cap(); awake();
}

function buildEmojis() {
  const box = $('#emojis');
  box.innerHTML = '<div class="cat">✿</div><div id="egrid"></div>';
  const g = $('#egrid');
  (cfg.emojis || []).forEach((e) => {
    const s = document.createElement('span'); s.textContent = e;
    s.onclick = () => { const t = $('#txt'); t.value += e; t.focus(); };
    g.appendChild(s);
  });
}

function renderSugg() {
  const box = $('#sugg');
  const val = $('#txt').value;
  if (!inputOpen || val[0] !== '/' || val.indexOf(' ') !== -1) { box.classList.add('hidden'); suggShown = []; suggSel = -1; return; }
  const q = val.toLowerCase();
  suggShown = suggestions.filter((s) => s.name.toLowerCase().startsWith(q)).slice(0, 5);
  if (!suggShown.length) { box.classList.add('hidden'); return; }
  if (suggSel >= suggShown.length) suggSel = suggShown.length - 1;
  box.classList.remove('hidden');
  box.innerHTML = suggShown.map((s, i) => `<div class="s${i === suggSel ? ' sel' : ''}"><span class="cmd">${esc(s.name)}</span><span class="desc">${esc(s.help || '')}</span></div>`).join('');
}

function openInput() {
  inputOpen = true;
  $('#inputwrap').classList.remove('hidden');
  $('#chat').classList.add('typing');
  const t = $('#txt'); t.value = ''; t.placeholder = loc('placeholder'); t.focus();
  histIdx = -1; awake(); renderSugg();
}
function closeInput() {
  inputOpen = false;
  $('#inputwrap').classList.add('hidden');
  $('#emojis').classList.add('hidden');
  $('#chat').classList.remove('typing');
  $('#txt').blur(); awake();
}
function submit() {
  const v = $('#txt').value.trim();
  closeInput();
  fetchNui('chatResult', { message: v });
  if (v) { sent.unshift(v); if (sent.length > 30) sent.pop(); }
}

$('#txt').addEventListener('input', () => { renderSugg(); const v = $('#txt').value; $('#chan').textContent = v[0] === '/' ? 'CMD' : 'SAY'; });
$('#txt').addEventListener('keydown', (e) => {
  if (e.key === 'Enter') { e.preventDefault(); submit(); }
  else if (e.key === 'Escape') { e.preventDefault(); closeInput(); fetchNui('chatClose'); }
  else if (e.key === 'Tab') { e.preventDefault(); if (suggShown.length) { const s = suggShown[suggSel < 0 ? 0 : suggSel]; $('#txt').value = s.name + ' '; renderSugg(); } }
  else if (e.key === 'ArrowUp') { e.preventDefault(); if (suggShown.length) { suggSel = Math.max(0, suggSel - 1); renderSugg(); } else if (sent.length) { histIdx = Math.min(sent.length - 1, histIdx + 1); $('#txt').value = sent[histIdx] || ''; } }
  else if (e.key === 'ArrowDown') { e.preventDefault(); if (suggShown.length) { suggSel = Math.min(suggShown.length - 1, suggSel + 1); renderSugg(); } else if (histIdx > 0) { histIdx--; $('#txt').value = sent[histIdx] || ''; } }
});
$('#send').onclick = submit;
$('#ebtn').onclick = () => { $('#emojis').classList.toggle('hidden'); $('#txt').focus(); };

function bubbles(list) {
  const box = $('#bubbles');
  const seen = {};
  (list || []).forEach((b) => {
    seen[b.id] = true;
    let el = box.querySelector(`[data-id="${b.id}"]`);
    if (!el) {
      el = document.createElement('div'); el.dataset.id = b.id; box.appendChild(el);
    }
    el.className = 'bub ' + (b.mtype === 'do' ? 'doo' : 'me');
    el.style.left = (b.x * 100) + 'vw';
    el.style.top = (b.y * 100) + 'vh';
    el.style.transform = `translate(-50%,-100%) scale(${b.scale})`;
    el.style.opacity = b.alpha;
    const label = b.mtype === 'do' ? 'DO' : 'ME';
    const inner = b.mtype === 'me' ? `✿ ${esc(b.name)} ${esc(b.text)}` : `${esc(b.text)}`;
    el.innerHTML = `<span class="ht">${label}</span><span class="htx">${inner}</span>`;
  });
  box.querySelectorAll('.bub').forEach((el) => { if (!seen[el.dataset.id]) el.remove(); });
}

function onInit(d) {
  Object.assign(cfg, d);
  myName = d.me || '';
  $('#chat').dataset.pos = d.position || 'top-left';
  buildEmojis();
  awake();
}

window.addEventListener('message', (e) => {
  const m = e.data || {};
  const d = m.data;
  if (m.action === 'init') onInit(d);
  else if (m.action === 'message') addMessage(d);
  else if (m.action === 'open') openInput();
  else if (m.action === 'suggestions') { suggestions = suggestions.concat(d || []); renderSugg(); }
  else if (m.action === 'suggestion') { suggestions.push(d); renderSugg(); }
  else if (m.action === 'removeSuggestion') { suggestions = suggestions.filter((s) => s.name !== d.name); renderSugg(); }
  else if (m.action === 'template') { templates[d.id] = d.html; }
  else if (m.action === 'clear') { $('#log').innerHTML = ''; }
  else if (m.action === 'bubbles') bubbles(d);
});

if (typeof GetParentResourceName === 'undefined') {
  onInit({ position: 'top-left', timestamps: true, sounds: false, emojis: ['🌸', '✿', '💖', '❤️', '✨', '🥺', '😊', '😳', '😢', '🙈', '🔥', '👍', '😂', '🎉', '⭐', '😎', '💅', '🤍', '👀', '💫'], me: 'Jaramiyo', locale: DEF });
  addMessage({ jrmy: true, mtype: 'system', ts: '21:04', body: '✿ Welcome to the city, have fun and be kind!' });
  addMessage({ jrmy: true, mtype: 'normal', ts: '21:05', tag: { label: 'STAFF', color: '#f4d778' }, name: 'Jaramiyo', nameColor: '#f4d778', body: 'hola a todos! si necesitan algo me dicen ✿' });
  addMessage({ jrmy: true, mtype: 'me', ts: '21:06', name: 'Jaramiyo', body: 'saluda con la manita' });
  addMessage({ jrmy: true, mtype: 'do', ts: '21:06', name: 'Jaramiyo', body: 'la música se escucha durísimo' });
  addMessage({ jrmy: true, mtype: 'ooc', ts: '21:07', name: 'Blu', body: 'brb 5 min' });
  addMessage({ jrmy: true, mtype: 'normal', ts: '21:07', tag: { label: 'MECHANIC', color: '#8fd6a4' }, name: 'Sam', nameColor: '#8fd6a4', body: '@Jaramiyo tu carrito ya está listo 🌸' });
  addMessage({ jrmy: true, mtype: 'ad', ts: '21:08', name: 'x', body: 'Vendo Sultan RS full, 555-0142' });
  addMessage({ jrmy: true, mtype: 'report', ts: '21:08', name: 'Blu', body: 'atascada bajo el mapa en Legion' });
  openInput(); $('#txt').value = 'nos vemos luego chicos 🌸'; $('#emojis').classList.remove('hidden');
} else {
  fetchNui('nuiReady');
}
