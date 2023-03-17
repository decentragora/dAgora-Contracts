
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {ERC20} from 'solmate/src/tokens/ERC20.sol';

contract Dai is ERC20 {
    constructor() ERC20('Dai Stablecoin', 'DAI', 18) {}

    function mint() external {
        _mint(msg.sender, 10000 * 10**18);
    }
}