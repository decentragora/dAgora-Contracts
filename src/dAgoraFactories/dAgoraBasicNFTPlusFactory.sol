// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { BasicNFTPlus } from "../dAgoraWizards/BasicNFTPlus.sol";
import '../IdAgoraMemberships.sol';

contract dAgoraBasicNFTPlusFactory is Ownable, ReentrancyGuard {
    BasicNFTPlus nft;

    struct Deploys {
        address[] ContractAddress;
        address Owner;
        uint256 contractId;
    }

    address public dAgoraMembership;
    uint256 public basicNFTPlusCount = 0;
    bool public paused;

    mapping(address => Deploys) private _deployedContracts;
    mapping(address => uint256) public _addressDeployCount;

    event BasicNFTPlusCreated(
        address _basicNFTPlusContract, 
        address _owner, 
        uint256 _contractId,
        uint256 _basicNFTPlusCount
    );

    constructor(address _dAgoraMembership) {
        dAgoraMembership = _dAgoraMembership;
    }

    modifier isPaused() {
        require(!paused, "Factory is paused");
        _;
    }

    function createBasicNFTPlus(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _mintCost,
        uint16 _bulkBuyLimit,
        uint16 _maxWhiteListAmount,
        uint256 _maxTotalSupply,
        address _newOwner,
        bytes32 _merkleRoot
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

        nft = new BasicNFTPlus(
            _name,
            _symbol,
            _baseURI,
            _mintCost,
            _bulkBuyLimit,
            _maxWhiteListAmount,
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

    function deployedContracts(address _owner) public view returns (Deploys memory) {
        return _deployedContracts[_owner];
    }

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

    function _canCreate() internal view returns(bool){
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