import { ethers, upgrades } from "hardhat";
require("@nomiclabs/hardhat-etherscan");
const hre = require("hardhat");

//npx hardhat run scripts/Upgrade_Membership..ts --network opGoerli
//npx hardhat verify --network opGoerli 0xAcad08550039581513B6d21420A32782031A1fe3 
async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    //deploy MembershipProxy contract
    const upgrade = await ethers.getContractFactory("DagoraMembershipsV1");
    const membershipProxy = await upgrades.upgradeProxy('0xc552c5956C972d29fde1bACe3BB82591b62D36FD', upgrade);
    await membershipProxy.deployed();

    console.log("The Tx receipt is:", membershipProxy.deployTransaction);
    console.log("MembershipProxy deployed to:", membershipProxy.address);

}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });