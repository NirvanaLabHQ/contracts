import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy } = deployments;
  const { degen_deployer } = await getNamedAccounts();

  await deploy("DeprecatedRBT", {
    from: degen_deployer,
    log: true,
  });
};
func.tags = ["DeprecatedRBT"];

export default func;
