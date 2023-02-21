import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy, get, execute } = deployments;
  const { deployer, owner } = await getNamedAccounts();

  const rbt = await get("RBT");
  const portal = await get("RebornPortal");

  await deploy("RewardVault", {
    from: deployer,
    args: [portal.address, rbt.address],
    log: true,
  });

  const vault = await get("RewardVault");

  // set vault for portal
  await execute("RebornPortal", { from: owner }, "setVault", vault.address);
};
func.tags = ["Vault"];

export default func;
