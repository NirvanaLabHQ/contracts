import { parseEther } from "ethers/lib/utils";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy, execute, getOrNull } = deployments;

  const { deployer, owner } = await getNamedAccounts();

  const isFirstDeploy = !(await getOrNull("RBT"));

  await deploy("RBT", {
    from: deployer,
    proxy: {
      proxyContract: "ERC1967Proxy",
      proxyArgs: ["{implementation}", "{data}"],
      execute: {
        init: {
          methodName: "initialize",
          args: [
            "Degen Reborn Token",
            "$REBORN",
            parseEther(Number(10 ** 9).toString()),
            owner,
          ],
        },
      },
    },
    log: true,
  });

  if (isFirstDeploy) {
    await execute(
      "RBT",
      { from: owner, log: true },
      "updateMinter",
      [owner],
      []
    );
  }
};
func.tags = ["RBT"];

export default func;
