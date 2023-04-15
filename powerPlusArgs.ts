require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

// string name_;
// string symbol_;
// string baseURI_;
// uint16 _bulkBuyLimit;
// uint16 _maxAllowListAmount;
// uint96 _royaltyBps;
// uint256 _mintPrice;
// uint256 _presaleMintCost;
// uint256 _maxSupply;
// address _royaltyRecipient;
// address _newOwner;
// bytes32 _merkleRoot;

// (string,string,string,uint16,uint16,uint96,uint256,uint256,uint256,address,address,bytes32)
module.exports = [
    [
      "Test PWR+", //name
      "Test",   //symbol
      "fds",   //baseuri
        10,   //bulkBuyLimit
        5,     //maxAllowListAmount
        500,  //royaltyBps
      0,    //uint16
      0,    //uint96
      100,  //uint256
      "0x5C05cDa796B474eEfc258C172F06d3f9A016bca3",
      "0x5C05cDa796B474eEfc258C172F06d3f9A016bca3",
      "0x517e19cd9adf1950ff1f51eb47223c1deb2c775e20569bbde7259ce47ce1da81",
    ],
  ];
  



// npx hardhat verify --network opGoerli --constructor-args powerPlusArgs.ts 0x715e0552B9517C85fc1C230195239bCc90139002