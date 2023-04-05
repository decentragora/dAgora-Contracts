// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {IDagoraMembershipsV1} from "../../contracts/interfaces/IDagoraMembershipsV1.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Create2Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/Create2Upgradeable.sol";
import {PowerPlusNFT} from "../../contracts/wizards/PowerPlusNFT.sol";

error DagoraFactory__TokenCreationPaused();
error DagoraFactory__InvalidTier(uint8 tier, uint8 neededTier);
error DagoraFactory__NotDAgoraMembershipsOwnerOrDelegate();
error DagoraFactory__ExpiredMembership();

contract DagoraPowerPlusNFTFactory is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable{


    
    /// @notice Boolean to determine if the contract is paused.
    /// @dev default value is false, contract is not paused on deployment.
    bool public isPaused;

    /// @notice The address of the dAgoraMemberships contract.
    address public dAgoraMembershipsAddress;

    /// @notice The minimum tier required to create a Power NFT contract.
    uint8 public minPowerNFTATier;

    /// @notice the count of all the contracts deployed by the factory
    uint256 public contractsDeployed;


    /// @notice The event emitted when a PowerNFTA contract is created.
    event PowerPlusNFTACreated(address newContractAddress, address ownerOF);

    mapping(address => address[]) public userContracts;
    

    function initialize(address _dAgoraMembershipsAddress) public initializer {
        __Ownable_init();
        dAgoraMembershipsAddress = _dAgoraMembershipsAddress;
        minPowerNFTATier = 2;
        isPaused = true;
    }

    /// @notice Modifier to check if the contract is paused.
    /// @dev Reverts if the contract is paused.
    modifier isNotPaused() {
        if (isPaused) {
            revert DagoraFactory__TokenCreationPaused();
        }
        _;
    }

    /// @notice Modifier to check if the user can create a contract.
    /// @dev Reverts if the user membership tier is not high enough, if the membership is expired, and if the user is not owner of tokenId.
    /// @param tokenId The id of the users membership tokenId.
    /// @param neededTier The tier required to create the Contract.
    modifier canCreate(uint256 tokenId, uint8 neededTier) {
        require(_canCreate(tokenId, neededTier), "dAgoraERC20Factory: Cannot create token");
        _;
    }

    /// @notice Function to create a PowerNFTA contract.
    /// @dev Reverts if the new owner is 0 address, if the royalty recipient is 0 address, if the max total supply is 0, if the bulk buy limit is 0, if the max allow list amount is 0, if the bulk buy limit is greater than the max total supply, if the max allow list amount is greater than the max total supply, and if the merkle root is 0.
    /// @param params The struct containing the parameters for the PowerNFTA contract.
    /// @param _id The id of the users membership tokenId.
    function createPowerPlusNFT(
        PowerPlusNFT.Params memory params,
        uint256 _id
    )   public
        isNotPaused
        canCreate(_id, minPowerNFTATier)
        nonReentrant
    {
        require(params._newOwner != address(0), "New owner cannot be 0 address");
        require(params._newOwner != address(this), "New owner cannot be factory address");
        require(params._royaltyRecipient != address(0), "Royalty recipient cannot be 0 address");
        require(params._royaltyRecipient != address(this), "Royalty recipient cannot be factory address");        
        require(params._maxSupply > 0, "Max total supply cannot be 0");
        require(params._bulkBuyLimit > 0 && params._maxAllowListAmount > 0, "Bulk buy limit and max allow list amount cannot be 0");
        require(params._bulkBuyLimit < params._maxSupply, "Bulk buy limit cannot be greater than max total supply");
        require(params._maxAllowListAmount < params._maxSupply, "Max allow list amount cannot be greater than max total supply");
        require(params._merkleRoot != bytes32(0), "Merkle root cannot be 0");

        bytes32 salt = keccak256(abi.encodePacked(params.name_, msg.sender, block.timestamp));
        bytes memory bytecode = abi.encodePacked(
            type(PowerPlusNFT).creationCode,
            abi.encode(
                params
            )
        );
        address newImplementation = Create2Upgradeable.deploy(0, salt, bytecode);
        userContracts[msg.sender].push(newImplementation);
        contractsDeployed++;
        emit PowerPlusNFTACreated(newImplementation, params._newOwner);
    }
        

    function getUserContracts(address _user) external view returns(address[] memory) {
        return userContracts[_user];
    }

    function togglePaused() external onlyOwner {
        isPaused = !isPaused;
    }

    function setMinPowerNFTATier(uint8 _minPowerNFTATier) external onlyOwner {
        minPowerNFTATier = _minPowerNFTATier;
    }

    /// @notice Internal function that checks if a address owns or is a delegate of a membership, and if the membership is valid, and if the membership tier is high enough.
    /// @param _id The id of the users membership tokenId.
    /// @param _neededTier The minimum membership tier required to create a contract.
    /// @return bool True or False. 
    function _canCreate(uint256 _id, uint8 _neededTier) internal view returns (bool) {
        if (IDagoraMembershipsV1(dAgoraMembershipsAddress).isOwnerOrDelegate(_id, msg.sender) != true) {
           revert DagoraFactory__NotDAgoraMembershipsOwnerOrDelegate();
        }

        uint8 memberTier = IDagoraMembershipsV1(dAgoraMembershipsAddress).getMembershipTier(_id);
        if (memberTier < _neededTier) {
           revert DagoraFactory__InvalidTier(memberTier, _neededTier);
        }

        if (IDagoraMembershipsV1(dAgoraMembershipsAddress).isValidMembership(_id) != true) {
           revert DagoraFactory__ExpiredMembership();
        } else {
            return true;
        }
    }    
}