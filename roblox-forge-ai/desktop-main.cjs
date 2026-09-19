const {app,BrowserWindow,ipcMain,session,dialog,shell}=require("electron");
const {spawn}=require("node:child_process");
const path=require("node:path");
const fs=require("node:fs");
const http=require("node:http");
const crypto=require("node:crypto");
const {AccountStore}=require("./account-store.cjs");
const FORGE_URL="https://roblox-forge-ai.hatchable.site";
let win=null,bridge=null,bridgeState="offline",accounts=null;
function logFile(){try{return path.join(app.getPath("userData"),"startup.log")}catch{return path.join(process.cwd(),"startup.log")}}
function log(x){try{fs.appendFileSync(logFile(),new Date().toISOString()+" "+x+"\n")}catch{}}
process.on("uncaughtException",e=>log("UNCAUGHT "+e.stack));
process.on("unhandledRejection",e=>log("REJECTION "+(e?.stack||e)));
function trusted(e){if(!win||win.isDestroyed()||e?.sender!==win.webContents)return false;const u=e.senderFrame?.url||"";if(u.startsWith("file://"))return true;return u===FORGE_URL||u.startsWith(FORGE_URL+"/")}
function emit(type,data){if(win&&!win.isDestroyed())win.webContents.send("forge-bridge-event",{type,...data})}
function setState(state,detail=""){bridgeState=state;emit("state",{state,detail})}
function startBridge(forgeKey,noxeryKey,autoDev=false){
 forgeKey=String(forgeKey||"").trim();noxeryKey=String(noxeryKey||"").trim();
 if(!noxeryKey)throw new Error("Noxery API Key gerekli.");
 if(bridge&&!bridge.killed)return {ok:true,state:bridgeState};
 const bridgePath=path.join(process.resourcesPath,"bridge.cjs");
 if(!fs.existsSync(bridgePath))throw new Error("Bridge runtime bulunamadı: "+bridgePath);
 bridge=spawn(process.execPath,[bridgePath,forgeKey,noxeryKey,autoDev?"1":"0"],{env:{...process.env,ELECTRON_RUN_AS_NODE:"1",ELECTRON_NO_ASAR:"1"},stdio:["pipe","pipe","pipe"],windowsHide:false});
 setState("starting","Roblox Studio MCP başlatılıyor...");
 bridge.stdout.on("data",b=>emit("log",{stream:"stdout",text:String(b)}));
 bridge.stderr.on("data",b=>emit("log",{stream:"stderr",text:String(b)}));
 bridge.on("error",e=>{log("BRIDGE ERROR "+e.stack);setState("error",e.message)});
 bridge.on("close",(code,signal)=>{bridge=null;setState(code===0?"offline":"error","Bridge kapandı: code="+code+" signal="+(signal||""))});
 accounts?.log("bridge.started",{autoDev:!!autoDev});
 return {ok:true,state:"starting"};
}
function sendCommand(p){if(!bridge||bridge.killed||!bridge.stdin.writable)throw new Error("Bridge bağlı değil.");p=String(p||"").trim();if(!p)return {ok:false};bridge.stdin.write(p+"\n");emit("log",{stream:"command",text:"> "+p});accounts?.log("ai.command",{prompt:p.slice(0,500)});return {ok:true}}
async function createForgeKey(){const r=await fetch(FORGE_URL+"/api/keys/create",{method:"POST"});const d=await r.json().catch(()=>({}));if(!r.ok||!d.key)throw new Error(d.error||"Forge API Key oluşturulamadı.");accounts?.log("forge.key_created");return {ok:true,key:d.key}}
function stopBridge(){if(bridge&&!bridge.killed){try{bridge.stdin.write("/exit\n")}catch{}setTimeout(()=>{try{if(bridge&&!bridge.killed)bridge.kill()}catch{}},1500)}accounts?.log("bridge.stopped");return {ok:true}}
function b64url(buf){return Buffer.from(buf).toString("base64").replace(/\+/g,"-").replace(/\//g,"_").replace(/=+$/,"")}
function googleLogin(){
 return new Promise(async(resolve,reject)=>{
  const clientId=process.env.GOOGLE_CLIENT_ID||"";
  if(!clientId) return reject(new Error("Google/Gmail girişini etkinleştirmek için GOOGLE_CLIENT_ID gerekli."));
  const verifier=b64url(crypto.randomBytes(32)),challenge=b64url(crypto.createHash("sha256").update(verifier).digest()),state=b64url(crypto.randomBytes(24));
  const server=http.createServer(async(req,res)=>{
   try{
    const u=new URL(req.url,"http://127.0.0.1");
    if(u.pathname!=="/oauth2/callback"){res.writeHead(404);return res.end("Not found")}
    if(u.searchParams.get("state")!==state){res.writeHead(400);return res.end("Invalid state")}
    const code=u.searchParams.get("code");if(!code)throw new Error(u.searchParams.get("error")||"Google authorization failed");
    const token=await fetch("https://oauth2.googleapis.com/token",{method:"POST",headers:{"content-type":"application/x-www-form-urlencoded"},body:new URLSearchParams({client_id:clientId,code,code_verifier:verifier,grant_type:"authorization_code",redirect_uri:redirect})});
    const td=await token.json();if(!token.ok||!td.access_token)throw new Error(td.error_description||"Google token exchange failed");
    const me=await fetch("https://openidconnect.googleapis.com/v1/userinfo",{headers:{Authorization:"Bearer "+td.access_token}});
    const profile=await me.json();if(!me.ok||!profile.sub)throw new Error("Google profile alınamadı");
    const account={id:"google_"+profile.sub,type:"google",name:profile.name||profile.email?.split("@")[0]||"Google User",email:profile.email||null,picture:profile.picture||null,createdAt:new Date().toISOString()};
    accounts.setAccount(account);accounts.log("account.google_login",{email:account.email});
    res.writeHead(200,{"content-type":"text/html; charset=utf-8"});res.end("<h2>Roblox Forge AI</h2><p>Giriş tamamlandı. Bu pencereyi kapatıp uygulamaya dönebilirsin.</p>");
    server.close();resolve(account);
   }catch(err){try{res.writeHead(400,{"content-type":"text/plain"});res.end("Login failed")}catch{}server.close();reject(err)}
  });
  server.listen(0,"127.0.0.1",async()=>{
   const port=server.address().port;redirect="http://127.0.0.1:"+port+"/oauth2/callback";
   const auth="https://accounts.google.com/o/oauth2/v2/auth?"+new URLSearchParams({client_id:clientId,redirect_uri:redirect,response_type:"code",scope:"openid email profile",code_challenge:challenge,code_challenge_method:"S256",state,access_type:"online"}).toString();
   try{await shell.openExternal(auth)}catch(e){server.close();reject(e)}
  });
  let redirect="";
 });
}
function createWindow(){
 win=new BrowserWindow({width:1440,height:920,minWidth:1050,minHeight:700,show:false,backgroundColor:"#05070b",autoHideMenuBar:true,title:"Roblox Forge AI",webPreferences:{preload:path.join(app.getAppPath(),"desktop-preload.cjs"),contextIsolation:true,nodeIntegration:false,sandbox:true}});
 win.once("ready-to-show",()=>win.show());win.webContents.on("did-fail-load",(_e,c,d,u)=>log("LOAD FAIL "+c+" "+d+" "+u));win.webContents.on("render-process-gone",(_e,d)=>log("RENDER GONE "+JSON.stringify(d)));win.webContents.on("console-message",(_e,l,m)=>log("CONSOLE "+l+" "+m));win.loadFile(path.join(app.getAppPath(),"desktop.html")).catch(e=>log("LOADFILE "+e.stack));win.on("closed",()=>{win=null;stopBridge()})
}
const gotLock=app.requestSingleInstanceLock();
if(!gotLock)app.quit();else{
 app.on("second-instance",()=>{if(win){if(win.isMinimized())win.restore();win.focus()}});
 app.whenReady().then(()=>{
  app.setAppUserModelId("com.robloxforge.ai");accounts=new AccountStore(path.join(app.getPath("userData"),"account.json"));accounts.ensureLocal();
  session.defaultSession.setPermissionRequestHandler((_wc,p,cb)=>cb(p==="clipboard-read"||p==="clipboard-sanitized-write"));
  ipcMain.handle("bridge-start",(e,a)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return startBridge(a?.forgeKey,a?.noxeryKey,!!a?.autoDev)});
  ipcMain.handle("bridge-send",(e,p)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return sendCommand(p)});
  ipcMain.handle("bridge-stop",(e)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return stopBridge()});
  ipcMain.handle("bridge-status",(e)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return {state:bridgeState,alive:!!bridge&&!bridge.killed}});
  ipcMain.handle("forge-create-key",async(e)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return createForgeKey()});
  ipcMain.handle("account-get",e=>{if(!trusted(e))throw new Error("Untrusted renderer.");return accounts.getAccount()});
  ipcMain.handle("account-local",e=>{if(!trusted(e))throw new Error("Untrusted renderer.");accounts.ensureLocal();accounts.log("account.local_login");return accounts.getAccount()});
  ipcMain.handle("account-google-login",async e=>{if(!trusted(e))throw new Error("Untrusted renderer.");return await googleLogin()});
  ipcMain.handle("account-logout",e=>{if(!trusted(e))throw new Error("Untrusted renderer.");accounts.ensureLocal();accounts.log("account.logout");return accounts.getAccount()});
  ipcMain.handle("account-setting",(e,a)=>{if(!trusted(e))throw new Error("Untrusted renderer.");accounts.log("setting.changed",{key:a?.key});return accounts.setSetting(String(a?.key||""),a?.value)});
  ipcMain.handle("account-snapshot",e=>{if(!trusted(e))throw new Error("Untrusted renderer.");return accounts.snapshot()});
  ipcMain.handle("account-log",(e,a)=>{if(!trusted(e))throw new Error("Untrusted renderer.");accounts.log(String(a?.action||"event"),a?.detail||{});return {ok:true}});
  ipcMain.handle("credits-add",(e,a)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return accounts.addCredits(a?.amount,a?.source)});
  ipcMain.handle("credits-spend",(e,a)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return accounts.spendCredits(a?.amount,a?.reason)});
  createWindow();
 }).catch(e=>{log("READY "+e.stack);dialog.showErrorBox("Roblox Forge AI başlatılamadı",e.stack||String(e));app.quit()});
 app.on("window-all-closed",()=>{if(process.platform!=="darwin")app.quit()});app.on("before-quit",()=>{try{stopBridge()}catch{}});
}
