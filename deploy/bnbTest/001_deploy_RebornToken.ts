import { parseEther } from "ethers/lib/utils";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy } = deployments;
  const { deployer, owner } = await getNamedAccounts();

  await deploy("RBT", {
    from: deployer,
    proxy: {
      proxyContract: "ERC1967Proxy",
      proxyArgs: ["{implementation}", "{data}"],
      execute: {
        init: {
          methodName: "initialize",
          args: [
            "$REBORN",
            "RBT",
            parseEther(Number(10 ** 10).toString()),
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