import { MockProvider } from "ethereum-waffle";

export const increaseWorldTimeInSeconds = async (provider: MockProvider, seconds: number, mine: boolean = false) => {
    await provider.send("evm_increaseTime", [seconds]);
    if(mine) {
        await provider.send("evm_mine", []);
    }
}

export default increaseWorldTimeInSeconds;