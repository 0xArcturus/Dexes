// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//This is an exercise to put into practice a basic Dex based on Uniswap's V1 protocol,
//as a pair that exchanges native ETH with the ERC20 token address we introduce on contract deployment.
contract MinimalViableDexV1 {
    using SafeMath for uint256;
    IERC20 token;
    uint256 public totalLiquidity;
    mapping(address => uint256) public liquidityProvided;

    constructor(address yeahTokenAddress) public {
        token = IERC20(yeahTokenAddress);
    }

    function init(uint256 tokens) public payable returns (uint256) {
        require(totalLiquidity == 0, "dex has already been initialized");
        //if someone send eth before calling the init function, the liquidity provided will be captured by
        //the user that calls init.
        totalLiquidity = address(this).balance;
        liquidityProvided[msg.sender] = totalLiquidity;
        require(token.transferFrom(msg.sender, address(this), tokens)); //transfer call for the amount we set as an input to this func
        return totalLiquidity;
    }

    function price(uint256 a, uint256 x, uint256 y) private pure returns (uint256) {
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
        uint256 tokensBought = price(msg.value, address(this).balance.sub(msg.value), tokenReserve); // a , x=x'- a, y
        require(token.transfer(msg.sender, tokensBought), "failed to transfer ETH");
        return tokensBought;
    }

    function tokenToEth(uint256 tokens) public payable returns (uint256) {
        uint256 tokenReserve = token.balanceOf(address(this));
        //in this case, tokens is X, Y is eth
        //y - b = y'
        //how many ETH are we getting?
        uint256 ethBought = price(tokens, tokenReserve, address(this).balance); // a , x, y
        require(token.transferFrom(msg.sender, address(this), tokens), "failed to transfer tokens");
        (bool sent, ) = msg.sender.call{value: ethBought}("");
        require(sent, "failed to send ETH");
        return ethBought;
    }

    function deposit() public payable returns (uint256) {
        //checks the original ETH reserve, subtracting what we have sent
        uint256 eth_reserve = address(this).balance.sub(msg.value);
        //Token reserve
        uint256 token_reserve = token.balanceOf(address(this));

        //token amount example with a pool with reserves of 4 eth and 8000 Dai
        // we send 1 eth, 1 * 8000 / 4 = 2000, therefore it will input the balance of 1 2000, which is correct.
        uint256 token_amount = (msg.value.mul(token_reserve) / eth_reserve).add(1);

        //((eth sent * total liquidity shares ) / eth reserves ) + 1
        // the previous formula with 18 decimals makes it so that the LP tokens minted to the user is
        //equal to the eth send, since the total liquidity shares in V1 is always going to be equal to the eth reserves.
        uint256 liquidity_minted = msg.value.mul(totalLiquidity) / eth_reserve;
        //liquidity tokens added to user balance
        liquidityProvided[msg.sender] = liquidityProvided[msg.sender].add(liquidity_minted);
        //update total liquidity for future liquidity operations
        totalLiquidity = totalLiquidity.add(liquidity_minted);
        //call transferFrom with the approved tokens to this contract to finish adding liquidity
        require(token.transferFrom(msg.sender, address(this), token_amount));
        return liquidity_minted;

        //on V2 the process is transferFunction agnostic, there is no approval, instead, the tokens must be sent to the contract,
        //the contract itself will keep track of the token balance after each interaction, and will calculate how many tokens you have sent,
        //based on the difference between the balanceOf its own address in the ERC20 contract, with its own balance data structure.
    }

    function withdraw(uint256 amount) public returns (uint256, uint256) {
        //ERC20 token call to know what is the balance of this contract
        uint256 token_reserve = token.balanceOf(address(this));
        //on the same pool mentioned before, with 5 eth and 10000 DAI the user inputs 1 as amount
        //1 * 5 / 5 = 1
        uint256 eth_amount = amount.mul(address(this).balance) / totalLiquidity;
        //1 * 10000 / 5 = 2000
        uint256 token_amount = amount.mul(token_reserve) / totalLiquidity;
        //liquidity subtracted from the users liquidity balance -1 = 0
        liquidityProvided[msg.sender] = liquidityProvided[msg.sender].sub(eth_amount);

        //transfer eth to user natively
        payable(msg.sender).transfer(eth_amount);
        //transfer 2000 dai to user
        require(token.transfer(msg.sender, token_amount));
        return (eth_amount, token_amount);
    }
}
