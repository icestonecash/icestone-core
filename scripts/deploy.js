async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const TUC = await ethers.getContractFactory("TokenUriConstructor");
    const Factory = await ethers.getContractFactory("StoneFactory");
    const Router = await ethers.getContractFactory("StoneRouter");

    console.log("Deploy TokenUriConstructor...");
    const tuc = await TUC.deploy();
    await tuc.deployTransaction.wait();

    console.log("Deploy StoneFactory...");
    const factory = await Factory.deploy(tuc.address);
    await factory.deployTransaction.wait();

    console.log("Deploy StoneRouter...");
    const router = await Router.deploy(factory.address, "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270");
    await router.deployTransaction.wait();

    console.log("TUC address:", tuc.address);
    console.log("Factory address:", factory.address, `constructor("${tuc.address}")`);
    console.log("Router address:", router.address, `constructor("${factory.address}", "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270")`);
}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });