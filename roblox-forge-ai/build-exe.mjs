import {mkdir} from "node:fs/promises";
import {build} from "esbuild";
import {execFileSync} from "node:child_process";
import path from "node:path";
await mkdir("dist",{recursive:true});
await build({entryPoints:["roblox-forge-bridge.js"],bundle:true,platform:"node",format:"cjs",target:"node24",outfile:"dist/bridge.cjs",sourcemap:false,minify:false});
const builder=process.platform==="win32"?path.join("node_modules",".bin","electron-builder.cmd"):path.join("node_modules",".bin","electron-builder");
execFileSync(process.env.ComSpec||"cmd.exe",["/d","/c",builder,"--win","portable"],{stdio:"inherit"});
console.log("RobloxForgeAI-Windows-x64.exe created.");