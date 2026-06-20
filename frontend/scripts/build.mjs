import { copyFileSync, existsSync, mkdirSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const frontendRoot = resolve(scriptDir, "..");
const outputDir = resolve(frontendRoot, "../backend/priv/static");
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
      "Elm compiler was not found. Run `npm install`, `mise install`, or enter `nix develop`.",
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
  const executable = process.platform === "win32" ? "elm.cmd" : "elm";
  const candidates = [
    join(frontendRoot, "node_modules", ".bin", executable),
    join(frontendRoot, "..", "node_modules", ".bin", executable),
  ];

  return candidates.find((candidate) => existsSync(candidate)) ?? executable;
}
