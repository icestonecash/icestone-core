const fs = require("fs");

async function main() {
    const [deployer] = await ethers.getSigners();

    const TUC = await ethers.getContractFactory("TokenUriConstructor");
    const tuc = await TUC.deploy();

    const uri = await tuc.construct("10", 6, "USDT", "1", "0xbE7604c3d86C7cAB061E1B920d4A7A10E6C9DcAE", 100, 0);
    const uriDecoded = (new Buffer(uri.slice("data:application/json;base64,".length),"base64")).toString("ascii");
    console.log(uriDecoded);
    const uriJson = JSON.parse(uriDecoded);
    const svgDecoded = (new Buffer(uriJson.image.slice("data:image/svg+xml;base64,".length),"base64")).toString("ascii");
    console.log(svgDecoded);
    fs.writeFileSync("image.svg", svgDecoded);
}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });