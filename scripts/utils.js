async function verify(address, args=[]) {
    try {
        await run("verify:verify", {
            address: address,
            constructorArguments: args
        });
    } catch(e) {
        console.log(e);
    }
}

async function wait(time) {
    return new Promise(done => {
        setTimeout(done, time);
    });
}

module.exports = {
    verify,
    wait
}