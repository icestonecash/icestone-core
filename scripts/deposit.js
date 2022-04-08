async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Address:", deployer.address);

    const router = await ethers.getContractAt("StoneRouter", process.env.ROUTER);
    const token = await ethers.getContractAt("ERC20", process.env.TOKEN);
    const amount = parseInt(process.env.AMT);

    console.log("Router address:", router.address);
    console.log("Token balance:", (await token.balanceOf(deployer.address)).toString());


    console.log("Deposit...");
    tx = await router.deposit(token.address, deployer.address, amount, 1);
    console.log(tx.hash);
    await tx.wait();


}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
