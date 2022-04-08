const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Address:", deployer.address);

    const router = await ethers.getContractAt("StoneRouter", process.env.ROUTER);
    const token = await ethers.getContractAt("ERC20", process.env.TOKEN);
    const tokenId = process.env.TOKENID;

    console.log(`Approve ${tokenId}...`);
    let stoneAddress = await router.map(token.address);
    const stone = await ethers.getContractAt("Stone", stoneAddress);
    let tx = await stone.approve(router.address, tokenId);
    console.log(tx.hash);
    await tx.wait();

    console.log(`Withdraw ${tokenId}...`);
    tx = await router.withdraw(token.address, tokenId, deployer.address);
    console.log(tx.hash);
    await tx.wait();


}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
