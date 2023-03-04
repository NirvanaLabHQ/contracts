import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy, get, execute } = deployments;
  const { deployer, owner } = await getNamedAccounts();

  const rbt = await get("RBT");
  const portal = await get("RebornPortal");

  await deploy("BurnPool", {
    from: deployer,
    args: [portal.address, rbt.address],
    log: true,
  });

  const burnPool = await get("BurnPool");

  //   set burn pool for portal
  await execute(
    "RebornPortal",
    { from: owner },
    "setBurnPool",
    burnPool.address
  );
};

func.tags = ["BurnPool"];
export default func;
