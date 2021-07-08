const PredictionMarket = artifacts.require('setBet');

module.exports = async function(deployer, _network, addresses)
{
    const [creator, better1, better2, better3, _] = addresses;
    await deployer.deploy(PredictionMarket);
    const predictionMarket = await PredictionMarket.deployed();
}
