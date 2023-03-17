// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {IDagoraMembershipsV1} from "../../contracts/interfaces/IDagoraMembershipsV1.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Create2Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/Create2Upgradeable.sol";
import {NFTAPlus} from "../../contracts/wizards/NFTAPlus.sol";

error DagoraFactory__TokenCreationPaused();
error DagoraFactory__InvalidTier(uint8 tier, uint8 neededTier);
error DagoraFactory__NotDAgoraMembershipsOwnerOrDelegate();
error DagoraFactory__ExpiredMembership();

contract DagoraNFTAPlusFactory is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    
    /// @notice Boolean to determine if the contract is paused.
    /// @dev default value is false, contract is not paused on deployment.
    bool public isPaused;

    /// @notice The address of the dAgoraMemberships contract.
    address public dAgoraMembershipsAddress;

    /// @notice The minimum tier required to create a NFTAPlus contract.
    uint8 public minNFTAPlusTier;

    /// @notice the count of all the contracts deployed by the factory
    uint256 public contractsDeployed;

    /// @notice The event emitted when a NFTAPlus contract is created.
    event NFTAPlusCreated(address newContractAddress, address ownerOF);

    mapping(address => address[]) public userContracts;
    

    function initialize(address _dAgoraMembershipsAddress) public initializer {
        __Ownable_init();
        dAgoraMembershipsAddress = _dAgoraMembershipsAddress;
        minNFTAPlusTier = 1;
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

    /// @notice Function to create a NFTAPlus contract.
    /// @dev Creates a NFTAPlus contract using the Create2Upgradeable library.
    /// @param name_ The name of the NFTAPlus contract.
    /// @param symbol_ The symbol of the NFTAPlus contract.
    /// @param baseURI_ The baseURI of the NFTAPlus contract.
    /// @param _bulkBuyLimit The bulk buy limit of the NFTAPlus contract.
    /// @param _maxAllowListAmount The max allow list amount of the NFTAPlus contract.
    /// @param _mintCost The mint cost of the NFTAPlus contract.
    /// @param _presaleMintCost The presale mint cost of the NFTAPlus contract.
    /// @param _maxTotalSupply The max total supply of the NFTAPlus contract.
    /// @param _newOwner The new owner of the NFTAPlus contract.
    /// @param _merkleRoot The merkle root of the NFTAPlus contract.
    /// @param _id The id of the users membership tokenId.
    function createNFTAPlus(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        uint16 _bulkBuyLimit,
        uint16 _maxAllowListAmount,
        uint256 _mintCost,
        uint256 _presaleMintCost,
        uint256 _maxTotalSupply,
        address _newOwner,
        bytes32 _merkleRoot,
        uint256 _id
    )   public isNotPaused canCreate(_id, minNFTAPlusTier) nonReentrant {
        require(_newOwner != address(0), "New owner cannot be 0 address");
        require(_newOwner != address(this), "New owner cannot be factory address");
        require(_maxTotalSupply > 0, "Max total supply cannot be 0");
        require(_bulkBuyLimit > 0 && _maxAllowListAmount > 0, "Bulk buy limit and max allow list amount cannot be 0");
        require(_bulkBuyLimit < _maxTotalSupply, "Bulk buy limit cannot be greater than max total supply");
        require(_maxAllowListAmount < _maxTotalSupply, "Max allow list amount cannot be greater than max total supply");
        require(_merkleRoot != bytes32(0), "Merkle root cannot be 0");

        bytes32 salt = keccak256(abi.encodePacked(name_, msg.sender, block.timestamp));
        bytes memory bytecode = abi.encodePacked(
            type(NFTAPlus).creationCode,
            abi.encode(
                name_,
                symbol_,
                baseURI_,
                _bulkBuyLimit,
                _maxAllowListAmount,
                _mintCost,
                _presaleMintCost,
                _maxTotalSupply,
                _newOwner,
                _merkleRoot
            )
        );
        address newImplementation = Create2Upgradeable.deploy(0, salt, bytecode);
        userContracts[msg.sender].push(newImplementation);
        contractsDeployed++;
        emit NFTAPlusCreated(newImplementation, _newOwner);
    }

    function getUserContracts(address _user) external view returns(address[] memory) {
        return userContracts[_user];
    }

    function togglePaused() external onlyOwner {
        isPaused = !isPaused;
    }

    function setMinNFTAPlusTier(uint8 _minNFTAPlusTier) external onlyOwner {
        minNFTAPlusTier = _minNFTAPlusTier;
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