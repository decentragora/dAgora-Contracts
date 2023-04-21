require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

module.exports = [
        'AG test', //name
        'ASTST',   //symbol
        ["0x7c3bA47e39741B37F6093b1c2E534f1E84C0B36b", "0x59992E3626D6d5471D676f2de5A6e6dcF0e06De7"],   //payees
        [50, 50],   //shares
        "5000000000000000",   //price
        1000, //maxSupply
        5,  //bulkBuyLimit
        'Test',   //baseURI
        '.json',     //tbase ext
        "0x7c3bA47e39741B37F6093b1c2E534f1E84C0B36b",  //newowner
  ];
  
// npx hardhat verify --network opGoerli --constructor-args paymentSplitterArgs.ts 0x86FE2a328C106aC6a713e31D28a36B47c27a8b75
// npx hardhat verify --network opGoerli --constructor-args powerPlusArgs.ts 0x715e0552B9517C85fc1C230195239bCc90139002