// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {IDagoraMembershipsV1} from "../../contracts/interfaces/IDagoraMembershipsV1.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Create2Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/Create2Upgradeable.sol";
import {DagoraERC20} from "../../contracts/wizards/dAgoraERC20.sol";

error DagoraFactory__TokenCreationPaused();
error DagoraFactory__InvalidTier(uint8 tier, uint8 neededTier);
error DagoraFactory__NotDAgoraMembershipsOwnerOrDelegate();
error DagoraFactory__ExpiredMembership();

contract DagoraERC20Factory is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    
    /// @notice Boolean to determine if the contract is paused.
    /// @dev default value is false, contract is not paused on deployment.
    bool public isPaused;

    /// @notice The address of the dAgoraMemberships contract.
    address public dAgoraMembershipsAddress;

    /// @notice The minimum tier required to create a NFTAPlus contract.
    uint8 public minERC20Tier;

    /// @notice the count of all the contracts deployed by the factory
    uint256 public contractsDeployed;

    /// @notice The event emitted when a NFTAPlus contract is created.
    event DagoraERC20Created(address newContractAddress, address ownerOF);

    mapping(address => address[]) public userContracts;
    

    function initialize(address _dAgoraMembershipsAddress) public initializer {
        __Ownable_init();
        dAgoraMembershipsAddress = _dAgoraMembershipsAddress;
        minERC20Tier = 0;
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

    /// @notice Function to create a new DagoraERC20 contract.
    /// @dev Creates a new DagoraERC20 contract, and emits a DagoraERC20Created event.
    /// @param name_ The name of the new DagoraERC20 contract.
    /// @param symbol_ The symbol of the new DagoraERC20 contract.
    /// @param _newOwner The address of the new owner of the new DagoraERC20 contract.
    /// @param _initialSupply The initial supply of the new DagoraERC20 contract.
    /// @param _maxSupply The max supply of the new DagoraERC20 contract.
    /// @param _id The id of the users membership tokenId.
    function createDagoraERC20(
        string memory name_,
        string memory symbol_,
        address _newOwner,
        uint256 _initialSupply,
        uint256 _maxSupply,
        uint256 _id
    )   public isNotPaused canCreate(_id, minERC20Tier) nonReentrant {
        require(_newOwner != address(0), "dAgoraERC20Factory: New owner cannot be the zero address");
        require(_newOwner != address(this), "dAgoraERC20Factory: New owner cannot be the factory address");
        require(_initialSupply <= _maxSupply, "dAgoraERC20Factory: Initial supply cannot be higher than max supply");
        require(_maxSupply > 0, "dAgoraERC20Factory: Max supply cannot be zero");

        bytes32 salt = keccak256(abi.encodePacked(name_, msg.sender, block.timestamp));
        bytes memory bytecode = abi.encodePacked(
            type(DagoraERC20).creationCode,
            abi.encode(
                name_,
                symbol_,
                _newOwner,
                _initialSupply,
                _maxSupply
            )
        );
        address newImplementation = Create2Upgradeable.deploy(0, salt, bytecode);
        userContracts[msg.sender].push(newImplementation);
        contractsDeployed++;
        emit DagoraERC20Created(newImplementation, _newOwner);
    }

    function getUserContracts(address _user) external view returns(address[] memory) {
        return userContracts[_user];
    }

    function togglePaused() external onlyOwner {
        isPaused = !isPaused;
    }

    function setMinERC20Tier(uint8 _minTier) external onlyOwner {
        minERC20Tier = _minTier;
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