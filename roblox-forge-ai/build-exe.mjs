import { mkdir, readFile, writeFile } from "node:fs/promises";
import { execFileSync } from "node:child_process";

await mkdir("dist", { recursive: true });
await import("./build-bundle.mjs");
const blob = await readFile("dist/bridge.cjs");

const config = {
  main: "dist/bridge.cjs",
  output: "dist/RobloxForgeAI.exe",
  disableExperimentalSEAWarning: true,
  useSnapshot: false,
  useCodeCache: false
};

await writeFile("dist/sea-config.json", JSON.stringify(config, null, 2));

const node = process.execPath;
execFileSync(node, ["--experimental-sea-config", "dist/sea-config.json"], { stdio: "inherit" });

const seaPrep = "dist/sea-prep.blob";
await writeFile(seaPrep, blob);

const { execSync } = await import("node:child_process");
execSync('powershell -NoProfile -ExecutionPolicy Bypass -Command "$exe=Join-Path $env:ProgramFiles \'nodejs\\node.exe\'; if(Test-Path $exe){$exe}else{$env:Path.Split(\';\')[0]+\'\\node.exe\'}"', {stdio:"pipe"});
console.log("SEA preparation complete. A platform-specific post-build injection step is required.");
console.log("Generated: dist/bridge.cjs and dist/sea-prep.blob");
