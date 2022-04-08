import chai, { expect } from 'chai';
import { deployContract, MockProvider, solidity } from 'ethereum-waffle';
import { Contract } from 'ethers';
import FlashLoaner from "../build/FlashLoaner.json";
import prepareContracts from './prepareContracts';

chai.use(solidity);

describe('Stone', () => {
    const provider = new MockProvider();
    const [wallet, other] = provider.getWallets();
    let contract: Contract;
    let token: Contract;

    beforeEach(async () => {
        const prepared = await prepareContracts(wallet);
        token = prepared.token;
        contract = prepared.stone;

        expect(await token.balanceOf(wallet.address)).to.equal("0xffffffffffffffffff");

        await expect(token.approve(contract.address, 10000))
            .to.emit(token, "Approval")
            .withArgs(wallet.address, contract.address, 10000);
    });

    it("deposit", async () => {
        await expect(token.transfer(contract.address, 10000))
            .to.emit(token, "Transfer")
            .withArgs(wallet.address, contract.address, 10000);

        await expect(contract.mint(wallet.address, 1))
            .to.emit(contract, "Transfer")
            .withArgs("0x0000000000000000000000000000000000000000", wallet.address, 1);
    });

    it("withdraw", async () => {
        await token.transfer(contract.address, 10000);
        await contract.mint(wallet.address, 1);
        await expect(contract['burn(uint256)'](1))
            .to.emit(contract, "Transfer")
            .withArgs(wallet.address, "0x0000000000000000000000000000000000000000", 1);

        await expect(contract.withdraw(wallet.address))
            .to.emit(token, "Transfer")
            .withArgs(contract.address, wallet.address, 10000);
    });

    it("failure withdraw", async () => {
        const block = await provider.getBlock("latest");
        await token.transfer(contract.address, 10000);
        await contract.mint(wallet.address, block.timestamp + 100);

        await expect(contract['burn(uint256)'](1)).to.be.revertedWith("not-unlocked-stone");
        await expect(contract.connect(other)['burn(uint256)'](1)).to.be.revertedWith("not-owner-call");
    });

    it("zero deposit", async () => {
        await expect(contract.mint(wallet.address, 1)).to.be.revertedWith("amountin-zero");
    });

    it("zero withdraw", async () => {
        await expect(contract.withdraw(wallet.address)).to.be.revertedWith("amountin-zero");
    });

    it("skim", async () => {
        await token.transfer(contract.address, 10000);
        await expect(contract.withdraw(wallet.address))
            .to.emit(token, "Transfer")
            .withArgs(contract.address, wallet.address, 10000);
        
    });

    it("success flash", async () => {
        const amount = 100000;
        await token.transfer(contract.address, amount);
        await contract.mint(wallet.address, 1);

        const flashLoaner = await deployContract(wallet, FlashLoaner);
        await token.transfer(flashLoaner.address, 10);
        
        const fee = ((amount / 100000) * 5);
        const requiredAmountWithFee = amount + fee;
        await expect(flashLoaner.execute(contract.address, 100000))
            .to.emit(token, "Transfer")
            .withArgs(contract.address, flashLoaner.address, 100000)
            .to.emit(token, "Transfer")
            .withArgs(flashLoaner.address, contract.address, requiredAmountWithFee)
            .to.emit(token, "Transfer")
            .withArgs(contract.address, wallet.address, fee);
    });

    it("failure flash", async () => {
        await token.transfer(contract.address, 100000);
        await contract.mint(wallet.address, 1);

        const flashLoaner = await deployContract(wallet, FlashLoaner);
        await token.transfer(flashLoaner.address, 10);
        
        await expect(flashLoaner.executeFail(contract.address, 100000))
            .to.be.revertedWith("final-balance-is-small");
    });
});