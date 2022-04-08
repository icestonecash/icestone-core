const { ethers, run } = require("hardhat");
const { verify } = require("./utils.js");
const WETH = require("./WETH.js");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());
    
    const Token = await ethers.getContractFactory("ERC20");

    console.log("Deploy Token...");
    const token = await Token.deploy("Envoys Token", "ETK", 18, "1000000000000000000000000");
    await token.deployTransaction.wait();

    console.log("Token address:", token.address);
}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });