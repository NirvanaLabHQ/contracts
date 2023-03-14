import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy } = deployments;
  const { deployer, owner } = await getNamedAccounts();

  await deploy("RewardDistributor", {
    from: deployer,
    args: [owner],
    log: true,
  });
};

func.tags = ["RewardDistributor"];
export default func;
