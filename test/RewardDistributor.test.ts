import { ethers } from "hardhat";
import { BigNumber } from "ethers";
import { expect } from "chai";
import { StandardMerkleTree } from "@openzeppelin/merkle-tree";

function expandTo18Decimals(num: number): BigNumber {
  return BigNumber.from(num).mul(BigNumber.from(10).pow(18));
}

async function advanceTime(time: number) {
  await ethers.provider.send("evm_increaseTime", [time]);
}

const ZeroAddress = 0x0000000000000000000000000000000000000000;

describe("RewardDistributorTest", function () {
  before(async function () {
    const signers = await ethers.getSigners();
    this.owner = signers[0];
    this.signer1 = signers[1];
    this.signer2 = signers[2];
    this.signer5 = signers[5];

    this.values = [
      [signers[1].address, expandTo18Decimals(1).toString()],
      [signers[2].address, expandTo18Decimals(2).toString()],
      [signers[3].address, expandTo18Decimals(1).toString()],
      [signers[4].address, expandTo18Decimals(1).toString()],
    ];

    this.tree = StandardMerkleTree.of(this.values, ["address", "uint256"]);
  });

  beforeEach(async function () {
    const RewardDistributor = await ethers.getContractFactory(
      "RewardDistributor"
    );
    this.rd = await RewardDistributor.deploy(this.owner.address);
    await this.rd.deployed();
  });

  it("should setMerkleRoot successful", async function () {
    await this.rd.connect(this.owner).setMerkleRoot(this.tree.root);
    expect(await this.rd.merkleRoot(), this.tree.root);
  });

  it("should set ZeroAddress as MerkleRoot failed", async function () {
    await expect(
      this.rd
        .connect(this.owner)
        .setMerkleRoot(ethers.utils.formatBytes32String(""))
    ).to.be.revertedWith("ZeroRootSet()");
  });

  it("should setMerkleRoot twice failed", async function () {
    await this.rd
      .connect(this.owner)
      .setMerkleRoot(ethers.utils.randomBytes(32));
    await expect(
      this.rd.connect(this.owner).setMerkleRoot(ethers.utils.randomBytes(32))
    ).to.be.revertedWith("RootSetTwice()");
  });

  it("test setClaimPeriodEnds", async function () {
    const { timestamp } = await ethers.provider.getBlock("latest");
    await this.rd
      .connect(this.owner)
      .setClaimPeriodEnds(timestamp + 60 * 60 * 7);
    expect(await this.rd.claimPeriodEnds()).eq(timestamp + 60 * 60 * 7);
  });

  it("test claimTokens", async function () {
    const { timestamp } = await ethers.provider.getBlock("latest");
    await this.rd.connect(this.owner).setMerkleRoot(this.tree.root);
    await this.rd
      .connect(this.owner)
      .setClaimPeriodEnds(timestamp + 60 * 60 * 7);
    await this.owner.sendTransaction({
      to: this.rd.address,
      value: expandTo18Decimals(5).toString(),
    });
    const proof = this.tree.getProof(0);
    await this.rd
      .connect(this.signer1)
      .claimTokens(expandTo18Decimals(1), proof);
  });

  it("should claimToken failed when time is expires", async function () {
    const { timestamp } = await ethers.provider.getBlock("latest");
    await this.rd.connect(this.owner).setMerkleRoot(this.tree.root);
    await this.rd.connect(this.owner).setClaimPeriodEnds(timestamp + 10);
    await advanceTime(60);
    await this.owner.sendTransaction({
      to: this.rd.address,
      value: expandTo18Decimals(5).toString(),
    });
    const proof = this.tree.getProof(0);
    await expect(
      this.rd.connect(this.signer1).claimTokens(expandTo18Decimals(1), proof)
    ).to.be.revertedWith("ClaimPeriodNotStartOrEnd()");
  });
});
