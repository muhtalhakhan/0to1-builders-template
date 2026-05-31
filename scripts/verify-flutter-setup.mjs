import fs from "node:fs";
import path from "node:path";

const root = process.cwd();

const requiredFiles = [
  path.join("scaffolds", "flutter-app", "AGENTS.md"),
  path.join("scaffolds", "flutter-app", "pubspec.yaml"),
  path.join("scaffolds", "flutter-app", "lib", "main.dart"),
  path.join("scaffolds", "flutter-app", ".agents", "skills", "start", "SKILL.md"),
  path.join("scaffolds", "flutter-app", ".agents", "skills", "fixit", "SKILL.md"),
  path.join("scaffolds", "flutter-app", ".agents", "skills", "deploy", "SKILL.md"),
  path.join("scaffolds", "flutter-app", ".agents", "skills", "imlost", "SKILL.md"),
  path.join("scripts", "check-mobile-prereqs.ps1"),
  path.join("scripts", "check-mobile-prereqs.sh")
];

const missing = requiredFiles.filter((file) => !fs.existsSync(path.join(root, file)));

if (missing.length) {
  console.error("Flutter setup check failed. Missing files:");
  for (const file of missing) console.error(`- ${file}`);
  process.exit(1);
}

console.log("Flutter setup check passed. Scaffold files are ready.");
