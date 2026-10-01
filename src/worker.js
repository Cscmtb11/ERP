const COOKIE = 'nexa_erp_session';
const SESSION_TTL = 60 * 60 * 12;
const attempts = new Map();

const json = (data, status = 200, extra = {}) => new Response(JSON.stringify(data), { status, headers: { 'content-type': 'application/json; charset=utf-8', ...extra } });
const now = () => Math.floor(Date.now() / 1000);
const b64 = (bytes) => btoa(String.fromCharCode(...new Uint8Array(bytes))).replace(/\+/g,'-').replace(/\//g,'_').replace(/=+$/,'');
const unb64 = (s) => Uint8Array.from(atob(s.replace(/-/g,'+').replace(/_/g,'/')), c => c.charCodeAt(0));

async function sha256(value) { return b64(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(value))); }
async function pbkdf2(password, encoded) {
  const [scheme, iterations, salt, expected] = (encoded || '').split('$');
  if (scheme !== 'pbkdf2' || !iterations || !salt || !expected) return false;
  const key = await crypto.subtle.importKey('raw', new TextEncoder().encode(password), 'PBKDF2', false, ['deriveBits']);
  const bits = await crypto.subtle.deriveBits({ name:'PBKDF2', salt:unb64(salt), iterations:Number(iterations), hash:'SHA-256' }, key, 256);
  return b64(bits) === expected;
}
async function verifyPassword(password, stored) {
  if ((stored || '').startsWith('pbkdf2$')) return pbkdf2(password, stored);
  return !!stored && password === stored;
}
function cookie(value, maxAge) { return `${COOKIE}=${value}; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=${maxAge}`; }
function getToken(request) { const c = request.headers.get('Cookie') || ''; const m = c.match(new RegExp(`(?:^|;\\s*)${COOKIE}=([^;]+)`)); return m?.[1]; }
async function requireUser(request, env) {
  if (!env.DB) throw new Error('D1 database binding DB is not configured');
  const token = getToken(request); if (!token) return null;
  const hash = await sha256(token);
  const row = await env.DB.prepare(`SELECT s.id, s.user_id, s.expires_at, u.email, u.name, u.role, u.active FROM sessions s JOIN users u ON u.id=s.user_id WHERE s.token_hash=? AND s.expires_at>? AND u.active=1`).bind(hash, now()).first();
  return row || null;
}
function sameOrigin(request) { const origin = request.headers.get('Origin'); return !origin || origin === new URL(request.url).origin; }

async function login(request, env) {
  const ip = request.headers.get('CF-Connecting-IP') || 'unknown';
  const t = now(); const a = attempts.get(ip) || { count:0, reset:t+900 };
  if (t > a.reset) { a.count=0; a.reset=t+900; }
  if (a.count >= 8) return json({error:'Too many login attempts. Try again later.'}, 429);
  const body = await request.json(); const email = String(body.email || '').trim().toLowerCase(); const password = String(body.password || '');
  let user = null;
  if (email === String(env.ADMIN_EMAIL || '').trim().toLowerCase() && await verifyPassword(password, env.ADMIN_PASSWORD_HASH)) {
    user = { id:'admin', email, name:'System Administrator', role:'admin', active:1 };
  } else if (env.DB) {
    user = await env.DB.prepare('SELECT * FROM users WHERE lower(email)=? AND active=1').bind(email).first();
    if (!user || !(await verifyPassword(password, user.password_hash))) user = null;
  }
  if (!user) { a.count++; attempts.set(ip,a); return json({error:'Invalid email or password'}, 401); }
  attempts.delete(ip);
  const token = b64(crypto.getRandomValues(new Uint8Array(32))); const hash = await sha256(token); const expires = t + SESSION_TTL;
  if (env.DB) await env.DB.prepare('INSERT INTO sessions(token_hash,user_id,expires_at,created_at,ip) VALUES(?,?,?,?,?)').bind(hash,String(user.id),expires,t,ip).run();
  return json({user:{id:user.id,email:user.email,name:user.name,role:user.role}},200,{'Set-Cookie':cookie(token,SESSION_TTL)});
}

