import os from "node:os";
import syncFs from "node:fs";
import fs from "node:fs/promises";
import { spawn } from "node:child_process";

const coreCount = os.cpus().length;
const threadCount = coreCount * 2;

let CC = process.env.CC;
let CXX = process.env.CXX;
if (!CC) CC = "gcc";
if (!CXX) CXX = "g++";

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

const spawnAsync = (program, args, cwd) =>
  new Promise((resolve, reject) => {
    console.log([program, ...args].join(" "));

    const child = spawn(program, args, cwd ? { cwd } : {});

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
    undefined
  );
}

if (process.platform == "linux") {
  await spawnAsync("./configure", ["--ninja", "--shared"], "node");
  await spawnAsync("make", [`-j${threadCount}`], "node");
} else if (process.platform == "win32") {
  await spawnAsync("vcbuild.bat", ["--shared"], "node");
}
