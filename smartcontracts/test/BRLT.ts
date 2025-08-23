import { expect } from "chai";
import hre, { ethers } from "hardhat";
import { BRLT } from "../types/ethers-contracts/BRLT.js";
import { Signer } from "ethers";

describe("BRLT", function () {
  let deployer: Signer;
  let user1: Signer;
  let user2: Signer;
  let BRLTContract: BRLT;
  beforeEach(async function () {
    [deployer, user1, user2] = await hre.ethers.getSigners();

    const BRLTContractDeployer = await hre.ethers.getContractFactory("BRLT");
    BRLTContract = await BRLTContractDeployer.deploy();
    await BRLTContract.waitForDeployment();
  });

  it("Balance of deployer should be 100000*10**18", async function () {
    const balance = await BRLTContract.balanceOf(await deployer.getAddress());
    expect(balance).to.equal(ethers.parseEther("100000"));
  });

  it("Balance of user1 should be 0", async function () {
    const balance = await BRLTContract.balanceOf(await user1.getAddress());
    expect(balance).to.equal("0");
  });

  it("Balance of user2 should be 0", async function () {
    const balance = await BRLTContract.balanceOf(await user2.getAddress());
    expect(balance).to.equal("0");
  });

  it("Transfer 1337 BRLTs from deployer to user1", async function () {
    const tx = await BRLTContract.transfer(await user1.getAddress(), "1337");
    await tx.wait();

    const balance = await BRLTContract.balanceOf(await user1.getAddress());
    expect(balance).to.equal("1337");
  });
});
