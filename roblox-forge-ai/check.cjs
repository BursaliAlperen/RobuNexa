"use strict";
const fs=require("node:fs"),path=require("node:path"),cp=require("node:child_process"),os=require("node:os");
const root=__dirname,errors=[];
const pkg=JSON.parse(fs.readFileSync(path.join(root,"package.json"),"utf8"));
const files=Array.isArray(pkg.build?.files)?pkg.build.files:[];
for(const f of files){if(!fs.existsSync(path.join(root,f)))errors.push("Missing packaged file: "+f)}
for(const f of files.filter(f=>/\.(cjs|mjs)$/.test(f))){const r=cp.spawnSync(process.execPath,["--check",path.join(root,f)],{encoding:"utf8"});if(r.status!==0)errors.push("Syntax error in "+f+"\n"+(r.stderr||"").slice(0,1200))}
for(const f of ["build-exe.mjs","build-bundle.mjs","check.cjs"]){const r=cp.spawnSync(process.execPath,["--check",path.join(root,f)],{encoding:"utf8"});if(r.status!==0)errors.push("Syntax error in "+f)}
const html=fs.readFileSync(path.join(root,"desktop.html"),"utf8");
const scripts=[...html.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/gi)];
if(!scripts.length)errors.push("desktop.html has no inline script");
for(const m of scripts){if(m[1].trim()){const tmp=path.join(os.tmpdir(),"rfa-desktop-inline-check.js");fs.writeFileSync(tmp,m[1],"utf8");const r=cp.spawnSync(process.execPath,["--check",tmp],{encoding:"utf8"});if(r.status!==0)errors.push("Syntax error in desktop.html inline script\n"+(r.stderr||"").slice(0,1200))}}
if(errors.length){console.error(errors.join("\n\n"));process.exit(1)}
console.log("RFA static checks OK");
