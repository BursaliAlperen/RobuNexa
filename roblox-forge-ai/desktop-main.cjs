const {app,BrowserWindow,ipcMain,session}=require("electron");
const {spawn}=require("node:child_process");
const path=require("node:path");
const FORGE_URL="https://roblox-forge-ai.hatchable.site";
const START_URL=FORGE_URL+"/?desktop=1";
let win=null,bridge=null,bridgeState="offline";
function trusted(event){const u=event.senderFrame?.url||"";return u===FORGE_URL||u.startsWith(FORGE_URL+"/");}
function emit(type,data){if(win&&!win.isDestroyed())win.webContents.send("forge-bridge-event",{type,...data});}
function setState(state,detail=""){bridgeState=state;emit("state",{state,detail});}
function startBridge(forgeKey,noxeryKey){forgeKey=String(forgeKey||"").trim();noxeryKey=String(noxeryKey||"").trim();if(!noxeryKey)throw new Error("Noxery API Key gerekli.");if(bridge&&!bridge.killed)return {ok:true,state:bridgeState};const bridgePath=path.join(process.resourcesPath,"bridge.cjs");bridge=spawn(process.execPath,[bridgePath,forgeKey,noxeryKey],{env:{...process.env,ELECTRON_RUN_AS_NODE:"1",ELECTRON_NO_ATTACH_CONSOLE:"1",ELECTRON_NO_ASAR:"1"},stdio:["pipe","pipe","pipe"],windowsHide:true});setState("starting","Roblox Studio MCP başlatılıyor...");bridge.stdout.on("data",b=>emit("log",{stream:"stdout",text:String(b)}));bridge.stderr.on("data",b=>emit("log",{stream:"stderr",text:String(b)}));bridge.on("error",e=>setState("error",e.message));bridge.on("close",(code,signal)=>{bridge=null;setState(code===0?"offline":"error",code===0?"Bridge kapandı.":"Bridge kapandı: code="+code+" signal="+(signal||""));});return {ok:true,state:"starting"};}
function sendCommand(prompt){if(!bridge||bridge.killed||!bridge.stdin.writable)throw new Error("Bridge bağlı değil.");const p=String(prompt||"").trim();if(!p)return {ok:false};bridge.stdin.write(p+"\n");emit("log",{stream:"command",text:"> "+p});return {ok:true};}
function stopBridge(){if(bridge&&!bridge.killed){try{bridge.stdin.write("/exit\n")}catch{}setTimeout(()=>{if(bridge&&!bridge.killed)bridge.kill();},1200);}return {ok:true};}
const gotLock=app.requestSingleInstanceLock();if(!gotLock)app.quit();
app.whenReady().then(()=>{session.defaultSession.setPermissionRequestHandler((_wc,permission,callback)=>callback(permission==="clipboard-read"||permission==="clipboard-sanitized-write"));ipcMain.handle("bridge-start",(e,a)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return startBridge(a?.forgeKey,a?.noxeryKey);});ipcMain.handle("bridge-send",(e,p)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return sendCommand(p);});ipcMain.handle("bridge-stop",(e)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return stopBridge();});ipcMain.handle("bridge-status",(e)=>{if(!trusted(e))throw new Error("Untrusted renderer.");return {state:bridgeState,alive:!!bridge&&!bridge.killed};});
win=new BrowserWindow({width:1440,height:920,minWidth:1050,minHeight:700,backgroundColor:"#05070b",autoHideMenuBar:true,title:"Roblox Forge AI",webPreferences:{preload:path.join(app.getAppPath(),"desktop-preload.cjs"),contextIsolation:true,nodeIntegration:false,sandbox:true,webSecurity:true}});
win.setMenuBarVisibility(false);win.loadURL(START_URL);win.on("closed",()=>{win=null;stopBridge();});});
app.on("window-all-closed",()=>{if(process.platform!=="darwin")app.quit();});
app.on("before-quit",()=>{if(bridge&&!bridge.killed){try{bridge.stdin.write("/exit\n")}catch{}try{bridge.kill()}catch{}}});