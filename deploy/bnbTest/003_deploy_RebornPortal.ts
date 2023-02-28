import { DeployFunction } from "hardhat-deploy/types";
import { parseEther } from "ethers/lib/utils";

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
          args: [rbt.address, owner, "Degen Tombstone", "RIP"],
        },
      },
    },
    libraries: { RenderEngine: render.address },
    log: true,
  });

  // await execute(
  //   "RebornPortal",
  //   { from: owner },
  //   "updateSigners",
  //   ["0x803470638940Ec595B40397cbAa597439DE55907"],
  //   []
  // );
};
func.tags = ["Portal"];

export default func;
