//SPDX-Licened-Identifier: MIT
pragma solidity ^0.8.13;

import "solmate/tokens/ERC20.sol";

contract DAI is ERC20 {
    constructor() ERC20("DAI", "DAI", 18) {}

    function _mint() public {
        _mint(msg.sender, 10000 * 10 ** 18);
    }

}
