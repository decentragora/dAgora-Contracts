// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title dAgora ERC20
/// @author Made By DecentrAgora
/// @notice a template for creating new ERC20 contracts.
contract DagoraERC20 is ERC20, Ownable {
    /// @notice Boolean to determine if the contract is paused.
    /// @dev default value is false, contract is not paused on deployment.
    bool public isPaused;

    /// @notice The maximum number of tokens that can be minted.
    uint256 public maxSupply;

    /// @notice The Contract that will be used to check if the user is a member.
    /// @param _name The name of the token.
    /// @param _symbol The symbol of the token.
    /// @param _newOwner The address that will be the owner of the contract.
    /// @param initialSupply The initial supply of the token to be minted to the _newOwner.
    /// @param _maxSupply The maximum supply of the token.
    constructor(string memory _name, string memory _symbol, address _newOwner, uint256 initialSupply, uint256 _maxSupply)
        ERC20(_name, _symbol)
    {
        _transferOwnership(_newOwner);
        maxSupply = _maxSupply;
        _mint(_newOwner, initialSupply);
        isPaused = false;
    }

    /// @notice OnlyOwner function to mint tokens.
    /// @param to The address that will receive the tokens.
    /// @param amount The amount of tokens to be minted.
    function mint(address to, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= maxSupply, "dAgoraERC20: max supply reached");
        require(to != address(0), "dAgoraERC20: mint to the zero address");
        _mint(to, amount);
    }

    /// @notice OnlyOwner function to burn tokens.
    /// @param from The address that will have the tokens burned.
    /// @param amount The amount of tokens to be burned.
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }

    /// @notice OnlyOwner function to toggle the paused state of the contract.
    function togglePaused() external onlyOwner {
        isPaused = !isPaused;
    }

    /// @notice check before every token transfer if the contract is paused.
    /// @param from The address that will send the tokens.
    /// @param to The address that will receive the tokens.
    /// @param amount The amount of tokens to be transferred.
    /// @dev This function overrides the _beforeTokenTransfer function from the ERC20 contract, and will fail if the contract is paused.
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        require(!isPaused, "dAgoraERC20: token transfer paused");
        super._beforeTokenTransfer(from, to, amount);
    }

    /// @notice Function to get the type of the contract.
    /// @return string The type of the contract.
    function typeOf() public pure returns (string memory) {
        return "dAgora ERC20";
    }

    /// @notice Function to get the version of the contract.
    /// @return string The version of the contract.
    function version() public pure returns (string memory) {
        return "1.0.0";
    }
}