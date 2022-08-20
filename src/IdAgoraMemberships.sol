// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "ERC721A/IERC721A.sol";

interface IdAgoraMembership is IERC721A {
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
