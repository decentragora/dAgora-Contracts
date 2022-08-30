/// @title Simple ERC721A Minting Contract
/// @author Made By DecentrAgora
/// @notice use this contract to enhance you understand of the ERC721 Standard
/// @dev 0xOrphan || DadlessNsad

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "ERC721A/ERC721A.sol";

/// @title Simple NFT A
/// @author 0xOrphan || DadlessNsad
/// @notice This is a template contract used to create new NFT contracts.
/// @dev This contract is a simple ERC721A contract that can be used to mint NFTs. and is apart of DecentrAgoras tools.

contract SimpleNFTA is ERC721A, Ownable {
    /// @notice Where the NFTs metadata is stored.
    string public baseURI;

    /// @notice The file extension for the NFTs baseURI.
    string public baseExtension = ".json";

    /// @notice Used to pause and unpause the contract.
    bool public paused = true;

    /// @notice The price to mint a new NFT.
    uint256 public mintCost;

    /// @notice The maximum amount of NFTs that can be minted in one transaction.
    uint256 public bulkBuyLimit;

    /// @notice The maximum amount of NFTs that can be minted.
    uint256 public maxTotalSupply;

    /// @notice Event emitted when a membership is purchased.
    /// @param _name The name of the NFT.
    /// @param _symbol The symbol of the NFT.
    /// @param _baseURI The baseURI of the NFT.
    /// @param _mintCost The cost to mint a new NFT.
    /// @param _bulkBuyLimit The maximum amount of NFTs that can be minted in one transaction.
    /// @param _maxTotalSupply The maximum amount of NFTs that can be minted.
    /// @param _newOwner The address of the owner/ msg.sender.
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _mintCost,
        uint256 _bulkBuyLimit,
        uint256 _maxTotalSupply,
        address _newOwner
    )
        ERC721A(_name, _symbol)
    {
        baseURI = _baseURI;
        mintCost = _mintCost;
        bulkBuyLimit = _bulkBuyLimit;
        maxTotalSupply = _maxTotalSupply;
        transferOwnership(_newOwner);
    }

    /// @notice Checks if the contract is paused.
    /// @dev Used to prevent users from minting NFTs when the contract is paused.
    modifier isPaused() {
        require(!paused, "Contract is Paused");
        _;
    }

    /// @notice Main function used to mint NFTs.
    /// @param _amount The amount of NFTs to mint.
    /// @dev The amount of NFTs to mint must be less than or equal to the bulkBuyLimit.
    /// @dev The total supply of NFTs must be less than or equal to the maxTotalSupply.
    /// @dev The Contracts paused state must be false.
    function mintNFT(uint256 _amount) public payable isPaused {
        require(_amount <= bulkBuyLimit, "Max per tx");
        require((_amount + totalSupply()) <= maxTotalSupply, "Soldout");
        require((_amount * mintCost) <= msg.value, "Insufficent Eth sent");

        _safeMint(msg.sender, _amount);
    }

    /// @notice Only Contract Owner can use this function to Mint NFTs.
    /// @param _amount The amount of NFTs to mint.
    /// @dev The total supply of NFTs must be less than or equal to the maxTotalSupply.
    function reserveTokens(uint256 _amount) public onlyOwner {
        require(_amount + totalSupply() <= maxTotalSupply, "Soldout");
        _safeMint(msg.sender, _amount);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(_tokenId), "Token does not exist.");
        return string(abi.encodePacked(baseURI, _toString(_tokenId), baseExtension));
    }

    /// @notice Only Contract Owner can use this function to set the baseURI.
    /// @param _newBaseURI The new baseURI.
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    /// @notice Only Contract Owner can use this function to set the baseExtension.
    /// @param _newBaseExtension The new baseExtension.
    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    /// @notice Only Contract Owner can use this function to set the mintCost.
    /// @param _newMintCost The new mintCost.
    function setMintCost(uint256 _newMintCost) public onlyOwner {
        mintCost = _newMintCost;
    }

    /// @notice Only Contract Owner can use this function to pause the contract.
    /// @param _newBulkBuyLimit The new bulkBuyLimit.
    /// @dev The bulkBuyLimit must be less than the maxTotalSupply.
    function setBulkBuyLimit(uint256 _newBulkBuyLimit) public onlyOwner {
        bulkBuyLimit = _newBulkBuyLimit;
    }

    /// @notice Only Contract Owner can use this function to pause the contract.
    /// @dev Used to prevent users from minting NFTs.
    function togglePaused() public onlyOwner {
        paused = !paused;
    }

    /// @notice Withdraws the funds from the contract to contract owner.
    /// @dev Only Contract Owner can use this function.
    function withdraw() public onlyOwner {
        (bool success,) =
            payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Address: unable to send value");
    }

    /// @notice Allows owner to withdraw any ERC20 tokens sent to this contract.
    /// @param _tokenAddr The address of the ERC20 token.
    /// @dev Only Contract Owner can use this function.
    function withdrawErc20s(address _tokenAddr) public onlyOwner {
        (bool success,) =
            payable(msg.sender).call{value: address(_tokenAddr).balance}("");
        require(success, "Address: unable to send value");
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }
}
