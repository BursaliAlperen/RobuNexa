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
 const c=loadConfig();let forge=process.argv[2]||c.forgeKey;let nox=process.argv[3]||c.noxeryKey;
 if(!nox&&process.stdin.isTTY){
  const rl=readline.createInterface({input:process.stdin,output:process.stdout});
  nox=await new Promise(resolve=>rl.question("Noxery API Key: ",v=>{rl.close();resolve(v.trim())}));
 }
 if(!nox)throw Error("Noxery API Key missing.");
 saveConfig({forgeKey:forge||"",noxeryKey:nox});return {forge,nox};
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

async function askAstra(nox,messages,tools){
 let last="";
 for(let attempt=1;attempt<=4;attempt++){
  try{
   const c=new AbortController();const timer=setTimeout(()=>c.abort(),90000);
   const r=await fetch("https://api.noxery.net/v1/chat/completions",{method:"POST",headers:{"Authorization":"Bearer "+nox,"Content-Type":"application/json"},signal:c.signal,body:JSON.stringify({
    model:"gpt-6-astra",messages,temperature:0.15,max_completion_tokens:9000,stream:false,
    tools:tools.map(t=>({type:"function",function:{name:t.name,description:t.description||"",parameters:t.inputSchema||{type:"object",properties:{}}}})),tool_choice:"auto"
   })});
   clearTimeout(timer);const raw=await r.text();let d;try{d=JSON.parse(raw)}catch{throw Error("Noxery invalid JSON: "+raw.slice(0,500))}
   if(!r.ok)throw Error("Noxery API "+r.status+": "+JSON.stringify(d).slice(0,1000));
   return d;
  }catch(e){last=String(e?.message||e);if(attempt<4)await new Promise(r=>setTimeout(r,1500*attempt))}
 }
 throw Error(last||"Noxery API request failed");
}

async function runPrompt(nox,session,prompt){
 const system=[
  "You are GPT-6 Astra, the lead AI game-development director controlling the REAL open Roblox Studio through its MCP server. You are not a generic chatbot and must work against the actual current Studio project.",
  "MANDATORY: First inspect the live Studio session and DataModel before proposing or changing anything. Use list_roblox_studios, get_studio_state and relevant Explorer/script/screenshot tools available.",
  "Determine whether the place is EMPTY/BASEPLATE-LIKE or an EXISTING PROJECT. Inspect Workspace, ReplicatedStorage, ServerScriptService, StarterPlayer, StarterGui, Lighting, SoundService, Teams, ServerStorage and important scripts/assets.",
  "For an EXISTING PROJECT, produce an AAA audit: current systems, architecture, scripts, UI, map, assets, VFX/SFX, mobile support, performance risks, missing systems, bugs, retention loops and concrete upgrade opportunities. Preserve working systems unless asked to replace them.",
  "For an EMPTY project, do not blindly build a random game. Generate 3-5 original, buildable Roblox concepts inspired by successful gameplay patterns, with core loop, viral hook, replayability, social loop, progression and feasible monetization options.",
  "When asked for a plan, internally run specialist passes: Product/Trend Scout, Game Designer, Systems Architect, Luau Engineer, World Builder, UI/UX Designer, Creator Store Asset Scout, VFX/SFX Director, Economy/Retention Designer, Mobile/Performance Engineer and QA/Playtest Engineer. Synthesize one coherent plan.",
  "Every AAA plan includes: game fantasy, 10-second hook, core loop, minute-to-minute loop, map zones, systems, data model, script tree, UI tree, mobile controls, Creator Store asset strategy, VFX/SFX direction, progression, economy, social/viral mechanics, monetization, onboarding, retention, anti-exploit basics, optimization, QA tests and phased build order.",
  "For build/fix requests after explicit approval, use real MCP tools and execute ONLY the currently approved phase. You are the dedicated Roblox production agent: implement real Studio changes, never a mockup. Use LocalScripts for UI/input/camera/client VFX, Scripts for server authority/DataStore/remotes/anti-exploit, ModuleScripts for shared logic. Create and wire every required Instance, folder, RemoteEvent/RemoteFunction, reference, animation, sound, VFX, cleanup and integration. Read existing scripts before editing and preserve compatible systems.",\n  "STUDDED GUI: when requested, actually construct the GUI in Studio with real ScreenGui, Frame, ImageLabel, ImageButton, TextLabel, UIStroke, UICorner and suitable stud textures/decals. Search available Creator Store/MCP asset tools for stud textures, cartoon icons and decals; use exact returned asset IDs/names and never invent IDs. Ensure consistent icon style, hover/press states, mobile touch targets and safe-area placement.",\n  "ASSETS: search Creator Store before using external models, textures, icons, VFX or SFX when appropriate. Evaluate relevance and compatibility; avoid random assets. If no suitable asset exists, use a native/procedural fallback and report it.",\n  "COMPLETENESS: never stop at a visual mockup. For every approved phase implement the complete connected feature, then inspect hierarchy/scripts, playtest, inspect Output/errors and fix failures before declaring completion.","For build/fix requests after explicit approval, use real MCP tools and execute ONLY the currently approved phase. Read existing scripts before editing. Playtest and inspect console output after important changes. Never claim success without tool evidence. When the approved phase is finished, STOP, report the verified result, and ask for approval for the next phase. Do not continue automatically.",
  "Be technical and specific. Prefer simple robust systems over fake complexity. Use studded/dark premium UI when style is unspecified, PC + mobile support, and Creator Store assets where appropriate.",
  "Remember the current session conversation context and previous Studio findings instead of restarting from zero.",
  "For analysis/plan requests, separate CURRENT PROJECT AUDIT, OPPORTUNITIES, AAA PLAN, BUILD PHASES and NEXT ACTION. For ANY request that would modify Studio, first produce the plan and STOP for explicit approval unless the user message contains an explicit approval phrase such as PLAN KABUL EDİLDİ, ETABI KABUL ET or APPROVED. Never modify Studio merely because the user asked for a feature; the approval gate is mandatory."
 ].join("\n");
 let messages=session.chatMessages||[{role:"system",content:system}],trace=[];
 session.chatMessages=messages;
 messages.push({role:"user",content:prompt});
 for(let i=0;i<80;i++){
  const d=await askAstra(nox,messages,session.tools);const m=d?.choices?.[0]?.message||{};
  if(m.tool_calls?.length){
   messages.push(m);
   for(const tc of m.tool_calls){
    const name=tc?.function?.name;let args={};try{args=JSON.parse(tc?.function?.arguments||"{}")}catch{throw Error("Astra invalid tool arguments: "+name)}
    if(!session.tools.find(x=>x.name===name))throw Error("Unknown MCP tool: "+name);
    console.log("\n[MCP] "+name);const result=await session.client.callTool({name,arguments:args});
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

async function jobLoop(forge,nox,session){
 if(!forge)return;
 const heartbeat=async(status,extra={})=>{try{await postForge("/api/bridge/heartbeat",{status,platform:process.platform,tools:session.tools.length,version:"3.0.0",...extra},forge)}catch{}};
 await heartbeat("online");setInterval(()=>heartbeat("online"),10000);
 while(true){
  try{
   const r=await postForge("/api/jobs/claim",{},forge);const d=await r.json();
   if(d.job){
    try{
     await heartbeat("working",{job_id:d.job.id});
     const result=await runPrompt(nox,session,d.job.prompt);
     await postForge("/api/jobs/complete",{id:d.job.id,status:"completed",result},forge);
     await heartbeat("online");console.log("\n[SITE JOB COMPLETED] "+d.job.id);
    }catch(e){
     const msg=String(e?.message||e);
     await postForge("/api/jobs/complete",{id:d.job.id,status:"failed",result:null,error:msg},forge);
     console.error("\n[SITE JOB FAILED] "+msg);
    }
   }
  }catch(e){console.error("\n[JOB LOOP] "+(e?.message||e))}
  await new Promise(r=>setTimeout(r,2500));
 }
}

async function main(){
 console.log("========================================\n Roblox Forge AI Bridge v3\n========================================");
 const {forge,nox}=await getKeys();let session;
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
 if(forge)jobLoop(forge,nox,session).catch(e=>console.error("[SITE]",e));

 const rl=readline.createInterface({input:process.stdin,output:process.stdout,prompt:"RobloxForgeAI > "});
 rl.prompt();
 rl.on("line",async line=>{
  const prompt=line.trim();if(!prompt){rl.prompt();return}
  if(prompt==="/exit"){await session.client.close().catch(()=>{});rl.close();return}
  if(prompt==="/status"){console.log("[STATUS] Studio MCP connected | tools="+session.tools.length+" | Astra=ready");rl.prompt();return}
  try{rl.pause();const result=await runPrompt(nox,session,prompt);console.log("\n[COMPLETED] "+result.summary);console.log("[MCP CALLS] "+result.steps.length)}
  catch(e){console.error("\n[ERROR] "+(e?.message||e))}
  rl.resume();rl.prompt();
 });
 rl.on("close",()=>process.exit(0));
}
main().catch(e=>{console.error("\n[FATAL] "+(e?.message||e));process.exit(1)});
