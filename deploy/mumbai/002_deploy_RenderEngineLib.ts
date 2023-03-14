import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("RenderConstant", {
    from: deployer,
    log: true,
  });
  await deploy("Renderer", {
    from: deployer,
    log: true,
    libraries: { RenderConstant: (await get("RenderConstant")).address },
  });
};
func.tags = ["RenderEngine"];

export default func;
