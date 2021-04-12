// SPDX-License-Identifier: MIT

/**
 * @summary: Uniswap Integration
 * @author: Himanshu Goyal
 */

pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "./interface/IUniswap.sol";

contract UniswapV2Integration {
    IUniswap public uniswap;

    constructor(address _uniswap) public {
        uniswap = IUniswap(_uniswap);
    }

    function swapTokensForEth(address token, uint amountIn, uint amountOutMin, uint deadline) public {
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswap.WETH();
        IERC20(token).approve(address(uniswap), amountIn);
        uniswap.swapExactTokensForETH(
          amountIn,
          amountOutMin,
          path,
          msg.sender,
          deadline
        );
    }

     function swapTokensForToken(address token, address tokenOut, uint amountIn, uint amountOutMin, uint deadline) public {
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = tokenOut;
        IERC20(token).approve(address(uniswap), amountIn);
        uniswap.swapExactTokensForTokens(
          amountIn,
          amountOutMin,
          path,
          msg.sender,
          deadline
        );
    }

     function swapEthForToken(address token, uint amountIn, uint amountOutMin, uint deadline) public {
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = uniswap.WETH();
        IERC20(token).approve(address(uniswap), amountIn);
        uniswap.swapExactETHForTokens(
          amountOutMin,
          path,
          msg.sender,
          deadline
        );
    }
}
