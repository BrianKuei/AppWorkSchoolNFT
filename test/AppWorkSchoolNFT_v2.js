const { expect } = require('chai');
const { ethers } = require('hardhat');

let AppWorkSchoolNFT_v2;
let appWorkSchoolNFT_v2;

describe("AppWorkSchoolNFT_v2", () => {
  beforeEach(async () => {
    AppWorkSchoolNFT_v2 = await ethers.getContractFactory("AppWorkSchoolNFT_v2");
    appWorkSchoolNFT_v2 = await AppWorkSchoolNFT_v2.deploy();

    await appWorkSchoolNFT_v2.deployed();
  })

  describe("open mint", () => {
    it("Should open mint function", async function () {
      await appWorkSchoolNFT_v2.toggleMint();
      expect(await appWorkSchoolNFT_v2.mintActive()).to.equal(true);
    });
  })
});