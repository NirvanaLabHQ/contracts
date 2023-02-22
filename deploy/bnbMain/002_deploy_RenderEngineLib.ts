import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy } = deployments;
  const { degen_deployer } = await getNamedAccounts();

  await deploy("RenderEngine", {
    from: degen_deployer,
    log: true,
  });
};
func.tags = ["RenderEngine"];

export default func;
