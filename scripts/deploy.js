const { ethers, run } = require("hardhat");
const { verify } = require("./utils.js");
const WETH = require("./WETH.js");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());
    const chainId = await deployer.getChainId();
    const wethAddress = WETH[chainId];
    
    const TUC = await ethers.getContractFactory("TokenUriConstructor");
    const Factory = await ethers.getContractFactory("StoneFactory");
    const Router = await ethers.getContractFactory("StoneRouter");
    const Token = await ethers.getContractFactory("IceStoneToken");

    console.log("Deploy TokenUriConstructor...");
    const tuc = await TUC.deploy();
    await tuc.deployTransaction.wait();

    console.log("Deploy StoneFactory...");
    const factory = await Factory.deploy(tuc.address);
    await factory.deployTransaction.wait();

    console.log("Deploy StoneRouter...");
    const router = await Router.deploy(factory.address, wethAddress);
    await router.deployTransaction.wait();

    console.log("Deploy IceStoneToken...");
    const token = await Token.deploy(factory.address, "1000000000000000000");
    await token.deployTransaction.wait();

    console.log("TUC address:", tuc.address);
    console.log("Factory address:", factory.address, `constructor("${tuc.address}")`);
    console.log("Router address:", router.address, `constructor("${factory.address}", "${wethAddress}")`);
    console.log("Token address:", token.address, `constructor("${factory.address}", "1000000000000000000")`);

    await verify(tuc.address);
    await verify(factory.address, [tuc.address]);
    await verify(router.address, [factory.address, wethAddress]);
    await verify(token.address, [factory.address, "1000000000000000000"]);
}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });