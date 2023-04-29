require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

module.exports = [
        'testter2', //name
        'Test',   //symbol
        ["0x7c3bA47e39741B37F6093b1c2E534f1E84C0B36b", "0x59992E3626D6d5471D676f2de5A6e6dcF0e06De7"],   //payees
        [50, 50],   //shares
        "5000000000000000",   //price
        250, //maxSupply
        5,  //bulkBuyLimit
        'Test',   //baseURI
        '.json',     //tbase ext
        "0x7c3bA47e39741B37F6093b1c2E534f1E84C0B36b",  //newowner
  ];
  
// npx hardhat verify --network opGoerli --constructor-args paymentSplitterArgs.ts 0xD8C97f302782cea98c7Fb5BDc5f6BcD53687f8cd
// npx hardhat verify --network opGoerli --constructor-args powerPlusArgs.ts 0x715e0552B9517C85fc1C230195239bCc90139002