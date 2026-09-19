import { Client } from "@modelcontextprotocol/client";
import { StdioClientTransport } from "@modelcontextprotocol/client/stdio";
import process from "node:process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const FORGE_URL="https://roblox-forge-ai.hatchable.site";
const CONFIG_DIR=path.join(os.homedir(),".roblox-forge-ai");
const CONFIG_FILE=path.join(CONFIG_DIR,"config.json");
function loadConfig(){try{return JSON.parse(fs.readFileSync(CONFIG_FILE,"utf8"))}catch{return {}}}
function saveConfig(c){try{fs.mkdirSync(CONFIG_DIR,{recursive:true});fs.writeFileSync(CONFIG_FILE,JSON.stringify(c,null,2),"utf8")}catch{}}
async function getKeys(){
 const c=loadConfig();let forge=process.argv[2]||c.forgeKey;let nox=process.argv[3]||c.noxeryKey;
 if(!forge||!nox){
  if(process.stdin.isTTY){const readline=await import("node:readline/promises");const rl=readline.createInterface({input:process.stdin,output:process.stdout});if(!forge)forge=(await rl.question("Forge API Key: ")).trim();if(!nox)nox=(await rl.question("Noxery API Key: ")).trim();rl.close()}
 }
 if(!forge||!nox)throw Error("Keys missing. Run with FORGE_KEY and NOXERY_KEY or enter them on first launch.");
 saveConfig({forgeKey:forge,noxeryKey:nox});return {forge,nox};
}
async function connectStudio(){
 if(process.platform==="win32"){const mcp=path.join(os.homedir(),"AppData","Local","Roblox","mcp.bat");if(!fs.existsSync(mcp))throw Error("Roblox Studio MCP not found: "+mcp+" . Enable Studio as MCP Server first.");return new StdioClientTransport({command:"cmd.exe",args:["/d","/s","/c",'"'+mcp+'"']})}
 if(process.platform==="darwin")return new StdioClientTransport({command:"/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP",args:[]});
 throw Error("Linux bridge is not configured for Roblox Studio MCP.");
}
async function main(){
 const {forge,nox}=await getKeys();const client=new Client({name:"RobloxForgeAI",version:"2.0.0"});await client.connect(await connectStudio());
 const listed=await client.listTools(),tools=listed.tools||[];console.log("Roblox Studio MCP connected. Tools:",tools.length);
 const compact=()=>tools.map(t=>({name:t.name,description:t.description,inputSchema:t.inputSchema}));
 const post=async(path,body,headers={})=>fetch(FORGE_URL+path,{method:"POST",headers:{"Content-Type":"application/json",...headers},body:JSON.stringify(body)});
 const heartbeat=async(status,extra={})=>{try{await post("/api/bridge/heartbeat",{status,platform:process.platform,tools:tools.length,...extra},{"x-forge-key":forge})}catch{}};
 await heartbeat("online",{version:"2.0.0"});setInterval(()=>heartbeat("online",{version:"2.0.0"}),10000);
 const ask=async messages=>{let last="";for(let attempt=1;attempt<=4;attempt++){try{const c=new AbortController();const timer=setTimeout(()=>c.abort(),60000);const r=await fetch("https://api.noxery.net/v1/chat/completions",{method:"POST",headers:{"Authorization":"Bearer "+nox,"Content-Type":"application/json"},signal:c.signal,body:JSON.stringify({model:"gpt-6-astra",messages,temperature:0.15,max_completion_tokens:9000,stream:false,tools:compact().map(t=>({type:"function",function:{name:t.name,description:t.description||"",parameters:t.inputSchema||{type:"object",properties:{}}}})),tool_choice:"auto"})});clearTimeout(timer);const d=await r.json();if(!r.ok)throw Error("Noxery API "+r.status+": "+JSON.stringify(d).slice(0,800));return d}catch(e){last=String(e?.message||e);if(attempt<4)await new Promise(r=>setTimeout(r,1500*attempt))}}throw Error(last||"Noxery API request failed")};
 const claim=async()=>{const r=await fetch(FORGE_URL+"/api/jobs/claim",{method:"POST",headers:{"x-forge-key":forge}});return r.json()};
 const complete=async(id,status,result,error="")=>post("/api/jobs/complete",{id,status,result,error},{"x-forge-key":forge});
 const execute=async job=>{
  await heartbeat("working",{job_id:job.id});
  const system="You are GPT-6 Astra controlling an open Roblox Studio session through its real MCP server. Execute the user request directly in Studio, not as a mockup. Inspect the existing DataModel before edits. Use Creator Store search tools when available and prefer usable/stylized assets; create secure server/client Luau, mobile UI, VFX and audio as appropriate; organize everything cleanly; run playtests when possible. Never claim an action succeeded until the MCP tool result confirms it. You may call any supplied MCP tool. When the task is complete, answer briefly with what was actually changed.";
  let messages=[{role:"system",content:system},{role:"user",content:job.prompt}],trace=[];
  for(let i=0;i<80;i++){
   const d=await ask(messages);
   const m=d?.choices?.[0]?.message||{};
   if(m.tool_calls?.length){
    messages.push(m);
    for(const tc of m.tool_calls){
     const name=tc?.function?.name;let args={};try{args=JSON.parse(tc?.function?.arguments||"{}")}catch{throw Error("Astra returned invalid tool arguments for "+name)}
     const tool=tools.find(x=>x.name===name);if(!tool)throw Error("Astra requested unknown MCP tool: "+name);
     console.log("["+i+"]",name);const result=await client.callTool({name,arguments:args});trace.push({tool:name,ok:!result.isError});await heartbeat("working",{job_id:job.id,step:i,tool:name});
     messages.push({role:"tool",tool_call_id:tc.id,content:JSON.stringify(result).slice(0,30000)});
    }
    continue;
   }
   const content=String(m.content||"");if(!content)throw Error("Noxery/Astra returned an empty response at step "+i);
   return {summary:content,steps:trace};
  }
  throw Error("Step limit reached");
 };
 while(true){try{const r=await claim();if(r.job){try{const result=await execute(r.job);await complete(r.job.id,"completed",result);await heartbeat("online");console.log("Completed",r.job.id)}catch(e){await complete(r.job.id,"failed",null,String(e?.message||e));await heartbeat("online",{error:String(e?.message||e)});console.error(e)}}}catch(e){await heartbeat("error",{error:String(e?.message||e)});console.error("Bridge:",e?.message||e)}await new Promise(r=>setTimeout(r,2500))}
}
main().catch(e=>{console.error(e);process.exit(1)});