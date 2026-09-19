import {mkdir} from "node:fs/promises";
import {build} from "esbuild";
import {execFileSync} from "node:child_process";
await mkdir("dist",{recursive:true});
await build({entryPoints:["roblox-forge-bridge.js"],bundle:true,platform:"node",format:"cjs",target:"node24",outfile:"dist/bridge.cjs",sourcemap:false,minify:false});
execFileSync("npx",["electron-builder","--win","portable"],{stdio:"inherit"});
console.log("RobloxForgeAI-Windows-x64.exe created.");