// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {BasicNFTPlus} from "../dAgoraWizards/BasicNFTPlus.sol";
import "../IdAgoraMemberships.sol";

/// @title dAgora Basic NFT Plus Factory
/// @author DadlessNsad || 0xOrphan
/// @notice Used to create new Basic NFT Plus contracts for dAgora members.
contract dAgoraBasicNFTPlusFactory is Ownable, ReentrancyGuard {
    BasicNFTPlus nft;

    struct Deploys {
        address[] ContractAddress;
        address Owner;
        uint256 contractId;
    }

    /// @notice The address of the dAgora Memberships contract.
    address public dAgoraMembership;

    /// @notice The total count of NFTs created for members..
    uint256 public basicNFTPlusCount = 0;

    /// @notice Used to pause and unpause the contract.
    bool public paused;

    /// @notice Maps deployed contracts to their owners.
    mapping(address => Deploys) private _deployedContracts;

    /// @notice Tracks users deployed contracts amount.
    mapping(address => uint256) public _addressDeployCount;

    /// @notice Emitted when a new NFT contract is deployed.
    /// @param _basicNFTPlusContract The address of the deployed contract.
    /// @param _owner The address of the owner.
    /// @param _contractId Users total amount of deployed contracts.
    /// @param _basicNFTPlusCount The total amount of NFTs created for members.
    event BasicNFTPlusCreated(
        address _basicNFTPlusContract,
        address _owner,
        uint256 _contractId,
        uint256 _basicNFTPlusCount
    );

    /// @notice Sets the contracts variables.
    /// @param _dAgoraMembership The address of the dAgora Memberships contract.
    constructor(address _dAgoraMembership) {
        dAgoraMembership = _dAgoraMembership;
    }

    /// @notice Checks if the contract is paused.
    /// @dev This modifier is used to prevent users from deploying contracts while the contract is paused.
    modifier isPaused() {
        require(!paused, "Factory is paused");
        _;
    }

    /// @notice Deploys a new NFT contract for the user.
    /// @param _name The name of the NFT.
    /// @param _symbol The symbol of the NFT.
    /// @param _baseURI The base URI of the NFT.
    /// @param _mintCost The Mint cost of a NFT.
    /// @param _bulkBuyLimit the max amount of NFTs that can be minted at once.
    /// @param _maxAllowListAmount The max amount of NFTs that can be minted by the allow list.
    /// @param _maxTotalSupply The max supply of the NFT.
    /// @param _id The tokenId of dAgora Membership.
    /// @param _newOwner The address of the new owner.
    /// @param _merkleRoot The merkle root of the allowed list addresses.
    function createBasicNFTPlus(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _mintCost,
        uint16 _bulkBuyLimit,
        uint16 _maxAllowListAmount,
        uint256 _maxTotalSupply,
        uint256 _id,
        address _newOwner,
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

        nft = new BasicNFTPlus(
            _name,
            _symbol,
            _baseURI,
            _mintCost,
            _bulkBuyLimit,
            _maxAllowListAmount,
            _maxTotalSupply,
            _newOwner,
            _merkleRoot
        );

        basicNFTPlusCount++;
        _addressDeployCount[msg.sender]++;
        _deployedContracts[msg.sender].ContractAddress.push(address(nft));
        _deployedContracts[msg.sender].Owner = msg.sender;
        _deployedContracts[msg.sender].contractId = basicNFTPlusCount;

        emit BasicNFTPlusCreated(
            address(nft),
            msg.sender,
            _addressDeployCount[msg.sender],
            basicNFTPlusCount
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

    function _canCreate(uint256 _id) internal view returns (bool) {
        require(
            IdAgoraMembership(dAgoraMembership).checkTokenTier(_id) > 0,
            "Must be dAgoraian tier or higher"
        );

        require(
            IdAgoraMembership(dAgoraMembership).isOwnerOrDelegate(_id, msg.sender) == true,
            "Must be owner or delegate"
        );

        return IdAgoraMembership(dAgoraMembership).isValidMembership(_id);
    }
}