// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YEAHToken is ERC20 {
    address public controlMultiSig;

    constructor(address _controlMultiSig) public ERC20("Yeah", "YEAH") {
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