async function api(request, env, ctx) {
  const url = new URL(request.url); const path = url.pathname;
  if (request.method === 'POST' && path === '/api/login') return login(request, env);
  if (path === '/api/fx' && request.method === 'GET') {
    const base = (url.searchParams.get('base') || 'INR').toUpperCase();
    const cacheKey = new Request(`https://fx.internal/${base}`); const cache = caches.default; const hit = await cache.match(cacheKey); if (hit) return hit;
    const upstream = await fetch(`https://open.er-api.com/v6/latest/${encodeURIComponent(base)}`, { cf:{cacheTtl:300,cacheEverything:true} });
    if (!upstream.ok) return json({error:'Exchange-rate provider unavailable'},502);
    const data = await upstream.json(); const response = json({base:data.base_code || base,rates:data.rates || {},updated_at:data.time_last_update_utc || null}); ctx.waitUntil(cache.put(cacheKey,response.clone())); return response;
  }
  if (path === '/api/health') return json({ok:true,time:new Date().toISOString(),d1:!!env.DB});
  const user = await requireUser(request, env); if (!user) return json({error:'Authentication required'},401);
  if (request.method !== 'GET' && !sameOrigin(request)) return json({error:'Invalid origin'},403);
  if (path === '/api/me') return json({user:{id:user.user_id,email:user.email,name:user.name,role:user.role}});
  if (path === '/api/logout') { if (env.DB) await env.DB.prepare('DELETE FROM sessions WHERE token_hash=?').bind(await sha256(getToken(request))).run(); return json({ok:true},200,{'Set-Cookie':cookie('',0)}); }
  if (path === '/api/users' && request.method === 'GET') { if (user.role !== 'admin') return json({error:'Admin only'},403); const rows = await env.DB.prepare('SELECT id,email,name,role,active,created_at FROM users ORDER BY created_at DESC').all(); return json({data:rows.results}); }
  if (path === '/api/users' && request.method === 'POST') {
    if (user.role !== 'admin') return json({error:'Admin only'},403); const b=await request.json(); const email=String(b.email||'').trim().toLowerCase(); const name=String(b.name||'').trim(); const password=String(b.password||''); const role=['admin','manager','operator','viewer'].includes(b.role)?b.role:'operator'; if(!email||!password||password.length<12) return json({error:'Email and password are required; password must be at least 12 characters.'},400); const salt=b64(crypto.getRandomValues(new Uint8Array(16))); const key=await crypto.subtle.importKey('raw',new TextEncoder().encode(password),'PBKDF2',false,['deriveBits']); const bits=await crypto.subtle.deriveBits({name:'PBKDF2',salt:unb64(salt),iterations:210000,hash:'SHA-256'},key,256); const hash=`pbkdf2$210000$${salt}$${b64(bits)}`; const id=crypto.randomUUID(); try { await env.DB.prepare('INSERT INTO users(id,email,name,password_hash,role,active,created_at) VALUES(?,?,?,?,?,1,?)').bind(id,email,name,hash,role,now()).run(); } catch(e){ return json({error:'Unable to create user. Email may already exist.'},409); } return json({ok:true,id});
  }
  const entityMatch=path.match(/^\/api\/(banks|customers|products|contracts|shipments|invoices)$/); if(entityMatch){ const table=entityMatch[1]; const allowed={banks:['name','account','branch','swift'],customers:['company','contact','email','phone','address','importer_bank'],products:['code','name','description','unit','hs_code'],contracts:['contract_no','customer_id','currency','amount','incoterm','payment_method','shipment_destination','last_shipment_date','status'],shipments:['contract_id','mode','origin','destination','eta','status'],invoices:['contract_id','invoice_no','currency','amount','status']}[table]; if(request.method==='GET'){const rows=await env.DB.prepare(`SELECT * FROM ${table} ORDER BY created_at DESC LIMIT 500`).all();return json({data:rows.results});} if(!['admin','manager','operator'].includes(user.role))return json({error:'Write permission denied'},403); const b=await request.json(); const keys=allowed.filter(k=>b[k]!==undefined); if(!keys.length)return json({error:'No fields supplied'},400); const vals=keys.map(k=>b[k]); const id=crypto.randomUUID(); const sql=`INSERT INTO ${table}(id,${keys.join(',')},created_at,updated_at) VALUES(?,${keys.map(()=>'?').join(',')},?,?)`; await env.DB.prepare(sql).bind(id,...vals,now(),now()).run(); return json({ok:true,id}); }
  return json({error:'Not found'},404);
}

export default { async fetch(request, env, ctx) { const url=new URL(request.url); if(url.pathname.startsWith('/api/')) return api(request,env,ctx); return env.ASSETS.fetch(request); } };
