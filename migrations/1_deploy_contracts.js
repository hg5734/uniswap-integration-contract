require('dotenv').config();

const UniswapV2Contract = artifacts.require('./UniswapV2Integration');

module.exports = async (deployer, network, accounts) => {
  const owner = accounts[0];

  if (network == "kovan") {

    let { DAI, UNISWAP_ROUTER, UNISWAP_FACTORY } = process.env
    let uniswapInstance = await deployer.deploy(UniswapV2Contract, UNISWAP_ROUTER, UNISWAP_FACTORY, { from: owner });
    uniswapInstance = await UniswapV2Contract.deployed();

    console.log('uniswap instance deployed', uniswapInstance.address);


    // let uniswapInstance = await UniswapV2Contract.at("0xaaeaCd5F4FB0526d153C668306CF59142b6D9b08")

    // SWAP for ETH to DAI
    console.log('balance before swap' + await uniswapInstance.getTokenBalance(DAI, owner));

    await uniswapInstance.swapEthForToken(DAI, web3.utils.toWei("0.2", "ether"), { from: owner, value : web3.utils.toWei("0.2", "ether") });

    console.log('balance before swap' + await uniswapInstance.getTokenBalance(DAI, owner))

  }
}