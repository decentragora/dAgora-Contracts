/// @title Simple ERC721A Minting Contract
/// @author Made By DecentrAgora
/// @notice use this contract to enhance you understand of the ERC721 Standard
/// @dev 0xOrphan || DadlessNsad

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "ERC721A/ERC721A.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

/// @title Power NFT Contract
/// @author DadlessNsad || 0xOrphan
/// @notice This is a template contract used to create new NFT contracts.
contract PowerNFT is ERC721A, ERC2981, Ownable {
    /// @notice Where the NFTs metadata is stored.
    string public baseURI;

    /// @notice The file extension for the NFTs baseURI.
    string public baseExtension = ".json";

    /// @notice Used to pause and unpause the contract.
    bool public paused = true;

    /// @notice The address that the royalty % will go to.
    address public royaltyReceiver;

    /// @notice The price to mint a new NFT.
    uint256 public mintCost;

    /// @notice The maximum amount of NFTs that can be minted in one transaction.
    uint16 public bulkBuyLimit;

    /// @notice The maximum amount of NFTs that can be minted.
    uint256 public maxTotalSupply;

    /// @notice Sets the contracts variables.
    /// @param _name The name of the NFT.
    /// @param _symbol The symbol of the NFT.
    /// @param _baseURI The baseURI of the NFT.
    /// @param _mintCost The cost to mint a new NFT.
    /// @param _bulkBuyLimit The maximum amount of NFTs that can be minted in one transaction.
    /// @param _maxTotalSupply The maximum amount of NFTs that can be minted.
    /// @param _royaltyCut The amount of the royalty cut.
    /// @param _newOwner The address that will be the owner of the contract.
    /// @param _royaltyReceiver The address that the royalty % will go to.
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _mintCost,
        uint16 _bulkBuyLimit,
        uint256 _maxTotalSupply,
        uint96 _royaltyCut,
        address _newOwner,
        address _royaltyReceiver
    )
        ERC721A(_name, _symbol)
    {
        baseURI = _baseURI;
        mintCost = _mintCost;
        royaltyReceiver = _royaltyReceiver;
        bulkBuyLimit = _bulkBuyLimit;
        maxTotalSupply = _maxTotalSupply;
        royaltyReceiver = _royaltyReceiver;

        transferOwnership(_newOwner);
        _setDefaultRoyalty(royaltyReceiver, _royaltyCut);
    }

    /// @notice Checks if the contract is paused.
    /// @dev Used to prevent users from minting NFTs when the contract is paused.
    modifier isPaused() {
        require(!paused, "Contract is Paused");
        _;
    }

    /// @notice Main function used to mint NFTs.
    /// @param _amount The amount of NFTs to mint.
    function mintNFT(uint256 _amount) public payable isPaused {
        require(_amount <= bulkBuyLimit, "Max per tx");
        require((_amount + totalSupply()) <= maxTotalSupply, "Soldout");
        require((_amount * mintCost) <= msg.value, "Insufficient Eth sent");

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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override (ERC721A, ERC2981)
        returns (bool)
    {
        return ERC721A.supportsInterface(interfaceId)
            || ERC2981.supportsInterface(interfaceId);
    }

    /// @notice Used to set the royalty receiver & amount.
    /// @param _receiver The address that the royalty % will go to.
    /// @param _value The amount of the royalty cut.
    /// @dev The value must be less than or equal to 10000. example (250 / 10000) * 100 = 2.5%.
    function setRoyalties(address _receiver, uint96 _value) public onlyOwner {
        _setDefaultRoyalty(_receiver, _value);
    }

    /// @notice Allows the owner to change the baseURI.
    /// @param _newBaseURI The new baseURI.
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    /// @notice Allows the owner to change the Base extension.
    /// @param _newBaseExtension The new baseExtension.
    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    /// @notice Allows the owner to change the mint cost.
    /// @param _newMintCost The new mint cost.
    function setMintCost(uint256 _newMintCost) public onlyOwner {
        mintCost = _newMintCost;
    }

    /// @param _newBulkBuyLimit The new bulkBuyLimit.
    /// @dev The bulkBuyLimit must be less than the maxTotalSupply.
    function setBulkBuyLimit(uint16 _newBulkBuyLimit) public onlyOwner {
        bulkBuyLimit = _newBulkBuyLimit;
    }

    /// @notice Allows contract owner to change the contracts paused state.
    /// @dev Used to pause & unpause the contract.
    function togglePaused() public onlyOwner {
        paused = !paused;
    }

    /// @notice Allows the owner to withdraw ether from contract.
    /// @dev The owner can only withdraw ether from the contract.
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
