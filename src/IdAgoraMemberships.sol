// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "ERC721A/IERC721A.sol";

/// @title dAgora Memberships NFT Interface
/// @author DadlessNSad || 0xOrphan
/// @notice Used to interact with the dAgora Memberships NFT
interface IdAgoraMembership is IERC721A {
    /// @notice Emitted when a new membership is created and minted to a user address.
    /// @param receiver The address of the minter
    event Claimed(address receiver);

    /// @notice Event emitted whenever a claim is requested.
    /// @param receiver The address that receives the tokens.
    event ClaimRequested(address receiver);

    function freeClaim() external;

    function checkTokenTier(uint256 _tokenId) external view returns (uint256);

    function isValidMembership(uint256 _tokenId) external view returns (bool);

    function membershipExpiresIn(uint256 _tokenId)
        external
        view
        returns (uint256);

    function checkTokenIndexedToOwner(uint256 _tokenId)
        external
        view
        returns (address);
}
