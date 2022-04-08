import chai, { expect } from 'chai';
import { MockProvider, solidity } from 'ethereum-waffle';
import { Contract, ethers } from 'ethers';
import Stone from "../build/Stone.json";
import prepareContracts from './prepareContracts';

chai.use(solidity);

describe('StoneRouter', () => {
    const provider = new MockProvider();
    const [wallet, other] = provider.getWallets();
    let contract: Contract;
    let token: Contract;
    let weth: Contract;
    let factory: Contract;
    const stoneAddress = "0x9024d5ead6e506e72F223b728c7fC77fdb084CEA";

    beforeEach(async () => {
        const prepared = await prepareContracts(wallet);
        token = prepared.token;
        contract = prepared.router;
        weth = prepared.weth;
        factory = prepared.factory;
    });

    it("deposit", async () => {
        await token.approve(contract.address, 1000);
        expect(await contract.deposit(token.address, wallet.address, 1000, 1))
            .to.emit(token, "Transfer")
            .withArgs(wallet.address, stoneAddress, 1000);
    });

    it("withdraw by transfer erc721", async () => {
        await token.approve(contract.address, 1000);
        await contract.deposit(token.address, wallet.address, 1000, 1);
        const stoneAddress = await factory.allStones(token.address);
        const stone = new Contract(stoneAddress, Stone.abi, wallet.connect(provider));
        expect(await stone['safeTransferFrom(address,address,uint256)'](wallet.address, contract.address, 1))
            .to.emit(token, "Transfer")
            .withArgs(stone.address, wallet.address, 1000);
    });

    it("withdraw by approve", async () => {
        await token.approve(contract.address, 1000);
        await contract.deposit(token.address, wallet.address, 1000, 1);
        const stoneAddress = await factory.allStones(token.address);
        const stone = new Contract(stoneAddress, Stone.abi, wallet.connect(provider));
        await stone.approve(contract.address, 1);

        expect(await contract.withdraw(token.address, 1, wallet.address))
            .to.emit(token, "Transfer")
            .withArgs(stone.address, contract.address, 1000)
            .to.emit(token, "Transfer")
            .withArgs(contract.address, wallet.address, 1000);
    });

    // it("deposit eth", async () => {
    //     // await contract.deposit();
    // });

});