import { ethers, upgrades } from "hardhat";

//npx hardhat run scripts/Deploy_Factory_Proxys.ts --network opGoerli
//npx hardhat verify --network opGoerli 0xb72C91AFDB40E5Da8642BB9Da5446210A4229eD9

async function main() {

    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const membershipAddress = '0x2866eedf82B941CeE9a7a17eF14b28112272633d';
    /// get all factory contracts
    const ERC20Factory = await ethers.getContractFactory("DagoraERC20Factory");
    // const DagoraNFTAPlusFactory = await ethers.getContractFactory("DagoraNFTAPlusFactory");
    // const PowerNFTAFactory = await ethers.getContractFactory("DagoraPowerNFTFactory");
    // const PowerPlusFactory = await ethers.getContractFactory("DagoraPowerPlusNFTFactory");
    // const SimpleNFTAFactory = await ethers.getContractFactory("DagoraSimpleNFTFactory");

    //deploy all factory contracts
    const erc20Factory = await upgrades.deployProxy(ERC20Factory, [membershipAddress]);
    // const nftaPlusFactory = await upgrades.deployProxy(DagoraNFTAPlusFactory, [membershipAddress]);
    // const powerNFTAFactory = await upgrades.deployProxy(PowerNFTAFactory, [membershipAddress]);
    // const powerPlusFactory = await upgrades.deployProxy(PowerPlusFactory, [membershipAddress]);
    // const simpleNFTAFactory = await upgrades.deployProxy(SimpleNFTAFactory, [membershipAddress]);

    await erc20Factory.deployed();
    // await nftaPlusFactory.deployed();
    // await powerNFTAFactory.deployed();
    // await powerPlusFactory.deployed();
    // await simpleNFTAFactory.deployed();

    console.log("ERC20Factory deployed to:", erc20Factory.address);
    // console.log("DagoraNFTAPlusFactory deployed to:", nftaPlusFactory.address);
    // console.log("PowerNFTAFactory deployed to:", powerNFTAFactory.address); 
    // console.log("PowerPlusFactory deployed to:", powerPlusFactory.address);
    // console.log("SimpleNFTAFactory deployed to:", simpleNFTAFactory.address);
    
}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });