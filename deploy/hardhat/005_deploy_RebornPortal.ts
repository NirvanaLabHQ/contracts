import { ethers } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy, get } = deployments;
  const { deployer, owner } = await getNamedAccounts();

  const rbt = await get("RBT");
  const render = await get("RenderEngine");

  await deploy("RebornPortal", {
    from: deployer,
    proxy: {
      proxyContract: "ERC1967Proxy",
      proxyArgs: ["{implementation}", "{data}"],
      execute: {
        init: {
          methodName: "initialize",
          args: [
            rbt.address,
            owner,
            "Degen Tombstone",
            "RIP",
            // VRFCoordinatorV2 on bnb chain test https://testnet.bscscan.com/address/0x6A2AAd07396B36Fe02a22b33cf443582f682c82f
            "0x6A2AAd07396B36Fe02a22b33cf443582f682c82f",
          ],
        },
      },
    },
    libraries: {
      RenderEngine: render.address,
      Renderer: (await get("Renderer")).address,
      FastArray: (await get("FastArray")).address,
      RankingRedBlackTree: (await get("RankingRedBlackTree")).address,
      SingleRanking: (await get("SingleRanking")).address,
      DegenRank: (await get("DegenRank")).address,
      PortalLib: (await get("PortalLib")).address,
    },
    log: true,
  });

  // await execute(
  //   "RebornPortal",
  //   { from: owner, log: true },
  //   "updateSigners",
  //   ["0x803470638940Ec595B40397cbAa597439DE55907"],
  //   []
  // );

  // // set refer reward
  // await execute(
  //   "RebornPortal",
  //   { from: owner, log: true },
  //   "setReferrerRewardFee",
  //   800,
  //   200,
  //   0
  // );
  // await execute(
  //   "RebornPortal",
  //   { from: owner, log: true },
  //   "setReferrerRewardFee",
  //   1800,
  //   200,
  //   0
  // );
};
func.tags = ["Portal"];

export default func;
