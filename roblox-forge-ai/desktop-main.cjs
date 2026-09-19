const {app,BrowserWindow,ipcMain,session,dialog}=require("electron");
const {spawn}=require("node:child_process");
const path=require("node:path");
const fs=require("node:fs");
const FORGE_URL="https://roblox-forge-ai.hatchable.site";
let win=null,bridge=null,bridgeState="offline";
function logFile(){try{return path.join(app.getPath("userData"),"startup.log")}catch{return path.join(process.cwd(),"startup.log")}}
function log(x){try{fs.appendFileSync(logFile(),new Date().toISOString()+" "+x+"\n")}catch{}}
process.on("uncaughtException",e=>{log("UNCAUGHT "+e.stack);});
process.on("unhandledRejection",e=>{log("REJECTION "+(e?.stack||e));});
function trusted(e){const u=e.senderFrame?.url||"";return u.startsWith("file://")||u===FORGE_URL||u.startsWith(FORGE_URL+"/");}
function emit(type,data){if(win&&!win.isDestroyed())win.webContents.send("forge-bridge-event",{type,...data});}
function setState(state,detail=""){bridgeState=state;emit("state",{state,detail});}
function startBridge(forgeKey,noxeryKey){
 forgeKey=String(forgeKey||"").trim();noxeryKey=String(noxeryKey||"").trim();
 if(!noxeryKey)throw new Error("Noxery API Key gerekli.");
 if(bridge&&!bridge.killed)return {ok:true,state:bridgeState};
 const bridgePath=path.join(process.resourcesPath,"bridge.cjs");
 if(!fs.existsSync(bridgePath))throw new Error("Bridge runtime bulunamadı: "+bridgePath);
 bridge=spawn(process.execPath,[bridgePath,forgeKey,noxeryKey],{env:{...process.env,ELECTRON_RUN_AS_NODE:"1",ELECTRON_NO_ASAR:"1"},stdio:["pipe","pipe","pipe"],windowsHide:false});
 setState("starting","Roblox Studio MCP başlatılıyor...");
 bridge.stdout.on("data",b=>emit("log",{stream:"stdout",text:String(b)}));
 bridge.stderr.on("data",b=>emit("log",{stream:"stderr",text:String(b)}));
 bridge.on("error",e=>{log("BRIDGE ERROR "+e.stack);setState("error",e.message)});
 bridge.on("close",(code,signal)=>{bridge=null;setState(code===0?"offline":"error","Bridge kapandı: code="+code+" signal="+(signal||""));});
 return {ok:true,state:"starting"};
}
function sendCommand(p){if(!bridge||bridge.killed||!bridge.stdin.writable)throw new Error("Bridge bağlı değil.");p=String(p||"").trim();if(!p)return {ok:false};bridge.stdin.write(p+"\n");emit("log",{stream:"command",text:"> "+p});return {ok:true};}
async function createForgeKey(){const r=await fetch(FORGE_URL+"/api/keys/create",{method:"POST"});const d=await r.json().catch(()=>({}));if(!r.ok||!d.key)throw new Error(d.error||"Forge API Key oluşturulamadı.");return {ok:true,key:d.key};}
function stopBridge(){if(bridge&&!bridge.killed){try{bridge.stdin.write("/exit\n")}catch{}setTimeout(()=>{try{if(bridge&&!bridge.killed)bridge.kill()}catch{}},1500)}return {ok:true};}
function createWindow(){
 win=new BrowserWindow({width:1440,height:920,minWidth:1050,minHeight:700,show:false,backgroundColor:"#05070b",autoHideMenuBar:true,title:"Roblox Forge AI",webPreferences:{preload:path.join(app.getAppPath(),"desktop-preload.cjs"),contextIsolation:true,nodeIntegration:false,sandbox:true,webSecurity:true}});
 win.once("ready-to-show",()=>win.show());
 win.webContents.on("did-fail-load",(_e,code,desc,url)=>{log("LOAD FAIL "+code+" "+desc+" "+url);});
 win.webContents.on("render-process-gone",(_e,d)=>{log("RENDER GONE "+JSON.stringify(d));});
 win.webContents.on("console-message",(_e,l,m)=>log("CONSOLE "+l+" "+m));
 win.loadFile(path.join(app.getAppPath(),"desktop.html")).catch(e=>log("LOADFILE "+e.stack));
 win.on("closed",()=>{win=null;stopBridge()});
}
const gotLock=app.requestSingleInstanceLock();
if(!gotLock){app.quit();}else{
 app.on("second-instance",()=>{if(win){if(win.isMinimized())win.restore();win.focus();}});
 app.whenReady().then(()=>{
  app.setAppUserModelId("com.robloxforge.ai");
  session.defaultSession.setPermissionRequestHandler((_wc,p,cb)=>cb(p==="clipboard-read"||p==="clipboard-sanitized-write"));
  ipcMain.handle("bridge-start",(e,a)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return startBridge(a?.forgeKey,a?.noxeryKey)});
  ipcMain.handle("bridge-send",(e,p)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return sendCommand(p)});
  ipcMain.handle("bridge-stop",(e)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return stopBridge()});
  ipcMain.handle("bridge-status",(e)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return {state:bridgeState,alive:!!bridge&&!bridge.killed}});
  ipcMain.handle("forge-create-key",async(e)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return createForgeKey();});
  createWindow();
 }).catch(e=>{log("READY "+e.stack);dialog.showErrorBox("Roblox Forge AI başlatılamadı",e.stack||String(e));app.quit();});
 app.on("window-all-closed",()=>{if(process.platform!=="darwin")app.quit()});
 app.on("before-quit",()=>{try{stopBridge()}catch{}});
}
