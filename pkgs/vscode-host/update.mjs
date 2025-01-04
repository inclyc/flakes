import { promises as fs } from "fs";
import { spawn } from "child_process";
import * as path from "path";

import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Helper function to run a command and capture its output
async function runCommand(command, args) {
  return new Promise((resolve, reject) => {
    const process = spawn(command, args);
    let stdout = "";
    let stderr = "";

    process.stdout.on("data", (data) => {
      stdout += data.toString();
    });

    process.stderr.on("data", (data) => {
      stderr += data.toString();
    });

    process.on("close", (code) => {
      if (code === 0) {
        resolve(stdout.trim());
      } else {
        reject(new Error(stderr.trim()));
      }
    });
  });
}

// Map Node.js architecture to Nix architecture
function getNixArch(arch) {
  const archMap = {
    x64: 'x86_64',
    arm64: 'aarch64',
  };
  return archMap[arch] || arch;
}

// Generate the VS Code update URL
function generateUrl(version, type, os, arch) {
  return `https://update.code.visualstudio.com/${version}/${type}-${os}-${arch}-web/stable`;
}

// Main function to fetch hashes and generate JSON
async function main() {
  // Define versions, types, OS, and architectures to process
  const versions = [process.argv.slice(2)];
  const types = ["server"];
  const osList = ["linux", "darwin"];
  const archList = ["x64", "arm64"];

  const result = {};

  // Progress tracking variables
  let completedTasks = 0;

  // Generate all async tasks
  const tasks = [];

  for (const version of versions) {
    for (const type of types) {
      const key = `vscode-${type}`;
      result[key] = result[key] || {};

      for (const os of osList) {
        for (const arch of archList) {
          if (os === "darwin" && arch === "x64") {
            continue;
          }
          const nixArch = getNixArch(arch);
          const archKey = `${nixArch}-${os}`;
          const url = generateUrl(version, type, os, arch);

          tasks.push(
            (async () => {
              try {
                const sha256 = await runCommand("nix-prefetch-url", [url]);
                result[key][archKey] = { url, sha256 };
              } catch (error) {
                console.error(`Error processing ${archKey}: ${error.message}`);
              } finally {
                completedTasks++;
                const progress = Math.round((completedTasks / tasks.length) * 100);
                console.log(`Progress: ${progress}% (${completedTasks}/${tasks.length})`);
              }
            })()
          );
        }
      }
    }
  }

  // Total number of tasks
  const totalTasks = tasks.length;
  console.log(`Total tasks: ${totalTasks}`);

  // Execute all tasks in parallel
  await Promise.all(tasks);

  // Write JSON to a file
  const outputFile = path.resolve(__dirname, "sources.json");
  await fs.writeFile(outputFile, JSON.stringify(result, null, 2));

  console.log(`Hashes and URLs saved to ${outputFile}`);
}

// Run the main function
main();
