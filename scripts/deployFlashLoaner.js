const { ethers, run } = require("hardhat");
const { verify, wait } = require("./utils");


async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contract with the account:", deployer.address);
    
    const FlashLoaner = await ethers.getContractFactory("FlashLoaner");
    const flashLoaner = await FlashLoaner.deploy();
    await flashLoaner.deployTransaction.wait();

    console.log("flashLoaner address:", flashLoaner.address);
    await wait(10000);
    await verify(flashLoaner.address);
}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });