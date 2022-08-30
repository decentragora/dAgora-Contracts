/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title dAgora Basic NFT OZ
/// @author DadlessNsad || 0xOrphan
/// @notice Used as a template for creating new NFT contracts.
contract BasicNFTPlus is ERC721, Ownable {
    using Strings for string;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    /// @notice Where the NFTs metadata is stored.
    string public baseURI;

    /// @notice The file extension for the NFTs baseURI.
    string public baseExtension = ".json";

    /// @notice Used to store the allowed addresses for minting.
    /// @dev This is used to store the addresses that are allowed to mint NFTs during presale.
    bytes32 public merkleRoot;

    /// @notice Used to pause and unpause the contract.
    bool public paused = true;

    /// @notice Used to change and set the sale state of the contract.
    bool public preSale = true;

    /// @notice The price to mint a new NFT.
    uint256 public mintCost;

    /// @notice The maximum amount of NFTs that can be minted in one transaction.
    uint256 public bulkBuyLimit;

    /// @notice The maximum amount of NFTs that can be minted by a allowed listed address.
    uint256 public maxAllowListAmount;

    /// @notice The maximum amount of NFTs that can be minted.
    uint256 public maxTotalSupply;

    /// @notice Maps a address to the amount of NFTs they have minted.
    /// @dev This is used to keep track of the amount of NFTs a address has minted during presale.
    mapping(address => uint256) public presaleMintBalance;

    /// @notice Event emitted when a membership is purchased.
    /// @param _name The name of the NFT.
    /// @param _symbol The symbol of the NFT.
    /// @param _baseURI The baseURI of the NFT.
    /// @param _mintCost The cost to mint a new NFT.
    /// @param _bulkBuyLimit The maximum amount of NFTs that can be minted in one transaction.
    /// @param _maxAllowListAmount The max amount of NFTs that can be minted by a allowed listed address.
    /// @param _maxTotalSupply The maximum amount of NFTs that can be minted.
    /// @param _newOwner The address of the owner/ msg.sender.
    /// @param _merkleRoot The merkle root of the allowed addresses.
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _mintCost,
        uint16 _bulkBuyLimit,
        uint16 _maxAllowListAmount,
        uint256 _maxTotalSupply,
        address _newOwner,
        bytes32 _merkleRoot
    )
        ERC721(_name, _symbol)
    {
        baseURI = _baseURI;
        mintCost = _mintCost;
        bulkBuyLimit = _bulkBuyLimit;
        maxAllowListAmount = _maxAllowListAmount;
        maxTotalSupply = _maxTotalSupply;
        merkleRoot = _merkleRoot;
        _tokenIdCounter = Counters.Counter(0);
        transferOwnership(_newOwner);
    }

    /// @notice Checks if the contract is paused.
    /// @dev Used to prevent users from minting NFTs when the contract is paused.
    modifier isPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier isValidMerkleProof(bytes32[] calldata merkleProof, bytes32 root) {
        require(
            MerkleProof.verify(merkleProof, root, keccak256(abi.encodePacked(msg.sender))),
            "Address does not exist in list"
        );
        _;
    }

    /// @notice Checks if the contract is in presale state.
    /// @dev Used to prevent users not in allow list from minting NFTs when the contract is in presale state.
    modifier isPreSale() {
        require(preSale == true, "Presale not active");
        _;
    }

    /// @notice Checks if the contract is in public sale state.
    modifier isPublic() {
        require(!preSale, "Sale not Public");
        _;
    }

    /// @notice Function for allowlisted addresses to mint NFTs.
    /// @dev Used to mint NFTs during presale.
    /// @param _proof The merkle proof of the msg.sender's address.
    /// @param _amount The amount of NFTs to mint.
    function presaleMint(bytes32[] calldata _proof, uint256 _amount)
        public
        payable
        isPaused
        isValidMerkleProof(_proof, merkleRoot)
        isPreSale
    {
        require(
            _amount + presaleMintBalance[msg.sender] <= maxAllowListAmount,
            "Reached max amount for whitelist"
        );
        require(
            (_tokenIdCounter.current() + _amount) <= maxTotalSupply, "Soldout"
        );
        require(msg.value >= (_amount * mintCost), "Insufficient funds");

        for (uint256 i = 1; i <= _amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            presaleMintBalance[msg.sender] += _amount;
            _safeMint(msg.sender, tokenId);
        }
    }

    /// @notice Function for public to mint NFTs.
    /// @dev Used to mint NFTs during public sale.
    /// @param _amount The amount of NFTs to mint.
    function mintNFT(uint256 _amount) public payable isPaused isPublic {
        require(_amount <= bulkBuyLimit, "Over Max per Tx");
        require(
            (_tokenIdCounter.current() + _amount) <= maxTotalSupply, "Soldout"
        );
        require(msg.value >= (_amount * mintCost), "Insufficient funds");

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
            _safeMint(msg.sender, _tokenIdCounter.current());
        }
    }

    /// @notice Allows contract owner to change the merkle root.
    /// @param _merkleRoot The new merkle root.
    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    /// @notice Allows contract owner to change the contracts sale state.
    /// @dev Used to change the contract from presale to public sale.
    function togglePreSale() public onlyOwner {
        preSale = !preSale;
    }

    /// @notice Allows contract owner to change the contracts paused state.
    /// @dev Used to pause & unpause the contract.
    function togglePaused() public onlyOwner {
        paused = !paused;
    }

    /// @notice Allows the owner to change the baseURI.
    /// @param _baseURI The new baseURI.
    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
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

    /// @notice Allows the owner to change the max allow list amount.
    /// @param _newMaxAllowListAmount The new max allow list amount.
    function setMaxAllowListAmount(uint256 _newMaxAllowListAmount)
        public
        onlyOwner
    {
        require(
            _newMaxAllowListAmount < bulkBuyLimit,
            "Max Allow List Amount must be less than Bulk Buy Limit"
        );
        maxAllowListAmount = _newMaxAllowListAmount;
    }

    /// @notice Only Contract Owner can use this function to pause the contract.
    /// @param _newBulkBuyLimit The new bulkBuyLimit.
    /// @dev The bulkBuyLimit must be less than the maxTotalSupply.
    function setBulkBuyLimit(uint256 _newBulkBuyLimit) public onlyOwner {
        require(_newBulkBuyLimit != 0, "Bulk Buy Limit must be greater than 0");
        require(
            _newBulkBuyLimit < maxTotalSupply,
            "Bulk Buy Limit must be less than Max Total Supply"
        );
        bulkBuyLimit = _newBulkBuyLimit;
    }

    /// @notice Checks the current token supply of the contract.
    /// @return The current token supply.
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter.current();
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
