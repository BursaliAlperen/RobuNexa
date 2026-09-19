const {contextBridge,ipcRenderer}=require("electron");
function listen(type,handler){const fn=(_,data)=>{try{handler(data)}catch{}};ipcRenderer.on(type,fn);return ()=>ipcRenderer.removeListener(type,fn)}
contextBridge.exposeInMainWorld("robloxForgeDesktop",{
 isDesktop:true,
 start:(noxeryKey,autoDev,model)=>ipcRenderer.invoke("bridge-start",{noxeryKey:String(noxeryKey||""),autoDev:!!autoDev,model:String(model||"gpt-6-astra")}),
 send:(prompt)=>ipcRenderer.invoke("bridge-send",String(prompt||"")),
 stop:()=>ipcRenderer.invoke("bridge-stop"),
 status:()=>ipcRenderer.invoke("bridge-status"),
 testNoxery:(key)=>ipcRenderer.invoke("noxery-test",String(key||"")),models:(key)=>ipcRenderer.invoke("noxery-models",String(key||"")),chat:(apiKey,messages,model)=>ipcRenderer.invoke("noxery-chat",{apiKey:String(apiKey||""),messages,model:String(model||"gpt-6-astra")}),
 account:()=>ipcRenderer.invoke("account-get"),
 getAccount:()=>ipcRenderer.invoke("account-get"),
 localAccount:()=>ipcRenderer.invoke("account-local"),
 localLogin:()=>ipcRenderer.invoke("account-local"),
 googleLogin:()=>ipcRenderer.invoke("account-google-login"),
 logout:()=>ipcRenderer.invoke("account-logout"),
 settings:(key,value)=>ipcRenderer.invoke("account-setting",{key,value}),
 setSetting:(key,value)=>ipcRenderer.invoke("account-setting",{key,value}),
 snapshot:()=>ipcRenderer.invoke("account-snapshot"),
 log:(action,detail)=>ipcRenderer.invoke("account-log",{action,detail}),
 addCredits:(amount,source)=>ipcRenderer.invoke("credits-add",{amount,source}),
 spendCredits:(amount,reason)=>ipcRenderer.invoke("credits-spend",{amount,reason}),
 onEvent:(callback)=>listen("forge-bridge-event",callback)
});