// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, upgrades } = require("hardhat");

async function main() {

  //                                                       放 contract 名稱，非檔案名
  const AppWorkSchoolNFT = await ethers.getContractFactory("AppWorkSchoolNFT");
  const appWorkSchoolNFT = await upgrades.deployProxy(AppWorkSchoolNFT, { initializer: "initialize" });
  console.log(appWorkSchoolNFT)
  await appWorkSchoolNFT.deployed();


  console.log(
    `AppWorkSchoolNFT with 0.0000001 ETH and deployed to ${appWorkSchoolNFT.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
