const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("AppWorkSchoolNFT", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const AppWorkSchoolNFT = await ethers.getContractFactory("AppWorkSchoolNFT");
    const appWorkSchoolNFT = await AppWorkSchoolNFT.deploy();

    return { appWorkSchoolNFT, owner, otherAccount };
  }

  describe("Open mint", function () {
    it("Should open mint function", async function () {
      const { appWorkSchoolNFT } = await loadFixture(deployOneYearLockFixture);
      await appWorkSchoolNFT.toggleMint()
      expect(await appWorkSchoolNFT.mintActive()).to.equal(true);
    });
  });
});
