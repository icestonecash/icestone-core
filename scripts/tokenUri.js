async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());


    const TUC = await ethers.getContractFactory("TokenUriConstructor");
    const tuc = await TUC.deploy();

    console.log(await tuc.construct(1, "USDT", "1"));
}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });