import { ethers, upgrades } from "hardhat";
require("@nomiclabs/hardhat-etherscan");
const hre = require("hardhat");

{/*
npx hardhat run scripts/Upgrade_Membership..ts --network opGoerli 

0x2866eedf82B941CeE9a7a17eF14b28112272633d
*/}
{/*
npx hardhat verify --network opGoerli 0x1F30135dec5A1d562DEEFffaF30501C11E7b6977 
*/}
async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    //deploy MembershipProxy contract
    const upgrade = await ethers.getContractFactory("DagoraMembershipsV1");
    console.log("Upgrading MembershipProxy...")
    const membershipProxy = await upgrades.upgradeProxy('0x2866eedf82B941CeE9a7a17eF14b28112272633d', upgrade, { unsafeAllowCustomTypes: true });
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