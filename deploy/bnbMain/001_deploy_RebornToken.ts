import { parseEther } from "ethers/lib/utils";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy } = deployments;
  const { degen_deployer } = await getNamedAccounts();

  await deploy("RBT", {
    from: degen_deployer,
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
            "0xa23a69CB8aE1259937F1e6b51e76a53F3DEaA988",
          ],
        },
      },
    },
    log: true,
  });
};
func.tags = ["RBT"];

export default func;
