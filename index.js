import os from "node:os";
import syncFs from "node:fs";
import fs from "node:fs/promises";
import { Readable } from "node:stream";
import { finished } from "node:stream/promises";
import { spawnSync, spawn } from "node:child_process";

const constructSourceTarballName = (version) => `node-${version}.tar.gz`;
const constructSourceTarballDirName = (version) => `node-${version}`;

const constructSourceDownloadLink = (version) =>
  `https://github.com/nodejs/node/archive/refs/tags/v${version}.tar.gz`;

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
    const child = spawn(program, args, { cwd });

    child.stdout.on("data", (chunk) => console.log(chunk.toString()));
    child.stderr.on("data", (chunk) => {
      console.error(chunk.toString());
      reject(chunk);
    });

    child.on("close", (code) => resolve(code));
  });

const latestNodeVersion = await getLatestNodeVersion();

if (!isANewerVersion(await getLatestPublishedVersion(), latestNodeVersion)) {
  console.log("Nothing to do!");
  process.exit(0);
}

const tarballName = constructSourceTarballName(latestNodeVersion);
if (!syncFs.existsSync(tarballName)) {
  const stream = syncFs.createWriteStream(tarballName);
  const { body } = await fetch(constructSourceDownloadLink(latestNodeVersion));
  await finished(Readable.fromWeb(body).pipe(stream));
}

const tarballDir = constructSourceTarballDirName(latestNodeVersion);
if (!syncFs.existsSync(tarballDir)) {
  const { stderr } = spawnSync("tar", ["-xvf", `${tarballName}`]);
  if (stderr.length > 0) {
    console.error(stderr);
    process.exit(0);
  }
}

await spawnAsync("./configure", ["--ninja", "--shared", "--debug"], tarballDir);

const coreCount = os.cpus().length;
const threadCount = coreCount * 2;

await spawnAsync("make", [`-j${threadCount}`], tarballDir);
