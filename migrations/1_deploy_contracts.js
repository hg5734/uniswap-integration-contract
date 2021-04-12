require('dotenv').config();

const UniswapV2Contract = artifacts.require('./UniswapV2Integration');

module.exports = async (deployer, network, accounts) => {
  const owner = accounts[0];

  if (network == "kovan") {
    let uniswapInstance = await deployer.deploy(UniswapV2Contract, { from: owner });
    uniswapInstance = await UniswapV2Contract.deployed();
    console.log('uniswap instance deployed', uniswapInstance.address);
  }
}