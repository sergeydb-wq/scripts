// wannacry hub — сервер для Wispbyte (Node.js 18+, без зависимостей)
//  • /presence      — кто юзает скрипт, в каком сервере Roblox и какая на нём косметика
//  • /admin/poll    — закрытый чат админов (ник + токен из config.json)
//  • /admin/send
//  • /admin/users   — список всех юзеров скрипта онлайн (только админам)
//  • /health        — проверка, что сервер жив
"use strict";

const http = require("http");
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

// ---------- конфиг ----------
const CFG_PATH = path.join(__dirname, "config.json");
let cfg = {};
try { cfg = JSON.parse(fs.readFileSync(CFG_PATH, "utf8")); } catch (e) {
  console.warn("[hub] config.json не найден или битый — использую значения по умолчанию");
}
const PORT = Number(process.env.SERVER_PORT || process.env.PORT || cfg.port || 3000);
const HUB_KEY = String(process.env.HUB_KEY || cfg.hubKey || "wc_hub_change_me");
// admins: { "Tobby2281E": "токен", "sergeoomg": "токен" }  (ник чувствителен к регистру)
const ADMINS = cfg.admins || {};
const PRESENCE_TTL = 25 * 1000;          // юзер пропадает через 25 с без пинга
const MAX_ADMIN_MSGS = 300;
const COS_ID = /^[a-z0-9_]{1,24}$/;
const HISTORY_FILE = path.join(__dirname, "adminchat.json");

if (HUB_KEY === "wc_hub_change_me") console.warn("[hub] ВНИМАНИЕ: поменяй hubKey в config.json (и WC_NET.hubKey в скрипте)");
for (const [n, t] of Object.entries(ADMINS)) {
  if (!t || String(t).length < 12) console.warn(`[hub] токен админа ${n} слишком короткий (нужно 12+ символов)`);
}

// ---------- состояние ----------
const users = new Map();                 // userId -> {userId,name,jobId,placeId,cos,korblox,headless,seen}
const adminOnline = new Map();           // name -> lastSeen
let adminMsgs = [];
let adminSeq = 0;
try {
  const h = JSON.parse(fs.readFileSync(HISTORY_FILE, "utf8"));
  if (Array.isArray(h.msgs)) { adminMsgs = h.msgs.slice(-MAX_ADMIN_MSGS); adminSeq = Number(h.seq) || 0; }
} catch (e) { /* истории ещё нет */ }
let saveTimer = null;
function saveHistory() {
  if (saveTimer) return;
  saveTimer = setTimeout(() => {
    saveTimer = null;
    fs.writeFile(HISTORY_FILE, JSON.stringify({ seq: adminSeq, msgs: adminMsgs }), () => {});
  }, 2000);
}

setInterval(() => {
  const now = Date.now();
  for (const [id, u] of users) if (now - u.seen > PRESENCE_TTL) users.delete(id);
  for (const [n, t] of adminOnline) if (now - t > 15000) adminOnline.delete(n);
  for (const [ip, b] of buckets) if (now - b.t > 60000) buckets.delete(ip);
}, 5000);

// ---------- защита ----------
const buckets = new Map();               // простой rate limit: 40 запросов / 10 с на IP
function allow(ip) {
  const now = Date.now();
  let b = buckets.get(ip);
  if (!b || now - b.t > 10000) { b = { t: now, n: 0 }; buckets.set(ip, b); }
  b.n += 1;
  return b.n <= 40;
}
function safeEq(a, b) {
  const x = Buffer.from(String(a)), y = Buffer.from(String(b));
  return x.length === y.length && crypto.timingSafeEqual(x, y);
}
function isAdmin(name, token) {
  if (typeof name !== "string" || typeof token !== "string") return false;
  if (!Object.prototype.hasOwnProperty.call(ADMINS, name)) return false;
  const real = ADMINS[name];
  return !!real && safeEq(real, token);
}
function str(v, max) { return typeof v === "string" ? v.slice(0, max) : ""; }
function clean(text) {
  return str(text, 300).replace(/[\u0000-\u001f\u007f]/g, " ").trim();
}

