import * as dotenv from "dotenv";

import fs from "fs";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-deploy";
import "hardhat-preprocessor";
import { HardhatUserConfig, task } from "hardhat/config";

import example from "./tasks/example";

function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean)
    .filter((v) => v.includes("@node_modules"))
    .map((line) => line.trim().split("="));
}

dotenv.config();

const deployer =
  process.env.DEPLOYER || "0x0000000000000000000000000000000000000000";
const owner = process.env.OWNER || "0x0000000000000000000000000000000000000000";
const accounts = process.env.ACCOUNTS ? process.env.ACCOUNTS.split(",") : [];

task("example", "Example task").setAction(example);

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000,
      },
    },
  },
  networks: {
    bnbMain: {
      url: process.env.BNB_CHAIN_URL,
      accounts: accounts,
      gas: "auto",
      gasPrice: "auto",
      deploy: ["deploy/bnbMain"],
      tags: ["production"],
    },
    bnbTestStaging: {
      url: process.env.BNB_CHAIN_TEST_URL,
      accounts: accounts,
      gas: "auto",
      gasPrice: "auto",
      deploy: ["deploy/bnbTestStaging"],
      tags: ["staging"],
    },
    bnbTest: {
      url: process.env.BNB_CHAIN_TEST_URL,
      accounts: accounts,
      gas: "auto",
      gasPrice: "auto",
      deploy: ["deploy/bnbTest"],
      tags: ["test"],
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
      bnbTest: deployer,
      bnbTestStaging: deployer,
      bnbMain: deployer,
    },
    owner: {
      default: 0,
      bnbTest: owner,
      bnbTestStaging: owner,
      bnbMain: owner,
    },
  },
  paths: {
    sources: "./src", // Use ./src rather than ./contracts as Hardhat expects
    cache: "./cache_hardhat", // Use a different cache for Hardhat than Foundry
  },
  // This fully resolves paths for imports in the ./lib directory for Hardhat
  preprocess: {
    eachLine: (hre) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import /i)) {
          getRemappings().forEach(([find, replace]) => {
            if (line.match(find)) {
              line = line.replace(find, replace);
            }
          });
        }
        return line;
      },
    }),
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: {
      bscTestnet: process.env.BNB_SCAN_API_KEY!,
      bsc: process.env.BNB_SCAN_API_KEY!,
    },
  },
  external: {
    contracts: [
      {
        artifacts:
          "node_modules/@openzeppelin/upgrades-core/artifacts/@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol/",
      },
    ],
  },
};

export default config;
