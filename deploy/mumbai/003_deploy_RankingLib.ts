import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("FastArray", { from: deployer, log: true });
  await deploy("RankingRedBlackTree", { from: deployer, log: true });
  await deploy("SingleRanking", {
    from: deployer,
    log: true,
    libraries: {
      FastArray: (await get("FastArray")).address,
      RankingRedBlackTree: (await get("RankingRedBlackTree")).address,
    },
  });
  await deploy("DegenRank", {
    from: deployer,
    libraries: {
      SingleRanking: (await get("SingleRanking")).address,
      FastArray: (await get("FastArray")).address,
      RankingRedBlackTree: (await get("RankingRedBlackTree")).address,
    },
    log: true,
  });
};

func.tags = ["RankingLib"];

export default func;