// ---------- http ----------
function send(res, code, obj) {
  const body = JSON.stringify(obj);
  res.writeHead(code, { "Content-Type": "application/json; charset=utf-8", "Content-Length": Buffer.byteLength(body) });
  res.end(body);
}
function readBody(req) {
  return new Promise((resolve) => {
    let data = "";
    req.on("data", (c) => {
      data += c;
      if (data.length > 8192) { data = ""; req.destroy(); }
    });
    req.on("end", () => { try { resolve(data ? JSON.parse(data) : {}); } catch (e) { resolve({}); } });
    req.on("error", () => resolve({}));
  });
}

async function handle(req, res) {
  const ip = (req.headers["x-forwarded-for"] || req.socket.remoteAddress || "?").toString().split(",")[0].trim();
  const url = new URL(req.url, "http://x");
  const p = url.pathname;
  const q = url.searchParams;

  if (p === "/health") return send(res, 200, { ok: true, users: users.size });
  if (!allow(ip)) return send(res, 429, { error: "slow" });
  if (!safeEq(q.get("key") || "", HUB_KEY)) return send(res, 401, { error: "bad key" });

  // --- кто юзает скрипт + косметика ---
  if (p === "/presence" && req.method === "POST") {
    const b = await readBody(req);
    const userId = Number(b.userId);
    if (!Number.isSafeInteger(userId) || userId <= 0) return send(res, 400, { error: "bad user" });
    const jobId = str(b.jobId, 64);
    const cos = Array.isArray(b.cos) ? b.cos.filter((c) => typeof c === "string" && COS_ID.test(c)).slice(0, 12) : [];
    // снятые UGC (имена аксессуаров) — другие юзеры прячут их у себя
    const ugc = Array.isArray(b.ugc) ? b.ugc.filter((n) => typeof n === "string" && n.length > 0 && n.length <= 100).slice(0, 40) : [];
    users.set(userId, {
      userId, name: str(b.name, 32), jobId, placeId: Number(b.placeId) || 0,
      cos, ugc, korblox: b.korblox === true, headless: b.headless === true, seen: Date.now(),
    });
    const same = [];
    if (jobId) {
      for (const u of users.values()) {
        if (u.jobId === jobId && u.userId !== userId) {
          same.push({ userId: u.userId, name: u.name, cos: u.cos, ugc: u.ugc || [], korblox: u.korblox, headless: u.headless });
        }
      }
    }
    return send(res, 200, { users: same, total: users.size });
  }

  // --- админ-чат ---
  if (p === "/admin/poll" && req.method === "GET") {
    const name = q.get("name") || "";
    if (!isAdmin(name, q.get("token") || "")) return send(res, 403, { error: "denied" });
    adminOnline.set(name, Date.now());
    const after = Number(q.get("after")) || 0;
    // первый запрос — последние 50 сообщений
    const list = after > 0 ? adminMsgs.filter((m) => m.id > after) : adminMsgs.slice(-50);
    return send(res, 200, { messages: list, last: adminSeq, admins: [...adminOnline.keys()], users: users.size });
  }
  if (p === "/admin/send" && req.method === "POST") {
    const b = await readBody(req);
    if (!isAdmin(b.name, b.token)) return send(res, 403, { error: "denied" });
    const text = clean(b.text);
    if (!text) return send(res, 400, { error: "empty" });
    adminSeq += 1;
    adminMsgs.push({ id: adminSeq, name: b.name, text, t: Date.now() });
    if (adminMsgs.length > MAX_ADMIN_MSGS) adminMsgs = adminMsgs.slice(-MAX_ADMIN_MSGS);
    adminOnline.set(b.name, Date.now());
    saveHistory();
    return send(res, 200, { ok: true, id: adminSeq });
  }
  if (p === "/admin/users" && req.method === "GET") {
    if (!isAdmin(q.get("name") || "", q.get("token") || "")) return send(res, 403, { error: "denied" });
    const list = [...users.values()].map((u) => ({ userId: u.userId, name: u.name, placeId: u.placeId, jobId: u.jobId, cos: u.cos, korblox: u.korblox, headless: u.headless }));
    return send(res, 200, { users: list });
  }

  return send(res, 404, { error: "not found" });
}

http.createServer((req, res) => {
  handle(req, res).catch((e) => { console.error(e); try { send(res, 500, { error: "server" }); } catch (_) {} });
}).listen(PORT, "0.0.0.0", () => {
  console.log(`[hub] wannacry hub слушает порт ${PORT} · админов: ${Object.keys(ADMINS).join(", ") || "нет"}`);
});
