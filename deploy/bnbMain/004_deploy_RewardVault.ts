import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy, get } = deployments;
  const { degen_deployer } = await getNamedAccounts();

  const rbt = await get("RBT");
  const portal = await get("RebornPortal");

  await deploy("RewardVault", {
    from: degen_deployer,
    args: [portal.address, rbt.address],
    log: true,
  });

  // TODO: manually set vault
  // const vault = await get("RewardVault");
  // await execute("RebornPortal", { from: owner }, "setVault", vault.address);
};
func.tags = ["Vault"];

export default func;
