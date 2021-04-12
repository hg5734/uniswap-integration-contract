// SPDX-License-Identifier: MIT

/**
 * @summary: Uniswap Integration
 * @author: Himanshu Goyal
 */

pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";

import "./interface/IUniswap.sol";
import "./interface/IUniswapV2Pair.sol";

contract UniswapV2Integration is OwnableUpgradeSafe {
    IUniswap public uniswap;
    address public uniswapFactory;

    constructor(address _uniswap, address _uniswapFactory) public {
        uniswap = IUniswap(_uniswap);
        uniswapFactory = _uniswapFactory;
    }

    function swapTokensForEth(
        address token,
        uint256 amountIn,
        address pairFor
    ) public {
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswap.WETH();
        IERC20(token).approve(address(uniswap), amountIn);
        (uint256 reserveA, uint256 reserveB, ) = pairInfo(
            path[0],
            path[1],
            pairFor
        );
        uint256 amountOutMin = (reserveB / reserveA) * amountIn;
        uniswap.swapExactTokensForETH(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );
    }

    function swapTokensForToken(
        address token,
        address tokenOut,
        uint256 amountIn,
        address pairFor
    ) public {
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = tokenOut;
        (uint256 reserveA, uint256 reserveB, ) = pairInfo(
            path[0],
            path[1],
            pairFor
        );
        uint256 amountOutMin = (reserveB / reserveA) * amountIn;
        IERC20(token).approve(address(uniswap), amountIn);
        uniswap.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );
    }

    function swapEthForToken(
        address token,
        uint256 amountIn,
        address pairFor
    ) public {
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = uniswap.WETH();
        IERC20(token).approve(address(uniswap), amountIn);
        (uint256 reserveA, uint256 reserveB, ) = pairInfo(
            path[0],
            path[1],
            pairFor
        );
        uint256 amountOutMin = (reserveB / reserveA) * amountIn;
        uniswap.swapExactETHForTokens(
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );
    }

    function setUniswapAddresses(address _factory, address _routerV02)
        external
        onlyOwner
    {
        require(_factory != address(0), "Zero address for UNI factory");
        require(_routerV02 != address(0), "Zero address for UNI router02");
        uniswapFactory = _factory;
        uniswap = IUniswap(_routerV02);
    }

    function pairInfo(
        address _tokenA,
        address _tokenB,
        address pairFor
    )
        public
        view
        returns (
            uint256 reserveA,
            uint256 reserveB,
            uint256 totalSupply
        )
    {
        IUniswapV2Pair pair = IUniswapV2Pair(pairFor);
        totalSupply = pair.totalSupply();
        (uint256 reserves0, uint256 reserves1, ) = pair.getReserves();
        (reserveA, reserveB) = _tokenA == pair.token0()
            ? (reserves0, reserves1)
            : (reserves1, reserves0);
        return (reserveA, reserveB, totalSupply);
    }
    
}
