// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { PowerNFT } from "../dAgoraWizards/PowerNFT.sol";
import '../IdAgoraMemberships.sol';

contract dAgoraPowerNFTFactory is Ownable, ReentrancyGuard {
    PowerNFT nft;

    struct Deploys {
        address[] ContractAddress;
        address Owner;
        uint256 contractId;
    }

    address public dAgoraMembership;
    uint256 public powerNFTCount = 0;
    bool public paused;

    mapping(address => Deploys) private _deployedContracts;
    mapping(address => uint256) public _addressDeployCount;

    event PowerNFTCreated(
        address _powerNFTContract, 
        address _owner, 
        uint256 _contractId,
        uint256 _powerNFTCount
    );

    constructor(address _dAgoraMembership) {
        dAgoraMembership = _dAgoraMembership;
    }

    modifier isPaused() {
        require(!paused, "Factory is paused");
        _;
    }

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

    function deployedContracts(address _owner) public view returns (Deploys memory) {
        return _deployedContracts[_owner];
    }

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

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