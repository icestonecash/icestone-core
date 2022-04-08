const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Address:", deployer.address);

    const router = await ethers.getContractAt("StoneRouter", process.env.ROUTER);

    console.log("Router address:", router.address);
    const block = await ethers.provider.getBlock("latest");
    tx = await router.depositEth(deployer.address, block.timestamp + 100, {
        value: ethers.utils.parseEther(process.env.AMT)
    });
    console.log(tx.hash);
    await tx.wait();


}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });