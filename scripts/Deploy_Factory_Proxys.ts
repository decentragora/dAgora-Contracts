import { ethers, upgrades } from "hardhat";

//npx hardhat run scripts/Deploy_Factory_Proxys.ts --network opGoerli

// Verify ERC20 Factory implementation
//npx hardhat verify --network opGoerli 0xb72C91AFDB40E5Da8642BB9Da5446210A4229eD9
// npx hardhat verify --network opGoerli 0xf5AE5bb934aAbCd8058d82F0A78bae98226DC542
// npx hardhat verify --network opGoerli 0xbB30329Fcf765C0f833d66cD9b41a197073c1197

// Verify SimpleNFTA Factory implementation
// npx hardhat verify --network opGoerli 0xB93f7aDdf7FD51790a6460a2408722177b7e4102


// Verify NFTAPlus Factory implementation
// npx hardhat verify --network opGoerli 0x8ec3d73798f19bb839b2d20fafaa0b65a6204543

// Verify PowerNFT Factory implementation
// npx hardhat verify --network opGoerli 0x0E523D84e5eb8a36e7a12E9f815d66047A9e8998

// Verify PowerPlus Factory implementation
// npx hardhat verify --network opGoerli  0x389D23e725FFAA1272Aa735A57e5Dc8D7c36c664

// Verify ERC20 wizard implementation
// npx hardhat verify --network opGoerli 0xF60536eF5d640B8D7ee48747813BeB1C8d122f4F 'My Token' 'MTKN' 0x7c3bA47e39741B37F6093b1c2E534f1E84C0B36b 1000000000000000000000 10000000000000000000000

// Verify SimpleNFTA wizard implementation
// npx hardhat verify --network opGoerli 0x538e3c797Ccf868fB25e0d809A662013544D62b9 'My NFT' 'MNFT' 'testURI' 10 0 100 0x1De380594dE7ABA6442D879713c86Ba7395abE7B

// Verify NFTAPlus wizard implementation 
// npx hardhat verify --network opGoerli 0xcF061029cA22287CDae2e5c5225e845Bbd4c8DCB 'My NFTA Plus' 'NFTA+' 'TestURI' 10 5 0 0 1000 0x1De380594dE7ABA6442D879713c86Ba7395abE7B 0xe88b6918ec4ca7ca7675b7dfab9c0eefa73834b8c95bed2a2379943d472e7a44 

// Verify PowerNFT wizard implementation
// npx hardhat verify --network opGoerli 0xf2a825880Bb94f96Debc7Eb2d0dcb3DacdB7cDBb 'Power m8' 'PWR' 'test' 10 250 0 100 0x1De380594dE7ABA6442D879713c86Ba7395abE7B 0x1De380594dE7ABA6442D879713c86Ba7395abE7B

// Verify PowerPlus wizard implementation
// npx hardhat verify --network opGoerli 0x715e0552B9517C85fc1C230195239bCc90139002 ('Power Plus T' 'PWR+' 'test' 500 0 0 100 0x7c3bA47e39741B37F6093b1c2E534f1E84C0B36b 0x7c3bA47e39741B37F6093b1c2E534f1E84C0B36b 0xfa4c32f3ac23c082a110221d13c7db673357a5d4431918b8bdabc3ee4f676093)

// Verify PaymentSplitter wizard implementation
// npx hardhat verify --network opGoerli 0x86FE2a328C106aC6a713e31D28a36B47c27a8b75 'AG test' 'AGTST' ["0x7c3bA47e39741B37F6093b1c2E534f1E84C0B36b", "0x59992E3626D6d5471D676f2de5A6e6dcF0e06De7"] [50, 50] 5000000000000000 1000 10 'Test' '.json' "0x7c3bA47e39741B37F6093b1c2E534f1E84C0B36b"

async function main() {

    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const membershipAddress = '0x2866eedf82B941CeE9a7a17eF14b28112272633d'; //REAL
    /// get all factory contracts
    // const ERC20Factory = await ethers.getContractFactory("DagoraERC20Factory");
    // const SimpleNFTAFactory = await ethers.getContractFactory("DagoraSimpleNFTFactory");
    const PaymentSplitterFactory = await ethers.getContractFactory("DagoraPaymentSplitterFactory");
    // const DagoraNFTAPlusFactory = await ethers.getContractFactory("DagoraNFTAPlusFactory");
    // const PowerNFTAFactory = await ethers.getContractFactory("DagoraPowerNFTFactory");
    // const PowerPlusFactory = await ethers.getContractFactory("DagoraPowerPlusNFTFactory");

    //deploy all factory contracts
    // const erc20Factory = await upgrades.deployProxy(ERC20Factory, [membershipAddress]);
    // const simpleNFTAFactory = await upgrades.deployProxy(SimpleNFTAFactory, [membershipAddress]);
    const paymentSplitterFactory = await upgrades.deployProxy(PaymentSplitterFactory, [membershipAddress]);
    // const nftaPlusFactory = await upgrades.deployProxy(DagoraNFTAPlusFactory, [membershipAddress]);
    // const powerNFTAFactory = await upgrades.deployProxy(PowerNFTAFactory, [membershipAddress]);
    // const powerPlusFactory = await upgrades.deployProxy(PowerPlusFactory, [membershipAddress]);

    // await erc20Factory.deployed();
    // await simpleNFTAFactory.deployed();
    await paymentSplitterFactory.deployed();
    // await nftaPlusFactory.deployed();
    // await powerNFTAFactory.deployed();
    // await powerPlusFactory.deployed();

    // console.log("ERC20Factory deployed to:", erc20Factory.address);
    // console.log("SimpleNFTAFactory deployed to:", simpleNFTAFactory.address);
    console.log("PaymentSplitterFactory deployed to:", paymentSplitterFactory.address);
    // console.log("DagoraNFTAPlusFactory deployed to:", nftaPlusFactory.address);
    // console.log("PowerNFTAFactory deployed to:", powerNFTAFactory.address); 
    // console.log("PowerPlusFactory deployed to:", powerPlusFactory.address);
    
}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });