import { Client } from "@modelcontextprotocol/client";
import { StdioClientTransport } from "@modelcontextprotocol/client/stdio";
import process from "node:process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import readline from "node:readline";

const FORGE_URL="https://roblox-forge-ai.hatchable.site";
const CONFIG_DIR=path.join(os.homedir(),".roblox-forge-ai");
const CONFIG_FILE=path.join(CONFIG_DIR,"config.json");

function loadConfig(){try{return JSON.parse(fs.readFileSync(CONFIG_FILE,"utf8"))}catch{return {}}}
function saveConfig(c){try{fs.mkdirSync(CONFIG_DIR,{recursive:true});fs.writeFileSync(CONFIG_FILE,JSON.stringify(c,null,2),"utf8")}catch{}}

async function getKeys(){
 const c=loadConfig();let forge=process.argv[2]||c.forgeKey;let nox=process.argv[3]||c.noxeryKey;let autoDev=process.argv[4]==="1"||c.autoDev===true;let provider=process.argv[5]||c.provider||"noxery";let model=process.argv[6]||c.model||"";
 if(!nox&&process.stdin.isTTY){
  const rl=readline.createInterface({input:process.stdin,output:process.stdout});
  nox=await new Promise(resolve=>rl.question("Noxery API Key: ",v=>{rl.close();resolve(v.trim())}));
 }
 if(!nox)throw Error("Noxery API Key missing.");
 saveConfig({forgeKey:forge||"",noxeryKey:nox,autoDev,provider,model});return {forge,nox,autoDev,provider,model};
}

function studioCommand(){
 if(process.platform==="win32"){
  const local=process.env.LOCALAPPDATA;if(!local)throw Error("LOCALAPPDATA bulunamadi.");
  const mcp=path.join(local,"Roblox","mcp.bat");
  if(!fs.existsSync(mcp))throw Error("Roblox Studio MCP bulunamadi: "+mcp+" | Studio > Assistant > MCP Server'i etkinlestir.");
  return {command:"cmd.exe",args:["/d","/c",mcp]};
 }
 if(process.platform==="darwin")return {command:"/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP",args:[]};
 throw Error("Bu EXE Windows/macOS icin yapilandirildi.");
}

async function connectStudio(){
 const transport=new StdioClientTransport({...studioCommand(),maxBufferSize:50*1024*1024});
 const client=new Client({name:"RobloxForgeAI",version:"3.0.0"});
 transport.onerror=e=>console.error("\n[MCP ERROR]",e?.message||e);
 transport.onclose=()=>console.error("\n[MCP] Connection closed.");
 await client.connect(transport);
 const listed=await client.listTools();
 return {client,transport,tools:listed.tools||[],chatMessages:null};
}

async function askAstra(nox,messages,tools,provider="noxery",model="gpt-6-astra"){
 let last="";
 for(let attempt=1;attempt<=4;attempt++){
  try{
   const c=new AbortController();const timer=setTimeout(()=>c.abort(),90000);
   const base=provider==="lemonade"?"http://127.0.0.1:13305/v1/chat/completions":"https://api.noxery.net/v1/chat/completions";const key=provider==="lemonade"?(process.env.LEMONADE_API_KEY||""):nox;const headers={"Content-Type":"application/json"};if(key)headers.Authorization="Bearer "+key;const r=await fetch(base,{method:"POST",headers,signal:c.signal,body:JSON.stringify({
    model:provider==="lemonade"?model:"gpt-6-astra",messages,temperature:0.15,max_completion_tokens:9000,stream:false,
    tools:tools.map(t=>({type:"function",function:{name:t.name,description:t.description||"",parameters:t.inputSchema||{type:"object",properties:{}}}})),tool_choice:"auto"
   })});
   clearTimeout(timer);const raw=await r.text();let d;try{d=JSON.parse(raw)}catch{throw Error("Noxery invalid JSON: "+raw.slice(0,500))}
   if(!r.ok)throw Error("Noxery API "+r.status+": "+JSON.stringify(d).slice(0,1000));
   return d;
  }catch(e){last=String(e?.message||e);if(attempt<4)await new Promise(r=>setTimeout(r,1500*attempt))}
 }
 throw Error(last||"Noxery API request failed");
}

async function runPrompt(nox,session,prompt,autoDev=false,actionMeta=null,provider="noxery",model="gpt-6-astra"){
 const system=[
  "You are GPT-6 Astra, the lead AI game-development director controlling the REAL open Roblox Studio through its MCP server. You are not a generic chatbot and must work against the actual current Studio project.",
  "MANDATORY: First inspect the live Studio session and DataModel before proposing or changing anything. Use list_roblox_studios, get_studio_state and relevant Explorer/script/screenshot tools available.",
  "Determine whether the place is EMPTY/BASEPLATE-LIKE or an EXISTING PROJECT. Inspect Workspace, ReplicatedStorage, ServerScriptService, StarterPlayer, StarterGui, Lighting, SoundService, Teams, ServerStorage and important scripts/assets.",
  "For an EXISTING PROJECT, produce an AAA audit: current systems, architecture, scripts, UI, map, assets, VFX/SFX, mobile support, performance risks, missing systems, bugs, retention loops and concrete upgrade opportunities. Preserve working systems unless asked to replace them.",
  "For an EMPTY project, do not blindly build a random game. Generate 3-5 original, buildable Roblox concepts inspired by successful gameplay patterns, with core loop, viral hook, replayability, social loop, progression and feasible monetization options.",
  "When asked for a plan, internally run specialist passes: Product/Trend Scout, Game Designer, Systems Architect, Luau Engineer, World Builder, UI/UX Designer, Creator Store Asset Scout, VFX/SFX Director, Economy/Retention Designer, Mobile/Performance Engineer and QA/Playtest Engineer. Synthesize one coherent plan.",
  "Every AAA plan includes: game fantasy, 10-second hook, core loop, minute-to-minute loop, map zones, systems, data model, script tree, UI tree, mobile controls, Creator Store asset strategy, VFX/SFX direction, progression, economy, social/viral mechanics, monetization, onboarding, retention, anti-exploit basics, optimization, QA tests and phased build order.",
  "For build/fix requests after explicit approval, use real MCP tools and execute ONLY the currently approved phase. You are the dedicated Roblox production agent: implement real Studio changes, never a mockup. Use LocalScripts for UI/input/camera/client VFX, Scripts for server authority/DataStore/remotes/anti-exploit, ModuleScripts for shared logic. Create and wire every required Instance, folder, RemoteEvent/RemoteFunction, reference, animation, sound, VFX, cleanup and integration. Read existing scripts before editing and preserve compatible systems.",
  "STUDDED GUI: when requested, actually construct the GUI in Studio with real ScreenGui, Frame, ImageLabel, ImageButton, TextLabel, UIStroke, UICorner and suitable stud textures/decals. Search available Creator Store/MCP asset tools for stud textures, cartoon icons and decals; use exact returned asset IDs/names and never invent IDs. Ensure consistent icon style, hover/press states, mobile touch targets and safe-area placement.",
  "ASSETS: search Creator Store before using external models, textures, icons, VFX or SFX when appropriate. Evaluate relevance and compatibility; avoid random assets. If no suitable asset exists, use a native/procedural fallback and report it.",
  "COMPLETENESS: never stop at a visual mockup. For every approved phase implement the complete connected feature, then inspect hierarchy/scripts, playtest, inspect Output/errors and fix failures before declaring completion.","For build/fix requests after explicit approval, use real MCP tools and execute ONLY the currently approved phase. Read existing scripts before editing. Playtest and inspect console output after important changes. Never claim success without tool evidence. When the approved phase is finished, STOP, report the verified result, and ask for approval for the next phase. Do not continue automatically.",
  "Be technical and specific. Prefer simple robust systems over fake complexity. Use studded/dark premium UI when style is unspecified, PC + mobile support, and Creator Store assets where appropriate.",
  "Remember the current session conversation context and previous Studio findings instead of restarting from zero.",
  "For analysis/plan requests, separate CURRENT PROJECT AUDIT, OPPORTUNITIES, AAA PLAN, BUILD PHASES and NEXT ACTION. For ANY request that would modify Studio, first produce the plan and STOP for explicit approval unless the user message contains an explicit approval phrase such as PLAN KABUL EDİLDİ, ETABI KABUL ET or APPROVED. Never modify Studio merely because the user asked for a feature; the approval gate is mandatory unless AUTO DEVELOPMENT MODE is explicitly enabled by the desktop user."
 ].join("\n");
 let messages=session.chatMessages||[{role:"system",content:system}],trace=[]; if(autoDev){messages[0].content+="\nAUTO DEVELOPMENT MODE IS EXPLICITLY ENABLED BY THE USER. You may autonomously choose and execute one small, high-value improvement at a time without asking for approval, but only after inspecting the live project. Never delete or replace working systems unnecessarily. After each completed improvement, verify it, log the result, then continue only if the next improvement is clearly safe and connected."; }
 session.chatMessages=messages;
 messages.push({role:"user",content:prompt});
 for(let i=0;i<80;i++){
  const d=await askAstra(nox,messages,session.tools,provider,model);const m=d?.choices?.[0]?.message||{};
  if(m.tool_calls?.length){
   messages.push(m);
   for(const tc of m.tool_calls){
    const name=tc?.function?.name;let args={};try{args=JSON.parse(tc?.function?.arguments||"{}")}catch{throw Error("Astra invalid tool arguments: "+name)}
    if(!session.tools.find(x=>x.name===name))throw Error("Unknown MCP tool: "+name);
    if(actionMeta){console.log("\n[ACTION "+String(actionMeta.index).padStart(3,"0")+"/"+String(actionMeta.total).padStart(3,"0")+" TOOL] "+name)} else {console.log("\n[MCP] "+name)}const result=await session.client.callTool({name,arguments:args});
    trace.push({tool:name,ok:!result?.isError});messages.push({role:"tool",tool_call_id:tc.id,content:JSON.stringify(result).slice(0,30000)});
   }continue;
  }
  const content=String(m.content||"").trim();
  if(content)return {summary:content,steps:trace};
  throw Error("Astra returned empty response.");
 }
 throw Error("Astra step limit reached.");
}
async function postForge(pathname,body,forge){
 return fetch(FORGE_URL+pathname,{method:"POST",headers:{"Content-Type":"application/json","x-forge-key":forge},body:JSON.stringify(body)});
}

