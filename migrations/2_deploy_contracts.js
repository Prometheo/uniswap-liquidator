const BonusPepeToken = artifacts.require("BonusPepeToken.sol");
const LiquidityMigrator = artifacts.require("LiquidityMigrator.sol");


module.exports = async function (deployer) {
    await deployer.deploy(Migrations);
    const bonusPepeToken = await BonusPepeToken.Deployed();

    const routerAddress = '';
    const pairAddress = '';
    const routerForkAddress = '';
    const pairForkAddress = '';

    await deployer.deploy(
        LiquidityMigrator,
        routerAddress,
        routerForkAddress,
        pairForkAddress,
        bonusPepeToken.address
    );
    const liquidityMigrator = await LiquidityMigrator.deployed();
    await bonusPepeToken.setLiquidator(liquidityMigrator.address);
};
