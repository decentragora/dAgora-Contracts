import { ethers, upgrades } from "hardhat";
require("@nomiclabs/hardhat-etherscan");
const hre = require("hardhat");

{/*
npx hardhat run scripts/Upgrade_Membership..ts --network opGoerli
*/}
{/*
npx hardhat verify --network opGoerli 0x84a48128c409cE9EBD10c0eD3c0f92b1a901f1E1 
*/}
async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    //deploy MembershipProxy contract
    const upgrade = await ethers.getContractFactory("DagoraMembershipsV1");
    const membershipProxy = await upgrades.upgradeProxy('0x2866eedf82b941cee9a7a17ef14b28112272633d', upgrade);
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