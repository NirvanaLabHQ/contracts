import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("RenderEngine", {
    from: deployer,
    log: true,
  });
};
func.tags = ["RenderEngine"];

export default func;
