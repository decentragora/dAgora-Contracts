const hre = require("hardhat");

async function main() {
  const constructorArgs = require("../powerPlusArgs");
  const contractAddress = "0x715e0552B9517C85fc1C230195239bCc90139002";
  await hre.run("verify:verify", {
    network: "opGoerli",
    address: contractAddress,
    constructorArguments: constructorArgs,
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
