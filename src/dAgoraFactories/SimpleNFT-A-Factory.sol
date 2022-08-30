// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SimpleNFTA} from "../dAgoraWizards/Simple-NFT-A.sol";
import "../IdAgoraMemberships.sol";

/// @title dAgora Simple NFT A Factory
/// @author DadlessNsad || 0xOrphan
/// @notice Used to create new Simple NFT A contracts for dAgora members.
contract dAgoraSimpleNFTAFactory is Ownable, ReentrancyGuard {
    SimpleNFTA nfta;

    struct Deploys {
        address[] ContractAddress;
        address Owner;
        uint256 nftAIndex;
    }

    /// @notice The address of the dAgora Memberships contract.
    address public dAgoraMembership;

    /// @notice The total count of NFTs created for members..
    uint256 public totalNftACount = 0;

    /// @notice Used to pause and unpause the contract.
    bool public paused;

    /// @notice Maps deployed contracts to their owners.
    mapping(address => Deploys) private _deployedContracts;

    /// @notice Tracks users deployed contracts amount.
    mapping(address => uint256) public _addressDeployCount;

    /// @notice Emitted when a new NFT A contract is deployed.
    /// @param _nftContract The address of the deployed contract.
    /// @param _owner The address of the owner.
    /// @param _UserDeployCount Users total amount of deployed contracts.
    /// @param _totalNftACount The total amount of NFTs created for members.
    event SimpleNFTACreated(
        address _nftContract,
        address _owner,
        uint256 _UserDeployCount,
        uint256 _totalNftACount
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
    /// @param _mintCost The cost of minting an NFT.
    /// @param _bulkBuyLimit the max amount of NFTs that can be minted at once.
    /// @param _maxTotalSupply The max supply of the NFT.
    /// @param _newOwner The address of the new owner of deployed contract.
    function createNFT(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _mintCost,
        uint256 _bulkBuyLimit,
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

        require(_newOwner != address(0), "New owner must be a valid address");

        nfta = new SimpleNFTA(
            _name,
            _symbol,
            _baseURI,
            _mintCost,
            _bulkBuyLimit,
            _maxTotalSupply,
            _newOwner
        );

        totalNftACount++;
        _addressDeployCount[msg.sender]++;
        _deployedContracts[msg.sender].ContractAddress.push(address(nfta));
        _deployedContracts[msg.sender].Owner = msg.sender;
        _deployedContracts[msg.sender].nftAIndex = totalNftACount;

        emit SimpleNFTACreated(
            address(nfta),
            msg.sender,
            _addressDeployCount[msg.sender],
            totalNftACount
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
    function togglePause() public onlyOwner {
        paused = !paused;
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
