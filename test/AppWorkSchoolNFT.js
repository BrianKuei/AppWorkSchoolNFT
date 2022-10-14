const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { MerkleTree } = require('merkletreejs')
const keccak256 = require('keccak256')

describe("AppWorkSchoolNFT", function () {
  async function deployOneYearLockFixture() {

    const [owner, otherAccount] = await ethers.getSigners();

    const AppWorkSchoolNFT = await ethers.getContractFactory("AppWorkSchoolNFT");
    const appWorkSchoolNFT = await AppWorkSchoolNFT.deploy();

    return { appWorkSchoolNFT, owner, otherAccount };
  }

  describe("mint some NFT", function () {

    it("It should mint NFT successfully", async function () {
      const { appWorkSchoolNFT } = await loadFixture(deployOneYearLockFixture);
      const tokenURI = "https://uri";
      
      await appWorkSchoolNFT.toggleMint()
      await appWorkSchoolNFT.mint(10, tokenURI, { value: ethers.utils.parseEther("0.1") });
      
      expect(await appWorkSchoolNFT.mintActive()).to.equal(true);
      expect(await appWorkSchoolNFT.addressMintedBalance(appWorkSchoolNFT.owner())).to.equal(10);
    });
  });

  describe("early mint NFT", function () {
    it("It should mint NFT successfully", async function () {
      const { appWorkSchoolNFT, owner } = await loadFixture(deployOneYearLockFixture);
      const ownerAddress = owner.address;
      const tokenURI = "https://uri";
      const whitelisted = [
        "0x1C541e05a5A640755B3F1B2434dB4e8096b8322f",
        "0x1071258E2C706fFc9A32a5369d4094d11D4392Ec",
        "0x25f7fF7917555132eDD3294626D105eA1C797250",
        "0xF6574D878f99D94896Da75B6762fc935F34C1300",
        ownerAddress
      ]
      const buf2hex = x => '0x' + x.toString('hex')
      const leaves = whitelisted.map(addr => keccak256(addr))
      const tree = new MerkleTree(leaves, keccak256, { sortPairs: true })
      const root = buf2hex(tree.getRoot())
      const leaf = keccak256(ownerAddress);
      const proof = tree.getProof(leaf).map(x => buf2hex(x.data))

      await appWorkSchoolNFT.setMerkleRoot(root);
      await appWorkSchoolNFT.toggleEarlyMint();
      await appWorkSchoolNFT.earlyMint(proof, 10, tokenURI, { value: ethers.utils.parseEther("0.1") });
      
      expect(await appWorkSchoolNFT.merkleRoot()).to.equal(true);
      expect(await appWorkSchoolNFT.addressMintedBalance(ownerAddress)).to.equal(10);
    });
  });

  describe("update price", function () {
    it("It should update NFT price ", async function () {
      const { appWorkSchoolNFT } = await loadFixture(deployOneYearLockFixture);

      const oldPrice = ethers.utils.formatUnits(await appWorkSchoolNFT.price(), "ether");

      await appWorkSchoolNFT.setPrice(ethers.utils.parseEther("0.02"));

      const newPrice = ethers.utils.formatUnits(await appWorkSchoolNFT.price(), "ether");

      expect(oldPrice).to.eq("0.01");
      expect(newPrice).to.eq("0.02");
    });
  })
});
