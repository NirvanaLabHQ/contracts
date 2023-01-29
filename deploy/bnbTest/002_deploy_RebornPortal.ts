import { DeployFunction } from "hardhat-deploy/types";
import { parseEther } from "ethers/lib/utils";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy, get } = deployments;
  const { deployer, owner } = await getNamedAccounts();

  const rbt = await get("RBT");

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
            parseEther("0.1"),
            "0x00000000000004200000000000064210",
            owner,
          ],
        },
      },
    },
    log: true,
  });
};
func.tags = ["RBT"];

export default func;
