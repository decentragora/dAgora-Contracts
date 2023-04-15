const hre = require("hardhat");

async function main() {
  // const constructorArgs = require("../powerPlusArgs");
  // const contractAddress = "0x438372329620E99Db1A978C659C3230359D7fe01";
  // await hre.run("verify:verify", {
  //   network: "opGoerli",
  //   address: contractAddress,
  //   constructorArguments: constructorArgs,
  // });
  const constructorArgsPaymentSplitter = require("../paymentSplitterArgs");
  const contractAddressPaymentSplitter = "0x266480D544BcCC1BAf33369DA9bbf539fF9999F6";
  await hre.run("verify:verify", {
    network: "opGoerli",
    address: contractAddressPaymentSplitter,
    constructorArguments: constructorArgsPaymentSplitter,
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
