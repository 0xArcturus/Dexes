// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Dex {
    using SafeMath for uin256;
    IERC20 token;
    uint256 public totalLiquidity;
    mapping(address => uint256) public liquidityProvided;

    constructor(address ERC20TokenAddress) public {
        token = IERC20(ERC20TokenAddress);
    }

    function init(uint256 tokens) public payable returns (uint256) {
        require(totalLiquidity == 0, "dex has already been initialized");
        totalLiquidity = address(this).balance;
        liquidityProvided[msg.sender] = totalLiquidity;
        require(token.transferFrom(msg.sender, address(this), tokens)); //transfer call for the amount we set as an input to this func
        return totalLiquidity;
    }

    function price(uint256 a, uint256 x, uint256 y) private returns (uint256) {
        //the constant k remains the same
        //x * y = k
        // x * y = x' * y'

        //the amount of tokens we recieve depends on the multiplication of x and y to mantain the constant
        // x' * y' = k
        //a is the token amount we input in the exchange
        // x + a = x'
        //b is the token amount we recieve
        // y - b = y'

        //(x + a)(y - b) = k

        //solving to b we deduce:
        //b = (y * a) / (x + a)

        //with the 0,3% trading fee:
        //b = (y * a * 0,997) / (x + a * 0,997)

        uint256 input_with_fee = a.mul(997);
        uint256 numerator = y.mul(input_with_fee);
        uint256 denominator = x.mul(1000).add(input_with_fee);
        return numerator / denominator;
    }

    function ethToToken() public payable returns (uint256) {
        uint256 tokenReserve = token.balanceOf(address(this));
        //ETH is X, tokens are Y 
        //y - b = y'
        //how many tokens are we getting? 
        uint256 tokensBought = price(msg.value, address(this).balance.sub(msg.value), tokenReserve) // a , x=x'- a, y 
        require(token.transfer(msg.sender, tokensBought), "failed to transfer ETH");
        return tokensBought;

    }
    function tokenToEth(uint256 tokens) public payable returns (uint256) {
        uint256 tokenReserve = token.balanceOf(address(this));
        //in this case, tokens is X, Y is eth
        //y - b = y'
        //how many ETH are we getting?
        uint256 ethBought = price(tokens,tokenReserve, address(this).balance) // a , x, y 
        require(token.transferFrom(msg.sender, address(this), tokens), "failed to transfer tokens");
        (bool sent, ) = msg.sender.call{value: ethBought}("")
        require(sent, "failed to send ETH");
        return ethBought;

    }

    function deposit()
     public payable returns (uint256) {
        uint256 eth_reserve = address(this).balance.sub(msg.value);
        uint256 token_reserve = token.balanceOf(address(this));
        uint256 token_amount = (msg.value.mul(totalLiquidity) / eth_reserve).add(1);
        uint256 liquidity_minted = msg.value.mul(totalLiquidity) / eth_reserve;
        liquidityProvided[msg.sender] = liquidityProvided[msg.sender].add(liquidity_minted);
        totalLiquidity = totalLiquidity.add(liquidity_minted);
        require(token.transferFrom(msg.sender, address(this), token_amount));
        return liquidity_minted;


        
    }
}
