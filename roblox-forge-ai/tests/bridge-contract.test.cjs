"use strict";
const fs=require("node:fs"),path=require("node:path");
const root=path.join(__dirname,"..");
const preload=fs.readFileSync(path.join(root,"desktop-preload.cjs"),"utf8");
const main=fs.readFileSync(path.join(root,"desktop-main.cjs"),"utf8");
for(const name of ["start","send","stop","status","onEvent"])if(!preload.includes(name+":"))throw new Error("preload missing "+name);
for(const needle of ["bridge-start","bridge-send","bridge-stop","bridge-status","forge-bridge-event"])if(!main.includes(needle))throw new Error("main missing "+needle);
for(const state of ["starting","online","offline","error"])if(!main.includes('setState("'+state+'"'))throw new Error("bridge state missing "+state);
console.log("Bridge contract OK");
