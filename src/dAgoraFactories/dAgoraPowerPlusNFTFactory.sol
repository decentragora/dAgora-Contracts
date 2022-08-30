// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {PowerPlusNFT} from "../dAgoraWizards/PowerPlusNFT.sol";
import "../IdAgoraMemberships.sol";

/// @title PowerPlusNFT Factory
/// @author DadlessNsad || 0xOrphan
/// @notice Allows dAgora members to create new PowerPlusNFT contracts.
contract dAgoraPowerPlusNFTFactory is Ownable, ReentrancyGuard {
    PowerPlusNFT nft;

    struct Deploys {
        address[] ContractAddress;
        address Owner;
        uint256 contractId;
    }

    /// @notice The address of the dAgora Memberships contract.
    address public dAgoraMembership;

    /// @notice The total count of NFTs created for members..
    uint256 public powerPlusNFTCount = 0;

    /// @notice Used to pause and unpause the contract.
    bool public paused;

    /// @notice Maps deployed contracts to their owners.
    mapping(address => Deploys) private _deployedContracts;

    /// @notice Tracks users deployed contracts amount.
    mapping(address => uint256) public _addressDeployCount;

    /// @notice Emitted when a new NFT contract is deployed.
    /// @param powerPlusContract The address of the deployed contract.
    /// @param owner The address of the owner.
    /// @param _contractId Users total amount of deployed contracts.
    /// @param _powerPlusNFTCount The total amount of NFTs created for members.
    event PowerPlusNFTCreated(
        address powerPlusContract,
        address owner,
        uint256 _contractId,
        uint256 _powerPlusNFTCount
    );

    /// @notice Sets the contracts variables.
    /// @param _dAgoraMembership The address of the dAgora Memberships contract.
    constructor(address _dAgoraMembership) {
        dAgoraMembership = _dAgoraMembership;
    }

    /// @notice Checks if the contract is paused.
    modifier isPaused() {
        require(!paused, "Factory is paused");
        _;
    }

    /// @notice Function to create contracts for members.
    /// @param _name The name of the NFT.
    /// @param _symbol The symbol of the NFT.
    /// @param _baseURI The base URI of the NFT.
    /// @param _mintCost The cost to mint a NFT.
    /// @param _bulkBuyLimit the max amount of NFTs that can be minted at once.
    /// @param _maxWhiteListAmount The max amount of NFTs that can be minted by allow listed addresses.
    /// @param _royaltyCut The % of royalties to be paid to the creator.
    /// @param _newOwner The address of the new owner.
    /// @param _royaltyReceiver The address to receive royalties.
    /// @param _merkleRoot The merkle root of the allowed list addresses.
    /// @param _id The TokenId of the dAgora Membership NFT.
    function createPowerPlusNFT(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _mintCost,
        uint16 _bulkBuyLimit,
        uint16 _maxWhiteListAmount,
        uint256 _maxTotalSupply,
        uint96 _royaltyCut,
        uint256 _id,
        address _newOwner,
        address _royaltyReceiver,
        bytes32 _merkleRoot
    )
        public
        isPaused
        nonReentrant
    {
        require(_canCreate(_id) == true, "Must be a valid membership");

        require(_maxTotalSupply > 0, "Max supply must be greater than 0");

        require(
            _maxTotalSupply > _bulkBuyLimit,
            "Max supply must be greater than bulk buy limit"
        );

        require(_newOwner != address(0), "Owner cannot be 0x0");

        nft = new PowerPlusNFT(
            _name,
            _symbol,
            _baseURI,
            _mintCost,
            _bulkBuyLimit,
            _maxWhiteListAmount,
            _maxTotalSupply,
            _royaltyCut,
            _newOwner,
            _royaltyReceiver,
            _merkleRoot
        );

        powerPlusNFTCount++;
        _addressDeployCount[msg.sender]++;
        _deployedContracts[msg.sender].ContractAddress.push(address(nft));
        _deployedContracts[msg.sender].Owner = msg.sender;
        _deployedContracts[msg.sender].contractId = powerPlusNFTCount;
        emit PowerPlusNFTCreated(
            address(nft),
            msg.sender,
            _addressDeployCount[msg.sender],
            powerPlusNFTCount
            );
    }

    /// @notice Function to check users deployed contract addresses.
    /// @param _owner The address of the user we want to check.
    function deployedContracts(address _owner)
        public
        view
        returns (Deploys memory)
    {
        return _deployedContracts[_owner];
    }

    /// @notice Function allows owner to pause/unPause the contract.
    function togglePaused() public onlyOwner {
        paused = !paused;
    }

    /// @notice Function to check if a user is a valid member & can create NFT contracts.
    /// @param _id The TokenId of the dAgora Membership NFT.
    /// @return boolean

    function _canCreate(uint256 _id) internal view returns (bool) {
        require(
            IdAgoraMembership(dAgoraMembership).checkTokenTier(_id) > 1,
            "Must be tier 2 or higher"
        );

        require(
            IdAgoraMembership(dAgoraMembership).isOwnerOrDelegate(_id, msg.sender) == true,
            "Must be owner or delegate"
        );

        return IdAgoraMembership(dAgoraMembership).isValidMembership(_id);
    }
}

