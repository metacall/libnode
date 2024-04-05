import os from "node:os";
import syncFs from "node:fs";
import fs from "node:fs/promises";
import { spawn } from "node:child_process";

const coreCount = os.cpus().length;
const threadCount = coreCount * 2;
const ccacheEnv = { CC: "ccache gcc", CXX: "ccache g++" };

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

const spawnAsync = (program, args, cwd, env) =>
  new Promise((resolve, reject) => {
    console.log([program, ...args].join(" "));

    const child = spawn(
      program,
      args,
      cwd ? { cwd, env: { ...process.env, ...env } } : {}
    );

    child.stdout.on("data", (chunk) => console.log(chunk.toString()));
    child.stderr.on("data", (chunk) => console.warn(chunk.toString()));
    child.on("close", (code) => resolve(code.toString()));
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

await spawnAsync(
  "./configure",
  ["--ninja", "--shared", "--debug"],
  "node",
  ccacheEnv
);

await spawnAsync("make", [`-j${threadCount}`], "node", ccacheEnv);
