async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Address:", deployer.address);

    const router = await ethers.getContractAt("StoneRouter", process.env.ROUTER);
    const token = await ethers.getContractAt("ERC20", process.env.TOKEN);

    console.log("Router address:", router.address);
    console.log("Token balance:", (await token.balanceOf(deployer.address)).toString());

    if((await token.allowance(deployer.address, router.address)).gt(0)) {
        console.log("Clear approve...");
        const tx = await token.approve(router.address, 0);
        console.log(tx.hash);
        await tx.wait();
    }

}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
