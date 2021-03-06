import { deployContract } from "ethereum-waffle";
import Stone from "../build/Stone.json";
import StoneRouter from "../build/StoneRouter.json";
import WETH from "../build/WETH9.json";
import TokenUriConstructor from "../build/TokenUriConstructor.json";
import ERC20 from "../build/ERC20.json";
import IceStoneToken from "../build/IceStoneToken.json";
import StoneFactory from "../build/StoneFactory.json";
import { Wallet } from "ethers";

async function prepareContracts(wallet: Wallet) {
    const tuc = await deployContract(wallet, TokenUriConstructor);
    const weth = await deployContract(wallet, WETH);
    const token = await deployContract(wallet, ERC20, ["Test Token", "USDT", 18, "0xffffffffffffffffff"]);
    const stone = await deployContract(wallet, Stone, [token.address, "Stone Test", "ST", tuc.address]);
    const factory = await deployContract(wallet, StoneFactory, [tuc.address]);
    const iceStoneToken = await deployContract(wallet, IceStoneToken, [factory.address, 10000]);
    const router = await deployContract(wallet, StoneRouter, [factory.address, weth.address]);

    return {token, stone, router, weth, factory, iceStoneToken, tuc};
}

export default prepareContracts;