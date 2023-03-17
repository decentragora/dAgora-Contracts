import { ethers, upgrades } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  //deploy SimpleNFTA
  const SimpleNFTA = await ethers.getContractFactory("SimpleNFTA");
  const simpleNFTA = await SimpleNFTA.deploy();
  await simpleNFTA.deployed();
  await simpleNFTA.initSimpleNFTA(
    "SimpleNFTA",
    "SNFTA",
    "https://dagora.io/nft/",
    10,
    ethers.utils.parseEther("0.1"),
    100,
    deployer.address
  );

  //deploy faccotr proxxy
  const Factory = await ethers.getContractFactory("dAgoraFactory");
  const factoryProxy = await upgrades.deployProxy(Factory, [
    simpleNFTA.address,
  ]);
  await factoryProxy.deployed();


  console.log("SimpleNFTA deployed to:", simpleNFTA.address);
  console.log("Factory deployed to:", factoryProxy.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