async function postActivity(forge,level,event,detail="",job_id=null){try{await postForge("/api/activity",{level,event,detail,job_id},forge)}catch{}}

function speakAction(text){
 try{
  if(process.platform!=="win32")return;
  const {spawn}=await import("node:child_process");
  const safe=String(text||"").replace(/"/g,'\\\"');
  spawn("powershell.exe",["-NoProfile","-Command","Add-Type -AssemblyName System.Speech; $s=New-Object System.Speech.Synthesis.SpeechSynthesizer; $s.Speak(\""+safe+"\")"],{windowsHide:true,stdio:"ignore"});
 }catch{}
}
async function createForgePlan(nox,session,prompt,provider="noxery",model="gpt-6-astra"){
 const messages=[
  {role:"system",content:"You are the Roblox Forge AI planning engine. Do not call tools. Return ONLY valid JSON in this exact shape: {\\"summary\\":\\"...\\",\\"actions\\":[{\\"title\\":\\"...\\",\\"goal\\":\\"...\\",\\"verification\\":\\"...\\"}]}. Create 5 to 10 small, ordered, verifiable actions. The first action must inspect/analyze the live Roblox Studio project. Separate planning from implementation."},
  {role:"user",content:prompt}
 ];
 const d=await askAstra(nox,messages,[],provider,model)
 let raw=String(d?.choices?.[0]?.message?.content||"").trim().replace("\\`\\`\\`json","").replace("\\`\\`\\`","").trim();
 let plan;try{plan=JSON.parse(raw)}catch(e){throw Error("Forge planner JSON invalid: "+raw.slice(0,1000))}
 if(!Array.isArray(plan.actions)||plan.actions.length<1)throw Error("Forge planner returned no actions.");
 plan.actions=plan.actions.slice(0,10);
 return plan;
}
async function runPlannedForge(nox,session,prompt,autoDev=false,provider="noxery",model="gpt-6-astra"){
 const plan=await createForgePlan(nox,session,prompt,provider,model);
 const total=plan.actions.length;
 console.log("\\n[PLAN 0/"+total+"] "+String(plan.summary||"Forge plan hazır."));
 console.log("[PLAN JSON] "+JSON.stringify(plan));
 speakAction("Plan hazır. "+total+" action çalıştırılacak.");
 const results=[];
 for(let i=0;i<total;i++){
  const a=plan.actions[i], index=i+1;
  const title=String(a.title||"Forge action");
  console.log("\\n[ACTION "+String(index).padStart(3,"0")+"/"+String(total).padStart(3,"0")+" START] "+title);
  speakAction(String(index).padStart(3,"0")+". "+title);
  try{
   const instruction="PLAN KABUL EDİLDİ. EXECUTE ONLY THIS APPROVED FORGE ACTION. Do not begin any other action.\\nACTION "+String(index).padStart(3,"0")+" / "+String(total).padStart(3,"0")+"\\nTITLE: "+title+"\\nGOAL: "+String(a.goal||"")+"\\nVERIFICATION: "+String(a.verification||"")+"\\nUse real Roblox Studio MCP tools. Inspect before modifying. Verify the result with tools. Return a concise evidence-based result.";
   const r=await runPrompt(nox,session,instruction,autoDev,{index,total},provider,model);
   results.push({id:String(index).padStart(3,"0"),title,result:r.summary});
   console.log("\\n[ACTION "+String(index).padStart(3,"0")+"/"+String(total).padStart(3,"0")+" SUCCESS] "+title);
   speakAction(String(index).padStart(3,"0")+". tamamlandı.");
  }catch(e){
   console.log("\\n[ACTION "+String(index).padStart(3,"0")+"/"+String(total).padStart(3,"0")+" FAILED] "+String(e?.message||e));
   speakAction(String(index).padStart(3,"0")+". başarısız oldu.");
   throw e;
  }
 }
 console.log("\\n[FORGE COMPLETE "+total+"/"+total+"]");
 speakAction("Forge tamamlandı. "+total+" action başarıyla tamamlandı.");
 return {summary:plan.summary||"Forge tamamlandı.",plan,results};
}
async function jobLoop(forge,nox,session,autoDev=false,provider="noxery",model="gpt-6-astra"){
 if(!forge)return;
 const heartbeat=async(status,extra={})=>{try{await postForge("/api/bridge/heartbeat",{status,platform:process.platform,tools:session.tools.length,version:"3.1.0",auto_dev:autoDev,...extra},forge)}catch{}};
 await heartbeat("online");setInterval(()=>heartbeat("online"),10000);
 while(true){
  try{
   const r=await postForge("/api/jobs/claim",{},forge);const d=await r.json();
   if(d.job){
    try{
     await heartbeat("working",{job_id:d.job.id});
     await postActivity(forge,"info","JOB STARTED",d.job.prompt,d.job.id);
     const result=await runPlannedForge(nox,session,d.job.prompt,autoDev,provider,model);
     await postForge("/api/jobs/complete",{id:d.job.id,status:"completed",result},forge);
     await postActivity(forge,"info","JOB COMPLETED",String(result.summary||"").slice(0,3500),d.job.id);
     await heartbeat("online");console.log("\n[SITE JOB COMPLETED] "+d.job.id);
    }catch(e){
     const msg=String(e?.message||e);
     await postForge("/api/jobs/complete",{id:d.job.id,status:"failed",result:null,error:msg},forge);
     await postActivity(forge,"error","JOB FAILED",msg,d.job.id);
     console.error("\n[SITE JOB FAILED] "+msg);
    }
   } else if(autoDev){
    try{
     await heartbeat("auto_working",{auto_dev:true});
     const autoPrompt=`AUTO DEVELOPMENT MODE — AUTONOMOUS BUILD CYCLE.
You are the senior Roblox product engineer responsible for improving the LIVE Roblox Studio project while the user is away.

MISSION:
1. Inspect the LIVE DataModel first. Never guess the project state.
2. Audit current systems, scripts, UI, map, assets, VFX/SFX, mobile controls, performance and errors.
3. Choose EXACTLY ONE safe, high-value improvement or bug fix for this cycle.
4. Internally create a concrete mini-plan: goal, affected Instances/scripts, client/server responsibilities, dependencies, Creator Store assets needed, acceptance checks and rollback-safe approach.
5. Execute that plan completely with real Roblox Studio MCP tools.
6. Use proper LocalScripts for client UI/input/camera/client VFX, Scripts for server authority/DataStore/remotes/anti-exploit, and ModuleScripts for shared logic.
7. For STUDDED GUI, actually create the required ScreenGui/Frames/ImageLabels/ImageButtons/TextLabels/UIStrokes/UICorners and search available Creator Store/MCP asset tools for suitable stud textures, cartoon icons and decals. Use exact returned asset IDs; never invent IDs.
8. Wire every dependency: folders, remotes, references, animations, sounds, VFX, cleanup and integration. Do not leave placeholders or disconnected mockups.
9. Preserve working systems. Do not delete/rewrite unrelated code.
10. Playtest/inspect Output and fix errors. Re-test the changed feature.
11. Write a concise completion report with what changed, files/Instances touched, verification evidence and any remaining limitation.
12. If there is no safe improvement, perform an audit only and report why.

IMPORTANT:
- Do NOT ask the user for approval in this mode; Auto Development is an explicit user opt-in.
- Never make destructive economy/data resets, delete major systems, publish external content, or spend Robux without an explicit user request.
- One cycle = one coherent improvement. Stop that cycle after verification and log it.
- Then wait for the next cycle.

Begin by inspecting the live Studio project now.`;
     await postActivity(forge,"info","AUTO DEVELOPMENT STARTED","Astra live audit + one improvement cycle başlıyor.");
     const result=await runPrompt(nox,session,autoPrompt,true);
     await postActivity(forge,"info","AUTO DEVELOPMENT COMPLETED",String(result.summary||"").slice(0,3500));
     await heartbeat("online",{auto_dev:true});
    }catch(e){
     const msg=String(e?.message||e);
     await postActivity(forge,"error","AUTO DEVELOPMENT ERROR",msg.slice(0,3500));
     await heartbeat("online",{auto_dev:true,error:msg.slice(0,1000)});
    }
   }
  }catch(e){console.error("\n[JOB LOOP] "+(e?.message||e))}
  await new Promise(r=>setTimeout(r,2500));
 }
}

async function main(){
 console.log("========================================\n Roblox Forge AI Bridge v3\n========================================");
 const {forge,nox,autoDev,provider:configuredProvider,model:configuredModel}=await getKeys();const provider=process.env.FORGE_PROVIDER||configuredProvider||"noxery";const model=process.env.FORGE_MODEL||configuredModel||(provider==="lemonade"?"auto":"gpt-6-astra");let session;
 for(let attempt=1;;attempt++){
  try{console.log("\n[1/2] Roblox Studio MCP baglaniyor...");session=await connectStudio();console.log("[OK] Studio baglandi. MCP tools: "+session.tools.length);break}
  catch(e){console.error("[MCP] Baglanti basarisiz: "+(e?.message||e));if(attempt>=5)throw e;console.log("Studio MCP yeniden deneniyor...");await new Promise(r=>setTimeout(r,3000))}
 }
 console.log("[2/2] Astra hazir.");
 console.log("[AUTO] Studio MCP baglantisi kuruldu. Forge AI plan/approval pipeline hazir.");
 console.log("\nKomut yaz ve Enter'a bas:");
 console.log("  > PLAN: oyunu analiz et ve AAA plan hazirla");
 console.log("  > create a studded lobby with 3 portals");
 console.log("  > add a mobile inventory UI");
 console.log("  > /status");
 console.log("  > /exit\n");
 if(forge){jobLoop(forge,nox,session,autoDev,provider,model).catch(e=>console.error("[SITE]",e)); await postActivity(forge,"info","BRIDGE CONNECTED",`Studio MCP connected; Auto Development=${autoDev?"ON":"OFF"}`);}

 const rl=readline.createInterface({input:process.stdin,output:process.stdout,prompt:"RobloxForgeAI > "});
 rl.prompt();
 rl.on("line",async line=>{
  const prompt=line.trim();if(!prompt){rl.prompt();return}
  if(prompt==="/exit"){await session.client.close().catch(()=>{});rl.close();return}
  if(prompt==="/status"){console.log("[STATUS] Studio MCP connected | tools="+session.tools.length+" | Astra=ready");rl.prompt();return}
  try{rl.pause();const result=await runPlannedForge(nox,session,prompt,autoDev,provider,model);console.log("\n[COMPLETED] "+result.summary);console.log("[ACTIONS] "+result.results.length)}
  catch(e){console.error("\n[ERROR] "+(e?.message||e))}
  rl.resume();rl.prompt();
 });
 rl.on("close",()=>process.exit(0));
}
main().catch(e=>{console.error("\n[FATAL] "+(e?.message||e));process.exit(1)});
