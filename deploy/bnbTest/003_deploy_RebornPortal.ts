import { DeployFunction } from "hardhat-deploy/types";
import { parseEther } from "ethers/lib/utils";

const func: DeployFunction = async function ({
  deployments,
  getNamedAccounts,
}) {
  const { deploy, get, execute } = deployments;
  const { deployer, owner } = await getNamedAccounts();

  const rbt = await get("RBT");
  const render = await get("RenderEngine");

  const talentPrice =
    "0x00000000000000000000000000000000000000000000004b02bc21c12c0a0000";

  await deploy("RebornPortal", {
    from: deployer,
    proxy: {
      proxyContract: "ERC1967Proxy",
      proxyArgs: ["{implementation}", "{data}"],
      execute: {
        init: {
          methodName: "initialize",
          args: [
            rbt.address,
            parseEther("0.01"),
            //
            talentPrice,
            owner,
            "Degen Tombstone",
            "RIP",
          ],
        },
      },
    },
    libraries: { RenderEngine: render.address },
    log: true,
  });

  // await execute(
  //   "RebornPortal",
  //   { from: owner },
  //   "updateSigners",
  //   ["0x803470638940Ec595B40397cbAa597439DE55907"],
  //   []
  // );

  // set portal as minter
  // const portal = await get("RebornPortal");
  // await execute("RBT", { from: owner }, "updateMinter", [portal.address], []);

  // set price
  // await execute("RebornPortal", { from: owner }, "setTalentPrice", talentPrice);
};
func.tags = ["Portal"];

export default func;
