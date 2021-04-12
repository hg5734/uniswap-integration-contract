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
import "./interface/IUniswapV2Factory.sol";

contract UniswapV2Integration is OwnableUpgradeSafe {
    IUniswap public uniswap;
    IUniswapV2Factory public uniswapFactory;

    constructor(address _uniswap, address _uniswapFactory) public {
        uniswap = IUniswap(_uniswap);
        uniswapFactory = IUniswapV2Factory(_uniswapFactory);
    }

    function swapTokensForEth(
        address token,
        uint256 amountIn
    ) public {
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswap.WETH();
        IERC20(token).approve(address(uniswap), amountIn);
        (uint256 reserveA, uint256 reserveB, ) = pairInfo(
            path[0],
            uniswapFactory.getPair(path[0], path[1])[1],
            pairFor
        );
        uint256 amountOutMin = (reserveB / reserveA) * amountIn;
        uniswap.swapExactTokensForETH(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp + 30
        );
    }

    function swapTokensForToken(
        address token,
        address tokenOut,
        uint256 amountIn
    ) public {
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = tokenOut;
        (uint256 reserveA, uint256 reserveB, ) = pairInfo(
            path[0],
            path[1],
            uniswapFactory.getPair(path[0], path[1])
        );
        uint256 amountOutMin = (reserveB / reserveA) * amountIn;
        IERC20(token).approve(address(uniswap), amountIn);
        uniswap.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp + 30
        );
    }

    function swapEthForToken(address token, uint256 amountIn) public {
        address[] memory path = new address[](2);
        path[0] = uniswap.WETH();
        path[1] = address(token);
        (uint256 reserveA, uint256 reserveB, ) = pairInfo(
            path[0],
            path[1],
            uniswapFactory.getPair(path[0], path[1])
        );
        uint256 amountOutMin = (reserveB / reserveA) * amountIn;
        uniswap.swapExactETHForTokens(
            amountOutMin,
            path,
            msg.sender,
            block.timestamp + 30
        );
    }

    function setUniswapAddresses(address _factory, address _routerV02)
        external
        onlyOwner
    {
        require(_factory != address(0), "Zero address for UNI factory");
        require(_routerV02 != address(0), "Zero address for UNI router02");
        uniswapFactory = IUniswapV2Factory(_factory);
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

    function getTokenBalance(address _tokenContract, address _user)
        external
        view
        returns (uint256)
    {
        return IERC20(_tokenContract).balanceOf(_user);
    }
}
