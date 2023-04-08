import { ethers, upgrades } from "hardhat";
require("@nomiclabs/hardhat-etherscan");
const hre = require("hardhat");

//npx hardhat run scripts/Upgrade_Wizard_Proxys.ts --network opGoerli
async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    //Get all factory contract to upgrade
    // const ERC20Factory = await ethers.getContractFactory("DagoraERC20Factory");
    // const SimpleNFTAFactory = await ethers.getContractFactory("DagoraSimpleNFTFactory");
    // const DagoraNFTAPlusFactory = await ethers.getContractFactory("DagoraNFTAPlusFactory");
    const PowerNFTAFactory = await ethers.getContractFactory("DagoraPowerNFTFactory");
    const PowerPlusFactory = await ethers.getContractFactory("DagoraPowerPlusNFTFactory");

    // DagoraERC20FactoryAddress:   0x7c886aB95E32D2109866707Bd55E9BF5044A7f5E
    // SimpleNFTFactoryAddress:     0x5D0f338E2713EbCB1fd93cDE66Ac939778B56F3f
    // NFTAPlusFactoryAddress:      0xcae225EdD51997ad88c77277286B79bc5a0Dad89
    // PowerNFTFactoryAddress:      0x63Ae7A699589705628dE8f595f2dc9fF84286DFC
    // PowerPlusNFTFactoryAddress:  0x3741e8511b9db045c4751d070a0373BF0940242f

    //Upgrade all factory contract
    // const ERC20FactoryProxy = await upgrades.upgradeProxy("0x7c886aB95E32D2109866707Bd55E9BF5044A7f5E", ERC20Factory);
    // const SimpleNFTAFactoryProxy = await upgrades.upgradeProxy("0x5D0f338E2713EbCB1fd93cDE66Ac939778B56F3f", SimpleNFTAFactory);
    // const DagoraNFTAPlusFactoryProxy = await upgrades.upgradeProxy("0xcae225EdD51997ad88c77277286B79bc5a0Dad89", DagoraNFTAPlusFactory);
    const PowerNFTAFactoryProxy = await upgrades.upgradeProxy("0x63Ae7A699589705628dE8f595f2dc9fF84286DFC", PowerNFTAFactory);
    const PowerPlusFactoryProxy = await upgrades.upgradeProxy("0x3741e8511b9db045c4751d070a0373BF0940242f", PowerPlusFactory);

    // console.log("DagoraERC20FactoryProxy has been upgraded to:", ERC20FactoryProxy.address);
    // console.log("SimpleNFTFactoryProxy has been upgraded to:", SimpleNFTAFactoryProxy.address);
    // console.log("DagoraNFTAPlusFactoryProxy has been upgraded to:", DagoraNFTAPlusFactoryProxy.address);
    console.log("PowerNFTFactoryProxy has been upgraded to:", PowerNFTAFactoryProxy.address);
    console.log("PowerPlusFactoryProxy has been upgraded to:", PowerPlusFactoryProxy.address);

}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });