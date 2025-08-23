import { expect } from "chai";
import hre from "hardhat";
import { Signer } from "ethers";
import { Bound } from "../typechain-types/index.js";

describe("Bound", function () {
  let deployer: Signer;
  let user1: Signer;
  let user2: Signer;
  let BoundContract: Bound;
  beforeEach(async function () {
    [deployer, user1, user2] = await hre.ethers.getSigners();
    const BoundContractDeployer = await hre.ethers.getContractFactory("Bound");
    BoundContract = await BoundContractDeployer.deploy();
    await BoundContract.waitForDeployment();
  });

  it("Should create a bound", async function () {
    const tx = await BoundContract.createBound(
      await user1.getAddress(),
      "https://api.bound.com/token/1.json"
    );
    await tx.wait();

    const balance = await BoundContract.balanceOf(await user1.getAddress());
    expect(balance).to.equal("1");
  });

  it("Should create a bound and transfer it to user2", async function () {
    let tx = await BoundContract.connect(deployer).createBound(
      await user1.getAddress(),
      "https://api.bound.com/token/1.json"
    );
    await tx.wait();

    let owner = await BoundContract.ownerOf("1");
    expect(owner).to.equal(await user1.getAddress());

    // Approve user2 to transfer token 1 from user1
    tx = await BoundContract.connect(user1).approve(
      await user2.getAddress(),
      1
    );
    await tx.wait();

    tx = await BoundContract.connect(user1).transferFrom(
      await user1.getAddress(),
      await user2.getAddress(),
      1
    );
    await tx.wait();

    owner = await BoundContract.ownerOf("1");
    expect(owner).to.equal(await user2.getAddress());
  });
});
