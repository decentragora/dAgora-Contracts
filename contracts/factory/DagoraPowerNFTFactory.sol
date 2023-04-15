// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {IDagoraMembershipsV1} from "../../contracts/interfaces/IDagoraMembershipsV1.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Create2Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/Create2Upgradeable.sol";
import {PowerNFT} from "../../contracts/wizards/PowerNFTA.sol";

error DagoraFactory__TokenCreationPaused();
error DagoraFactory__InvalidTier(uint8 tier, uint8 neededTier);
error DagoraFactory__NotDAgoraMembershipsOwnerOrDelegate();
error DagoraFactory__ExpiredMembership();

error DagoraFactory__FailedToCreateContract();

contract DagoraPowerNFTFactory is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    
    /// @notice Boolean to determine if the contract is paused.
    /// @dev default value is false, contract is not paused on deployment.
    bool public isPaused;

    /// @notice The address of the dAgoraMemberships contract.
    address public dAgoraMembershipsAddress;

    // will delete this later
    address public powerNFtAddress;

    /// @notice The minimum tier required to create a Power NFT contract.
    uint8 public minPowerNFTATier;

    /// @notice the count of all the contracts deployed by the factory
    uint256 public contractsDeployed;


    /// @notice The event emitted when a PowerNFTA contract is created.
    event PowerNFTACreated(address newContractAddress, address ownerOF);

    mapping(address => address[]) public userContracts;
    

    function initialize(address _dAgoraMembershipsAddress) public initializer {
        __Ownable_init();
        dAgoraMembershipsAddress = _dAgoraMembershipsAddress;
        minPowerNFTATier = 1;
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
    /// @dev Creates a PowerNFTA contract, and emits an event.
    /// @param name_ The name of the contract.
    /// @param symbol_ The symbol of the contract.
    /// @param baseURI_ The baseURI of the contract.
    /// @param _bulkBuyLimit The bulk buy limit of the contract.
    /// @param _royaltyBps The royalty bps of the contract.
    /// @param _mintCost The mint cost of the contract.
    /// @param _maxSupply The max total supply of the contract.
    /// @param _royaltyRecipient The royalty recipient of the contract.
    /// @param _newOwner The new owner of the contract.
    /// @param _id The id of the users membership tokenId.
    function createPowerNFT(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        uint16 _bulkBuyLimit,
        uint96 _royaltyBps,
        uint256 _mintCost,
        uint256 _maxSupply,
        address _royaltyRecipient,
        address _newOwner,
        uint256 _id
    )   public isNotPaused canCreate(_id, minPowerNFTATier) nonReentrant {
        require(_newOwner != address(0), "New owner cannot be 0 address");
        require(_newOwner != address(this), "New owner cannot be factory address");
        require(_royaltyRecipient != address(0), "Royalty recipient cannot be 0 address");
        require(_maxSupply > 0, "Max total supply cannot be 0");
        require(_bulkBuyLimit > 0 , "Bulk buy limit t cannot be 0");
        require(_bulkBuyLimit < _maxSupply, "Bulk buy limit cannot be greater than max total supply");

        bytes32 salt = keccak256(abi.encodePacked(name_, msg.sender, block.timestamp));
        bytes memory bytecode = abi.encodePacked(
            type(PowerNFT).creationCode,
            abi.encode(
                name_,
                symbol_,
                baseURI_,
                _bulkBuyLimit,
                _royaltyBps,
                _mintCost,
                _maxSupply,
                _royaltyRecipient,
                _newOwner
            )
        );
        address newImplementation = Create2Upgradeable.deploy(0, salt, bytecode);
        if (newImplementation == address(0)) {
            revert DagoraFactory__FailedToCreateContract();
        }
        userContracts[msg.sender].push(newImplementation);
        contractsDeployed++;
        emit PowerNFTACreated(newImplementation, _newOwner);
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