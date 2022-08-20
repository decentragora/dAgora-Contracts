// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { BasicNFTOZ } from "../dAgoraWizards/BasicNFTOZ.sol";
import '../IdAgoraMemberships.sol';

contract dAgoraBasicNFTOZFactory is Ownable, ReentrancyGuard {
    BasicNFTOZ nft;

    struct Deploys {
        address[] ContractAddress;
        address Owner;
        uint256 contractId;
    }

    address public dAgoraMembership;
    uint256 public basicNFTCount = 0;
    bool public paused;

    mapping(address => Deploys) private _deployedContracts;
    mapping(address => uint256) public _addressDeployCount;

    event BasicNFTCreated(
        address basicNFTContract, 
        address owner,
        uint256 _contractId,
        uint256 _basicNFTCount
    );

    constructor(address _dAgoraMembership) {
        dAgoraMembership = _dAgoraMembership;
    }

    modifier isPaused() {
        require(!paused, "Factory is paused");
        _;
    }

    function createBasicNFT(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _mintCost,
        uint16 _bulkBuyLimit,
        uint256 _maxTotalSupply,
        address _newOwner
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

        emit BasicNFTCreated(address(nft), msg.sender, _addressDeployCount[msg.sender], basicNFTCount);
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
                    return IdAgoraMembership(dAgoraMembership).isValidMembership(i);
                }
            }
        } else {
            return false;
        }
    }
}