import { DeployFunction } from "hardhat-deploy/types";
import { parseEther } from "ethers/lib/utils";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy, get } = deployments;
  const { degen_deployer } = await getNamedAccounts();

  const rbt = await get("RBT");
  const render = await get("RenderEngine");

  await deploy("RebornPortal", {
    from: degen_deployer,
    proxy: {
      proxyContract: "ERC1967Proxy",
      proxyArgs: ["{implementation}", "{data}"],
      execute: {
        init: {
          methodName: "initialize",
          args: [
            rbt.address,
            parseEther("0.001"),
            "0xa23a69CB8aE1259937F1e6b51e76a53F3DEaA988",
            "Degen Tombstone",
            "RIP",
          ],
        },
      },
    },
    libraries: { RenderEngine: render.address },
    log: true,
  });

  // TODO: manually add signer
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
