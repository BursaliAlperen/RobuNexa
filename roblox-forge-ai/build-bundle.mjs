import { build } from "esbuild";
await build({
  entryPoints: ["roblox-forge-bridge.js"],
  bundle: true,
  platform: "node",
  format: "cjs",
  outfile: "dist/bridge.cjs",
  external: []
});
console.log("Bridge bundle ready.");
