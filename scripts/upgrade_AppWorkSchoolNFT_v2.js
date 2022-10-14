const { ethers, upgrades } = require("hardhat");

const PROXY_CONTRACT = "0xF7f2747e7Bb7B468203cd3a97B74DFDaCa74c792"

async function main() {

  const AppWorkSchoolNFT_v2 = await ethers.getContractFactory("AppWorkSchoolNFT_v2");
  await upgrades.upgradeProxy(PROXY_CONTRACT, AppWorkSchoolNFT_v2);

  console.log(
    `AppWorkSchoolNFT upgraded to v2`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
