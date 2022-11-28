// SPDX-License-Identifier: MIT
/// @title dAgora Basic NFT OZ Factory
/// @author DadlessNsad || 0xOrphan
/// @notice Used to create new Basic NFT OZ contracts for dAgora members.
pragma solidity ^0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {BasicNFTOZ} from "../dAgoraWizards/BasicNFTOZ.sol";
import {IdAgoraMembership} from "../IdAgoraMemberships.sol";


contract dAgoraBasicNFTOZFactory is Ownable, ReentrancyGuard {
    BasicNFTOZ nft;

    struct Deploys {
        address[] ContractAddress;
        address Owner;
        uint256 contractId;
    }

    /// @notice The address of the dAgora Memberships contract.
    address public dAgoraMembership;

    /// @notice The total count of NFTs created for members..
    uint256 public basicNFTCount = 0;

    /// @notice Used to pause and unpause the contract.
    bool public paused;

    /// @notice Maps deployed contracts to their owners.
    mapping(address => Deploys) private _deployedContracts;

    /// @notice Tracks users deployed contracts amount.
    mapping(address => uint256) public _addressDeployCount;

    /// @notice Emitted when a new NFT contract is deployed.
    /// @param basicNFTContract The address of the deployed contract.
    /// @param owner The address of the owner.
    /// @param _contractId Users total amount of deployed contracts.
    /// @param _basicNFTCount The total amount of NFTs created for members.
    event BasicNFTCreated(
        address basicNFTContract,
        address owner,
        uint256 _contractId,
        uint256 _basicNFTCount
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

    /// @notice Deploys a new Basic NFT contract for the user.
    /// @param _name The name of the NFT.
    /// @param _symbol The symbol of the NFT.
    /// @param _baseURI The base URI of the NFT.
    /// @param _mintCost The Mint cost of a NFT.
    /// @param _bulkBuyLimit the max amount of NFTs that can be minted at once.
    /// @param _maxTotalSupply The max supply of the NFT.
    /// @param _id The tokenId of dAgora Membership.
    /// @param _newOwner The address of the new owner.
    function createBasicNFT(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _mintCost,
        uint16 _bulkBuyLimit,
        uint256 _maxTotalSupply,
        uint256 _id,
        address _newOwner
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

        nft = new BasicNFTOZ(
            _name,
            _symbol,
            _baseURI,
            _mintCost,
            _bulkBuyLimit,
            _maxTotalSupply,
            _newOwner
        );

        basicNFTCount++;
        _addressDeployCount[msg.sender]++;
        _deployedContracts[msg.sender].ContractAddress.push(address(nft));
        _deployedContracts[msg.sender].Owner = msg.sender;
        _deployedContracts[msg.sender].contractId = basicNFTCount;

        emit BasicNFTCreated(
            address(nft),
            msg.sender,
            _addressDeployCount[msg.sender],
            basicNFTCount
            );
    }

    function deployedContracts(address _owner)
        public
        view
        returns (Deploys memory)
    {
        return _deployedContracts[_owner];
    }

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }


    /// @notice Function to check if a user is a valid member & can create NFT contracts.
    /// @param _id The tokenId of the NFT.
    /// @return boolean
    function _canCreate(uint256 _id) internal view returns (bool) {
        require(
            IdAgoraMembership(dAgoraMembership).isOwnerOrDelegate(_id, msg.sender) == true,
            "Must be the owner of the NFT"
        );
        
        return IdAgoraMembership(dAgoraMembership).isValidMembership(_id);
    }
}
