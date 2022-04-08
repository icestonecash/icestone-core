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

    beforeEach(async () => {
        const prepared = await prepareContracts(wallet);
        token = prepared.token;
        contract = prepared.factory;
    });

    it("create stone", async () => {
        await expect(contract.createStone(token.address))
            .to.emit(contract, "NewStone")
    });

    it("create existing stone", async () => {
        await contract.createStone(token.address);
        await expect(contract.createStone(token.address))
            .to.be.revertedWith("already-exists-stone");
    });

    it("stone name & symbol", async () => {
        await contract.createStone(token.address);
        const stoneAddr = await contract.allStones(token.address);
        const stone = new ethers.Contract(stoneAddr, Stone.abi, wallet.connect(provider));

        const name = await stone.name();
        const symbol = await stone.symbol();
        const namePrefix = await contract.NAME_PREFIX();
        const symbolPrefix = await contract.SYMBOL_PREFIX();

        expect(symbol).equal(`${symbolPrefix}USDT`)
        expect(name).equal(`${namePrefix}USDT`)
    });
});