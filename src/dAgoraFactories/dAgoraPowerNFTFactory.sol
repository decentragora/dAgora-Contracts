// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { PowerNFT } from "../dAgoraWizards/PowerNFT.sol";
import '../IdAgoraMemberships.sol';

/// @title PowerNFT Factory
/// @author DadlessNsad || 0xOrphan
/// @notice Allows dAgora members to create new PowerNFT contracts.

contract dAgoraPowerNFTFactory is Ownable, ReentrancyGuard {
    PowerNFT nft;

    struct Deploys {
        address[] ContractAddress;
        address Owner;
        uint256 contractId;
    }

    /// @notice The address of the dAgora Memberships contract.
    address public dAgoraMembership;
    
    /// @notice The total count of NFTs created for members..
    uint256 public powerNFTCount = 0;

    /// @notice Used to pause and unpause the contract.
    bool public paused;


    /// @notice Maps deployed contracts to their owners.
    mapping(address => Deploys) private _deployedContracts;

    /// @notice Tracks users deployed contracts amount.
    mapping(address => uint256) public _addressDeployCount;


    /// @notice Emitted when a new NFT contract is deployed.
    /// @param _powerNFTContract The address of the deployed contract.
    /// @param _owner The address of the owner.
    /// @param _contractId Users total amount of deployed contracts.
    /// @param _powerNFTCount The total amount of NFTs created for members.
    event PowerNFTCreated(
        address _powerNFTContract, 
        address _owner, 
        uint256 _contractId,
        uint256 _powerNFTCount
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

    /// @notice Function to create contracts for members.
    /// @param _name The name of the NFT.
    /// @param _symbol The symbol of the NFT.
    /// @param _baseURI The base URI of the NFT.
    /// @param _mintCost The cost to mint a NFT.
    /// @param _bulkBuyLimit the max amount of NFTs that can be minted at once.
    /// @param _maxTotalSupply The max amount of NFTs that can be minted.
    /// @param _royaltyCut The % of royalties to be paid to the creator.
    /// @param _newOwner The address to receive royalties.
    /// @param _royaltyReceiver The address to receive royalties.
    function createPowerNFT(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _mintCost,
        uint16 _bulkBuyLimit,
        uint256 _maxTotalSupply,
        uint96 _royaltyCut,
        address _newOwner,
        address _royaltyReceiver
    )   public
        isPaused
        nonReentrant
    {
        require(_canCreate() == true, "Must be a valid membership");

        require(
            _maxTotalSupply > 0, 
            "Max supply must be greater than 0"
        );

        require(
            _maxTotalSupply > _bulkBuyLimit, 
            "Max supply must be greater than bulk buy limit"
        );

        require(_newOwner != address(0), "Owner cannot be 0x0");

        nft = new PowerNFT(
            _name,
            _symbol,
            _baseURI,
            _mintCost,
            _bulkBuyLimit,
            _maxTotalSupply,
            _royaltyCut,
            _newOwner,
            _royaltyReceiver
        );

        powerNFTCount++;
        _addressDeployCount[msg.sender]++;
        _deployedContracts[msg.sender].ContractAddress.push(address(nft));
        _deployedContracts[msg.sender].Owner = msg.sender;
        _deployedContracts[msg.sender].contractId = powerNFTCount;
        
        emit PowerNFTCreated(
            address(nft),
            msg.sender,
            _addressDeployCount[msg.sender],
            powerNFTCount
        );
    }

    /// @notice Function to check users deployed contract addresses.
    /// @param _owner The address of the user we want to check.
    function deployedContracts(address _owner) public view returns (Deploys memory) {
        return _deployedContracts[_owner];
    }


    /// @notice Function allows owner to pause/unPause the contract.
    function togglePaused () public onlyOwner {
        paused = !paused;
    }

    /// @notice Function to check if a user is a valid member & can create NFT contracts.
    /// @return boolean
    function _canCreate() internal view returns (bool) {
        uint256 _currentSupply =  IdAgoraMembership(dAgoraMembership).totalSupply();
        if(IdAgoraMembership(dAgoraMembership).balanceOf(msg.sender) > 0) {
            for(uint256 i = 1; i <= _currentSupply; i++) {
                if(IdAgoraMembership(dAgoraMembership).ownerOf(i) == msg.sender) {
                    require(
                        IdAgoraMembership(dAgoraMembership).checkTokenTier(i) > 0,
                        "Must be tier 1 or higher"
                    );
                    return IdAgoraMembership(dAgoraMembership).isValidMembership(i);
                }
            }
        } else {
            return false;
        }
    }
}