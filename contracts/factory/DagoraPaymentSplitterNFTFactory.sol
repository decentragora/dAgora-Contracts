// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {IDagoraMembershipsV1} from "../../contracts/interfaces/IDagoraMembershipsV1.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Create2Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/Create2Upgradeable.sol";
import {DagoraPaymentSplitterNFT} from "../wizards/dAgoraPaymentSplitterNFT.sol";


error DagoraFactory__TokenCreationPaused();
error DagoraFactory__InvalidTier(uint8 tier, uint8 neededTier);
error DagoraFactory__NotDAgoraMembershipsOwnerOrDelegate();
error DagoraFactory__ExpiredMembership();

error DagoraFactory__FailedToCreateContract();

contract DagoraPaymentSplitterFactory is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    
    struct NFTParams {
            string name;
            string symbol;
            address[] payees;
            uint256[] shares;
            uint256 mintPrice;
            uint256 maxSupply;
            uint16 bulkBuyLimit;
            string baseURI;
            string baseExtension;
            address newOwner;
    }

    /// @notice Boolean to determine if the contract is paused.
    /// @dev default value is false, contract is not paused on deployment.
    bool public isPaused;

    /// @notice The address of the dAgoraMemberships contract.
    address public dAgoraMembershipsAddress;

    /// @notice The minimum tier required to create a NFTAPlus contract.
    uint8 public minTier;

    /// @notice the count of all the contracts deployed by the factory
    uint256 public contractsDeployed;

    event PaymentSplitterCreated(address newContractAddress, address ownerOf);

    mapping(address => address[]) public userContracts;

    function initialize(address _dAgoraMembershipsAddress) public initializer {
        __Ownable_init();
        dAgoraMembershipsAddress = _dAgoraMembershipsAddress;
        minTier = 1;
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


    function createNFT(
        NFTParams memory params,
        uint256 id
    ) public isNotPaused canCreate(id, minTier) nonReentrant returns (address newImplementation) {
        require(params.newOwner != address(0), "New owner cannot be 0 address");
        require(params.newOwner != address(this), "New owner cannot be factory address");
        require(params.maxSupply > 0, "Max total supply cannot be 0");
        require(params.bulkBuyLimit > 0,  "Bulk buy limit amount cannot be 0");
        require(params.bulkBuyLimit < params.maxSupply, "Bulk buy limit cannot be greater than max total supply");
        require(params.payees.length == params.shares.length, "Payees and shares arrays must be the same length");
        require(paymentSharesTotal(params.shares) == 100, "Shares must add up to 100");
        require(params.payees.length > 0, "Payees array must be greater than 0");
        require(params.shares.length > 0, "Shares array must be greater than 0");

        bytes32 salt = keccak256(abi.encodePacked(params.name, msg.sender, block.timestamp));

        newImplementation = createNFTImpl(params, salt);
        if (newImplementation == address(0)) {
            revert DagoraFactory__FailedToCreateContract(); 
        }

        userContracts[msg.sender].push(newImplementation);
        contractsDeployed++;
        emit PaymentSplitterCreated(newImplementation, msg.sender);
    }

    /// @notice Function that returns the deployed contracts by a user.
    function getUserContracts(address _user) external view returns(address[] memory) {
        return userContracts[_user];
    }

    /// @notice onlyOwner function to set the paused state of the contract.
    function togglePaused() external onlyOwner {
        isPaused = !isPaused;
    }
        
    /// @notice onlyOwner function to set the minimum tier required to create a contract.
    function setMinTier(uint8 _minTier) external onlyOwner {
        minTier = _minTier;
    }

    function paymentSharesTotal(uint256[] memory shares_) internal pure returns (uint256) {
        uint256 totalShares;
        for (uint256 i = 0; i < shares_.length; i++) {
            totalShares += shares_[i];
        }
        return totalShares;
    }

    function createNFTImpl(NFTParams memory params, bytes32 salt) internal returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(DagoraPaymentSplitterNFT).creationCode,
            abi.encode(
                params.name,
                params.symbol,
                params.payees,
                params.shares,
                params.mintPrice,
                params.maxSupply,
                params.bulkBuyLimit,
                params.baseURI,
                params.baseExtension,
                params.newOwner
            )
        );
        address newImplementation = Create2Upgradeable.deploy(0, salt, bytecode);
        return newImplementation;
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