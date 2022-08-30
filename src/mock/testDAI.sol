//SPDX-Licened-Identifier: MIT
pragma solidity ^0.8.13;

import "solmate/tokens/ERC20.sol";

contract TestDAI is ERC20 {
    constructor() ERC20("TestDAI", "TDAI", 18) {}

    function _mint() public {
        _mint(msg.sender, 10000 * 10 ** 18);
    }

}
