import chai, { expect } from 'chai';
import { MockProvider, solidity, MockContract } from 'ethereum-waffle';
import { Contract, ethers } from 'ethers';
import { increaseWorldTimeInSeconds } from './increaseWorldTimeInSeconds.spec';
import prepareContracts from './prepareContracts';
import Stone from "../build/Stone.json";

chai.use(solidity);

describe('IceStoneToken', () => {
    const provider = new MockProvider();
    const [wallet, other] = provider.getWallets();
    let token: Contract;
    let stone: Contract;
    let anyToken: Contract;

    beforeEach(async () => {
        const prepared = await prepareContracts(wallet);
        token = prepared.iceStoneToken;
        anyToken = prepared.token;
        await prepared.factory.createStone(anyToken.address);
        const stoneAddress = await prepared.factory.allStones(anyToken.address);
        stone = new ethers.Contract(stoneAddress, Stone.abi, wallet);
    });

    it("initial balance", async () => {
        expect(await token.balanceOf(wallet.address)).to.equal(10000)
    });

    it("transfer emits event", async () => {
        await expect(token.transfer(other.address, 7))
          .to.emit(token, "Transfer")
          .withArgs(wallet.address, other.address, 7)
    });

    it("transfer balance changed", async () => {
        await token.transfer(other.address, 7);

        expect(await token.balanceOf(wallet.address)).to.equal(10000-7);
        expect(await token.balanceOf(other.address)).to.equal(7);
    });

    it("can not transfer above the amount", async () => {
        await expect(token.transfer(other.address, 10007)).to.be.revertedWith("insufficient-funds");
    })
    
    it("burn", async () => {
        await expect(token.burn(7))
            .to.emit(token, "Transfer")
            .withArgs(wallet.address, "0x0000000000000000000000000000000000000000", 7);
        expect(await token.balanceOf(wallet.address)).to.equal(10000-7);
    });

    it("burnFrom", async () => {
        await token.approve(other.address, 7);

        await expect(token.connect(other).burnFrom(wallet.address, 7))
            .to.emit(token, "Transfer")
            .withArgs(wallet.address, "0x0000000000000000000000000000000000000000", 7);
        expect(await token.balanceOf(wallet.address)).to.equal(10000-7);
    });

    it("burnFrom without approve", async () => {
        await expect(token.connect(other).burnFrom(wallet.address, 7)).to.be.reverted;
        
        await token.approve(other.address, 7);
        await expect(token.connect(other).burnFrom(wallet.address, 8)).to.be.reverted;
    });

    it("claim", async() => {
        await anyToken.transfer(stone.address, "10000000000000000000");
        await stone.mint(wallet.address, 1);
        await token.setTokenRewardPerSecond(anyToken.address, 10853);

        await increaseWorldTimeInSeconds(provider, 3600*24*30, true);

        const claimableAmount = await token.claimableAmount(stone.address, 1);

        expect(claimableAmount).to.gt(0);
        await token.claim(stone.address, 1);
        expect(await token.claimableAmount(stone.address, 1)).to.eq(0);
        expect(await token.balanceOf(wallet.address)).to.gte(claimableAmount);
    });
});