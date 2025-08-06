const {ethers, upgrades} = require('hardhat');

async function main() {
    //Deploy TokenLocker Contract
    const TokenLocker = await ethers.getContractFactory('TokenLocker');
    const tokenLocker = await upgrades.deployProxy(TokenLocker,[],{initializer: 'initialize'});
    // await tokenLocker.waitForDeployment();

    console.log("TokenLocker deployed to (Proxy):",await tokenLocker.getAddress());


 }
main().catch((error) => {
    console.error(error);
    process.exit(1);
})