const BonusPepeToken = artifacts.require("BonusPepeToken.sol");
const LiquidityMigrator = artifacts.require("LiquidityMigrator.sol");
const UniPairAddress = artifacts.require("IUniswapV2Pair.sol")

module.exports = async function (deployer) {
    await deployer.deploy(BonusPepeToken);
    const bonusPepeToken = await BonusPepeToken.deployed();

    const routerAddress = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';
    const pairAddress = '0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f';
    const routerForkAddress = '0x204b3e86a41451E0bf4A526Eaaa81F9dB4e6f976';
    const pairForkAddress = '0xAd7E36dE9a9db9F474Ce9e18D47c45312Ed2580e';

    await deployer.deploy(
        LiquidityMigrator,
        routerAddress,
        pairAddress,
        routerForkAddress,
        pairForkAddress,
        bonusPepeToken.address
    );
    const liquidityMigrator = await LiquidityMigrator.deployed();
    await bonusPepeToken.setLiquidator(liquidityMigrator.address);
};
