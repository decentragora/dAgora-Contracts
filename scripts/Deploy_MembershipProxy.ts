import { ethers, upgrades } from "hardhat";
require("@nomiclabs/hardhat-etherscan");
const hre = require("hardhat");

//npx hardhat run scripts/Deploy_MembershipProxy.ts --network optimism
//npx hardhat verify --network optimism 0x88D829Bee83c024b28c28736e4C844214bBE11B1 
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
        '0x567582053C3Ad36494d4e4480f2dBB7aacf25C47', // Treasury
        '0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1' // Dai
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
