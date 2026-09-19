const fs=require("node:fs");
const path=require("node:path");
const crypto=require("node:crypto");
const {safeStorage}=require("electron");

class AccountStore{
 constructor(file){this.file=file;this.data=this.load()}
 load(){try{return JSON.parse(fs.readFileSync(this.file,"utf8"))}catch{return {version:1,account:null,settings:{language:"tr",theme:"light"},actions:[],credits:0,entitlements:{pro:false}}}}
 save(){fs.mkdirSync(path.dirname(this.file),{recursive:true});fs.writeFileSync(this.file,JSON.stringify(this.data,null,2),"utf8")}
 ensureLocal(){if(!this.data.account){this.data.account={id:"local_"+crypto.randomUUID(),type:"local",name:"Local User",email:null,createdAt:new Date().toISOString()};this.save();this.log("account.local_created",{id:this.data.account.id})}return this.data.account}
 setAccount(account){this.data.account={...account};this.save();return this.data.account}
 getAccount(){return this.data.account||this.ensureLocal()}
 setSetting(key,value){this.data.settings[key]=value;this.save();return this.data.settings}
 getSettings(){return this.data.settings}
 log(action,detail={}){this.data.actions.unshift({id:crypto.randomUUID(),action,detail,createdAt:new Date().toISOString()});if(this.data.actions.length>1000)this.data.actions.length=1000;this.save()}
 actions(){return this.data.actions}
 addCredits(amount,source="manual"){const n=Math.max(0,Number(amount)||0);this.data.credits+=n;this.log("credits.added",{amount:n,source,balance:this.data.credits});this.save();return this.data.credits}
 spendCredits(amount,reason="ai"){const n=Math.max(0,Number(amount)||0);if(this.data.credits<n)throw new Error("Yetersiz kredi.");this.data.credits-=n;this.log("credits.spent",{amount:n,reason,balance:this.data.credits});this.save();return this.data.credits}
 setPro(source="official"){this.data.entitlements.pro=true;this.data.entitlements.proSource=source;this.data.entitlements.proAt=new Date().toISOString();this.log("pro.activated",{source});this.save();return this.data.entitlements}
 snapshot(){return {account:this.getAccount(),settings:this.data.settings,actions:this.data.actions.slice(0,100),credits:this.data.credits,entitlements:this.data.entitlements}}
}
module.exports={AccountStore};
