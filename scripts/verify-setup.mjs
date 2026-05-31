import fs from "node:fs";
import path from "node:path";

const root = process.cwd();

const requiredFiles = [
  "AGENTS.md",
  "package.json",
  path.join("app", "layout.tsx"),
  path.join("app", "page.tsx"),
  path.join("components", "providers.tsx"),
  path.join("public", "milestones.json"),
  path.join(".agents", "skills", "start", "SKILL.md"),
  path.join(".agents", "skills", "fixit", "SKILL.md"),
  path.join(".agents", "skills", "deploy", "SKILL.md"),
  path.join(".agents", "skills", "imlost", "SKILL.md")
];

const missing = requiredFiles.filter((file) => !fs.existsSync(path.join(root, file)));

if (missing.length) {
  console.error("Setup check failed. Missing files:");
  for (const file of missing) console.error(`- ${file}`);
  process.exit(1);
}

const hasNodeModules = fs.existsSync(path.join(root, "node_modules"));
if (!hasNodeModules) {
  console.error("Dependencies are not installed yet. Run: npm install");
  process.exit(1);
}

console.log("Setup check passed. Codex config and dependencies are ready.");
