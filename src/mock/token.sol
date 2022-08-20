//SPDX-Licened-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("Token", "TK") {}

    function _mint() public {
        _mint(msg.sender, 10000 * 10 ** 18);
    }
}
