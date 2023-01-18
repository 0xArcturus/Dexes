// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LPToken is ERC20 {
    address public DexAddress;

    constructor(address _dexAddress) public ERC20("LP", "LP") {
        DexAddress = _dexAddress;
    }

    modifier onlyOwner() {
        require(msg.sender == DexAddress, "not owner");
        _;
    }

    function mintTokensTo(address mintRecipient, uint256 tokensToMint) public onlyOwner {
        _mint(mintRecipient, tokensToMint);
    }

    function burnTokensTo(address mintRecipient, uint256 tokensToBurn) public onlyOwner {
        _burn(mintRecipient, tokensToBurn);
    }
}
