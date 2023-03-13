import { ethers } from "hardhat";
import { expect } from "chai";
import { StandardMerkleTree } from "@openzeppelin/merkle-tree";

import { generageTestAccount, metadataList } from "./helper";

describe("NFTManager Test", async function () {
  before(async function () {
    const signers = await ethers.getSigners();

    this.owner = signers[0];
    this.signer = signers[1];
    this.user1 = signers[2];
    this.user2 = signers[3];
    this.user3 = signers[4];

    this.accounts = generageTestAccount(100);
    this.whiteList = generageTestAccount(98);
    this.whiteList.unshift(this.user1.address);
    this.whiteList.push(this.user2.address);

    const NFTManager = await ethers.getContractFactory("NFTManager");
    this.nftManager = await NFTManager.deploy();
    await this.nftManager.deployed();
    // initialize
    await this.nftManager.initialize("DegenZero", "DegenZ", this.owner.address);

    // update signers
    await this.nftManager.updateSigners([this.signer.address], []);
  });

  it("should airdrop to users successful", async function () {
    await this.nftManager.connect(this.signer).airdrop(this.accounts);
    expect(await this.nftManager.getLatestTokenId()).to.eq(100);
    expect(await this.nftManager.ownerOf(100)).to.eq(this.accounts[99]);
  });

  it("should airdrop to users twice failed", async function () {
    const accounts = this.accounts;
    accounts.push(accounts[accounts.length - 1]);
    await expect(
      this.nftManager.connect(this.signer).airdrop(accounts)
    ).to.be.revertedWith("AlreadyMinted");
  });

  it("should airdrop to users failed if not signer", async function () {
    await expect(
      this.nftManager.connect(this.user1).airdrop(this.accounts)
    ).to.be.revertedWith("NotSigner");
  });

  it("should white list accounts mint only once", async function () {
    const whiteList = this.whiteList.map((item: string) => [item]);
    // generate merkle tree
    const tree = StandardMerkleTree.of(whiteList, ["address"]);
    // set merkle tree root
    await this.nftManager.connect(this.owner).setMerkleRoot(tree.root);
    expect(await this.nftManager.merkleRoot()).to.eq(tree.root);

    // user in white list can mint
    const proof0 = tree.getProof(0);
    // this.user1 == this.whiteList[0]
    await this.nftManager.connect(this.user1).mint(proof0);
    // user in white list can only mint once
    await expect(
      this.nftManager.connect(this.user1).mint(proof0)
    ).to.be.revertedWith("AlreadyMinted");

    // only the user in white list can mint
    await expect(
      this.nftManager.connect(this.user3).mint(proof0)
    ).to.be.revertedWith("InvalidProof");
  });
});
