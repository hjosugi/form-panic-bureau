import { copyFileSync, mkdirSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const frontendRoot = resolve(scriptDir, "..");
const outputDir = resolve(frontendRoot, "../dist");
const optimize = process.argv.includes("--optimize");
const elm = findElm();

mkdirSync(outputDir, { recursive: true });

const args = [
  "make",
  "src/Main.elm",
  `--output=${join(outputDir, "app.js")}`,
];

if (optimize) {
  args.push("--optimize");
}

const result = spawnSync(elm, args, {
  cwd: frontendRoot,
  stdio: "inherit",
});

if (result.error) {
  if (result.error.code === "ENOENT") {
    console.error(
      "Elm compiler was not found. Enter the Nix dev shell with `nix develop` before building.",
    );
    process.exit(1);
  }

  throw result.error;
}

if (result.status !== 0) {
  process.exit(result.status ?? 1);
}

copyFileSync(
  join(frontendRoot, "public/index.html"),
  join(outputDir, "index.html"),
);
copyFileSync(
  join(frontendRoot, "public/styles.css"),
  join(outputDir, "styles.css"),
);

console.log(`Elm frontend built in ${optimize ? "optimized" : "debug"} mode.`);

function findElm() {
  return process.platform === "win32" ? "elm.cmd" : "elm";
}
