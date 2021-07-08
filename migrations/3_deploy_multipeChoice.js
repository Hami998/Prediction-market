const MultipleChoicePredictionMarket = artifacts.require('setMultipleBet');

module.exports = async function(deployer, _network, addresses)
{
    const [creator, better1, better2, better3, _] = addresses;
    await deployer.deploy(MultipleChoicePredictionMarket);
    const multipleChoicePredictionMarket = await MultipleChoicePredictionMarket.deployed();
}