import { ethers, upgrades } from "hardhat";
require("@nomiclabs/hardhat-etherscan");
const hre = require("hardhat");

//npx hardhat run scripts/Deploy_MembershipProxy.ts --network opGoerli
//npx hardhat verify --network opGoerli 0xfb4e6dd0ECD25F47CfcD404B0aA7dbF5cD6e61cB 
async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    //deploy MembershipProxy contract
    const MembershipContract = await ethers.getContractFactory("DagoraMembershipsV1");
    const membershipProxy = await upgrades.deployProxy(MembershipContract, [
        'Dagora Memberships',
        'DAGORA', 
        'https://decentragora.xyz/api/tokenid/',
        '0x1de380594de7aba6442d879713c86ba7395abe7b',
        '0xD68E69e2B5AE5baB29ff2DD363Ce1685465Df531'
    ]);
    await membershipProxy.deployed();

    console.log('Contract deployed, setting proxy address...')

    const setting = await membershipProxy.setProxyAddress(membershipProxy.address);
    await setting.wait();
    
    console.log("MembershipProxy deployed to:", membershipProxy.address);

}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  