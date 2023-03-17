// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.17;

// import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
// import {ERC20PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";

// contract DagoraERC20UpgradeableImplementation is OwnableUpgradeable, ERC20PausableUpgradeable {

//     bool public isPaused;

//     uint256 public maxSupply;

//     function initialize(
//         string memory name,
//         string memory symbol,
//         address _newOwner,
//         uint256 initialSupply,
//         uint256 _maxSupply
//     ) public initializer {
//         __ERC20_init(name, symbol);
//         __ERC20Pausable_init();
//         __Ownable_init();
//         maxSupply = _maxSupply;
//         _transferOwnership(_newOwner);
//         isPaused = false;
//         _mint(_newOwner, initialSupply);
//     }

//     function mint(address to, uint256 amount) external onlyOwner {
//         require(totalSupply() + amount <= maxSupply, "dAgoraERC20: max supply reached");
//         require(to != address(0), "dAgoraERC20: mint to the zero address");
//         _mint(to, amount);
//     }

//     function burn(address from, uint256 amount) external onlyOwner {
//         _burn(from, amount);
//     }

//     function togglePaused() external onlyOwner {
//         isPaused = !isPaused;
//     }

//     function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
//         require(!paused(), "dAgoraERC20: token transfer paused");
//         super._beforeTokenTransfer(from, to, amount);
//     }
// }