import syncFs from "node:fs";
import { cpus } from "node:os";
import fs from "node:fs/promises";
import { spawn } from "node:child_process";

let OS = process.env.OS;
const ARCH = process.env.ARCH == "amd64" ? "x64" : "arm64";

const coreCount = cpus().length;
const threadCount = coreCount * 2;
let current_os;
switch (process.platform) {
  case "darwin":
    current_os = "mac";
    break;
  case "win32":
    current_os = "win";
    break;
  default:
    current_os = "linux";
    break;
}

if (!OS) OS = current_os;

const nodejsGithubRepo = "https://github.com/nodejs/node";
const removeTheVCharacter = (str) => str.replace("v", "");

const nodeIndexUrl = "https://nodejs.org/dist/index.json";
const getLatestNodeVersion = async () => {
  const res = await fetch(nodeIndexUrl);
  const jsonData = await res.json();

  return removeTheVCharacter(jsonData[0]["version"]);
};

const getLatestPublishedVersion = async () =>
  removeTheVCharacter(await fs.readFile("version.txt", { encoding: "utf8" }));

const isANewerVersion = (oldVer, newVer) => {
  const oldParts = oldVer.split(".");
  const newParts = newVer.split(".");

  for (var i = 0; i < newParts.length; i++) {
    const a = ~~newParts[i]; // parse int
    const b = ~~oldParts[i]; // parse int

    if (a > b) return true;
    if (a < b) return false;
  }

  return false;
};

const spawnAsync = (program, args) =>
  new Promise((resolve, reject) => {
    console.log("Running:", [program, ...args].join(" "));

    const child = spawn(program, args, {});

    child.stdout.on("data", (chunk) => console.log(chunk.toString()));
    child.stderr.on("data", (chunk) => console.error(chunk.toString()));
    child.on("close", (code) => {
      if (code == 0) resolve(code.toString());
      else reject(code.toString());
    });
  });

const latestNodeVersion = await getLatestNodeVersion();
if (!isANewerVersion(await getLatestPublishedVersion(), latestNodeVersion)) {
  console.log("Nothing to do!");
  process.exit(0);
}

if (!syncFs.existsSync("node")) {
  await spawnAsync(
    "git",
    [
      "clone",
      nodejsGithubRepo,
      "--branch",
      `v${latestNodeVersion}`,
      "--depth=1",
    ],
    undefined,
    {}
  );
}

process.chdir("node");

let extraArgs = [];
if (process.platform == "win32") {
  await spawnAsync(".\\vcbuild.bat", [ARCH, "dll", "openssl-no-asm"]);
} else {
  if (ARCH === "arm64") {
    extraArgs.push("--with-arm-float-abi");
    extraArgs.push("hard");
    extraArgs.push("--with-arm-fpu");
    extraArgs.push("neon");
  }

  await spawnAsync("./configure", [
    "--shared",
    "--dest-cpu",
    ARCH,
    "--dest-os",
    OS,
    ...extraArgs,
  ]);
  await spawnAsync("make", [`-j${threadCount}`]);
}
