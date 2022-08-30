// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title dAgora Basic NFT OZ
/// @author DadlessNsad || 0xOrphan
/// @notice Used as a template for creating new NFT contracts.
contract BasicNFTOZ is ERC721, ERC721Enumerable, Ownable {
    using Strings for string;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    /// @notice Where the NFTs metadata is stored.
    string public baseURI;

    /// @notice The file extension for the NFTs baseURI.
    string public baseExtension = ".json";

    /// @notice Used to pause and unpause the contract.
    bool public paused = true;

    /// @notice The price to mint a new NFT.
    uint256 public mintCost;

    /// @notice The maximum amount of NFTs that can be minted in one transaction.
    uint16 public bulkBuyLimit;

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
        uint16 _bulkBuyLimit,
        uint256 _maxTotalSupply,
        address _newOwner
    )
        ERC721(_name, _symbol)
    {
        setBaseURI(_baseURI);
        setMintCost(_mintCost);
        bulkBuyLimit = _bulkBuyLimit;
        maxTotalSupply = _maxTotalSupply;
        transferOwnership(_newOwner);
    }

    /// @notice Checks if the contract is paused.
    /// @dev Used to prevent users from minting NFTs when the contract is paused.
    modifier isPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    /// @notice Main function used to mint NFTs.
    /// @param _amount The amount of NFTs to mint.
    /// @dev The amount of NFTs to mint must be less than or equal to the bulkBuyLimit.
    /// @dev The total supply of NFTs must be less than or equal to the maxTotalSupply.
    /// @dev The Contracts paused state must be false.
    function mintNFT(uint256 _amount) public payable isPaused {
        require(_amount <= bulkBuyLimit, "Over Max per Tx");
        require((totalSupply() + _amount) <= maxTotalSupply, "Soldout");
        require((_amount * mintCost) <= msg.value, "Insufficient funds");

        for (uint256 i = 1; i <= _amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
        }
    }

    /// @notice Only Contract Owner can use this function to Mint NFTs.
    /// @param _amount The amount of NFTs to mint.
    /// @dev The total supply of NFTs must be less than or equal to the maxTotalSupply.
    function reserveTokens(uint256 _amount) public onlyOwner {
        require(_amount + totalSupply() <= maxTotalSupply, "Soldout");

        for (uint256 i = 1; i <= _amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
        }
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId), "ERC721Metadata: URI query for nonexistent token"
        );
        string memory tokenId = Strings.toString(_tokenId);
        string memory currentBaseURI = baseURI;

        return
            bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId, baseExtension))
            : "";
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
    function setBulkBuyLimit(uint16 _newBulkBuyLimit) public onlyOwner {
        require(_newBulkBuyLimit != 0, "Bulk Buy Limit must be greater than 0");
        require(
            _newBulkBuyLimit < maxTotalSupply,
            "Bulk Buy Limit must be less than Max Total Supply"
        );
        bulkBuyLimit = _newBulkBuyLimit;
    }

    /// @notice Only Contract Owner can use this function to pause the contract.
    /// @dev Used to prevent users from minting NFTs.
    function togglePaused() public onlyOwner {
        paused = !paused;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override (ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override (ERC721, ERC721Enumerable)
        returns (bool)
    {
        return ERC721.supportsInterface(interfaceId)
            || ERC721Enumerable.supportsInterface(interfaceId);
    }

    /// @notice Withdraws the funds from the contract to contract owner.
    /// @dev Only Contract Owner can use this function.
    function withdraw() public payable onlyOwner {
        (bool success,) =
            payable(msg.sender).call{value: address(this).balance}("");
        require(
            success, "Address: unable to send value, recipient may have reverted"
        );
    }

    /// @notice Allows owner to withdraw any ERC20 tokens sent to this contract.
    /// @param _tokenAddr The address of the ERC20 token.
    /// @dev Only Contract Owner can use this function.
    function withdrawErc20s(address _tokenAddr) public onlyOwner {
        (bool success,) =
            payable(msg.sender).call{value: address(_tokenAddr).balance}("");
        require(success, "Address: unable to send value");
    }
}
