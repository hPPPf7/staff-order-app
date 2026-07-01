import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const version = (process.argv[2] || process.env.VERSION || "").replace(/^v/i, "");
const match = version.match(/^(\d+)\.(\d+)\.(\d+)$/);

if (!match) {
  throw new Error("Version must use major.minor.patch format.");
}

const [, major, minor, patch] = match.map(Number);
if (minor > 99 || patch > 99) {
  throw new Error("Minor and patch versions must be between 0 and 99.");
}

const versionCode = major * 10000 + minor * 100 + patch;
const root = path.resolve(import.meta.dirname, "..");

function replaceInFile(relativePath, pattern, replacement) {
  const filePath = path.join(root, relativePath);
  const source = fs.readFileSync(filePath, "utf8");

  if (!pattern.test(source)) {
    throw new Error(`Version pattern was not found in ${relativePath}.`);
  }

  const updated = source.replace(pattern, replacement);
  fs.writeFileSync(filePath, updated);
}

replaceInFile("index.html", /const appVersion = "[^"]+";/, `const appVersion = "${version}";`);
replaceInFile("android/app/build.gradle", /versionCode \d+/, `versionCode ${versionCode}`);
replaceInFile("android/app/build.gradle", /versionName "[^"]+"/, `versionName "${version}"`);

const packagePath = path.join(root, "package.json");
const packageJson = JSON.parse(fs.readFileSync(packagePath, "utf8"));
packageJson.version = version;
fs.writeFileSync(packagePath, `${JSON.stringify(packageJson, null, 2)}\n`);

console.log(`Prepared version ${version} (${versionCode}).`);
