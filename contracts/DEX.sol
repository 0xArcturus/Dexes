// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DEXToken is ERC20 {
    address public controlMultiSig;

    constructor(address _controlMultiSig) public ERC20("DEX", "DEX") {
        _mint(msg.sender, 1000);
        controlMultiSig = _controlMultiSig;
    }

    modifier onlyOwner() {
        require(msg.sender == controlMultiSig, "not owner");
        _;
    }

    function mintTokensTo(address mintRecipient, uint256 tokensToMint) public onlyOwner {
        _mint(mintRecipient, tokensToMint);
    }
}
