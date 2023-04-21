// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {ERC721A} from "erc721a/contracts/ERC721A.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DagoraPaymentSplitterNFT is ERC721A, Ownable, ReentrancyGuard {

    /// @notice Struct to hold the payee and share amount.
    /// @dev payee is the address of the payee.
    /// @dev shareAmount is the amount of shares the payee has.
    struct PayeeShare {
        address payee;
        uint256 shareAmount;
    }

    /// @notice Boolean to determine if the contract is isPaused.
    /// @dev default value is true, contract is isPaused on deployment.
    bool public isPaused;

    /// @notice The base URI for all tokens.
    string public baseURI;

    /// @notice The file extension of the metadata can be set to nothing.
    /// @dev default value is json
    string public baseExtension;

    /// @notice The maximum number of tokens that can be minted in a single transaction.
    uint16 public bulkBuyLimit;

    /// @notice The cost to mint a token.
    uint256 public mintPrice;

    /// @notice The maximum number of tokens that can be minted.
    uint256 public maxSupply;

    /// @notice The number of payees.
    uint256 public payeeCount;

    /// @notice The total amount of shares.
    uint256 private _totalShares;

    /// @dev The total amount of released payments.
    uint256 private _totalReleased;

    /// @dev The addresses of the payees.
    address[] private _payees; 

    mapping(uint256 => PayeeShare) public payeeShares;
    /// @dev The amount of shares each address has.
    mapping(address => uint256) private _shares;
    /// @dev The amount of released payments each address has.
    mapping (address => uint256) private _released;
    /// @dev The amount of released payments each address has.
    mapping(IERC20 => uint256) private _erc20TotalReleased;
    /// @dev The amount of released payments each address has.
    mapping(IERC20 => mapping(address => uint256)) private _erc20Released;

    event Minted(address indexed to, uint256 indexed tokenId);
    event BaseURIChanged(string baseURI);
    event BaseExtensionChanged(string baseExtension);
    event MintCostChanged(uint256 mintPrice);
    event BulkBuyLimitChanged(uint16 bulkBuyLimit);
    event isPausedToggled(bool isPaused);
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event ERC20PaymentReleased(IERC20 indexed token, address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);


    /// @notice Constructor for the contract.
    /// @param name_ the name of the contract and token
    /// @param symbol_ the symbol of the token
    /// @param payees the addresses of the payees
    /// @param shares_ the amount of shares each payee has
    /// @param _mintPrice the cost to mint a token
    /// @param _maxSupply the maximum number of tokens that can be minted
    /// @param _bulkBuyLimit the maximum number of tokens that can be minted in a single transaction
    /// @param _baseURI the base URI for all tokens
    /// @param _baseExtension the file extension of the metadata can be set to nothing
    /// @param newOwner the address of the new owner
    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory payees,
        uint256[] memory shares_,
        uint256 _mintPrice,
        uint256 _maxSupply,
        uint16 _bulkBuyLimit,
        string memory _baseURI,
        string memory _baseExtension,
        address newOwner
    ) ERC721A(name_, symbol_) {
        require(payees.length == shares_.length, "Payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");
        payeeCount = payees.length;
        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
            payeeShares[i] = PayeeShare(payees[i], shares_[i]);
        }

        mintPrice = _mintPrice;
        maxSupply = _maxSupply;
        bulkBuyLimit = _bulkBuyLimit;
        baseURI = _baseURI;
        baseExtension = _baseExtension;
        isPaused = false;
        transferOwnership(newOwner);
    }

    /// @notice Modifier to check if the contract is isPaused.
    /// @dev Throws if the contract is isPaused.
    modifier isNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }

    /// @notice Funtion to mint one or more tokens.
    /// @param to the address to mint the tokens to
    /// @param amount the number of tokens to mint
    /// @dev Throws if the number of tokens to mint exceeds the bulk buy limit.
    /// @dev Throws if the number of tokens to mint exceeds the max supply.
    /// @dev Throws if the amount of ETH sent is less than the cost to mint a token.
    function mintNFT(address to, uint256 amount) public payable isNotPaused nonReentrant {
        require(amount > 0, "Amount must be greater than 0");
        require(to != address(0), "Cannot mint to the zero address");
        require(amount <= bulkBuyLimit, "Exceeds bulk buy limit");
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
        require(msg.value >= mintPrice * amount, "Incorrect amount of ETH sent");

        _mint(to, amount);
        emit Minted(to, totalSupply());
    }

    /// @notice onlyOwner function to mint one or more tokens.
    /// @param amount the number of tokens to mint
    /// @dev Throws if the number of tokens to mint exceeds the max supply.
    function reserveTokens(uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
        _mint(msg.sender, amount);
        emit Minted(msg.sender, totalSupply());
    }

    /// @notice getter function for the total shares.
    /// @return the total shares
    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    /// @notice getter function for the total released.
    /// @return the total released
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    /// @notice getter function for the total released.
    /// @param token the token to check
    function totalReleased(IERC20 token) public view returns (uint256) {
        return _erc20TotalReleased[token];
    }

    /// @notice getter function for the shares.
    /// @param account the address to check
    /// @return the shares for the address
    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }

    /// @notice getter function for the released.
    /// @param account the address to check
    /// @return the released for the address
    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    /// @notice getter function for the released.
    /// @param token the token to check
    /// @param account the address to check
    function released(IERC20 token, address account) public view returns (uint256) {
        return _erc20Released[token][account];
    }

    /// @notice getter function for the payees.
    /// @param index the index of the payee
    /// @return the address of the payee
    function payee(uint256 index) public view returns (address) {
        return _payees[index];
    }

    /// @notice getter function for checking how much a payee is owed.
    /// @param account the address to check
    /// @return the amount of ETH owed to the address
    function releasable(address account) public view returns (uint256) {
        uint256 totalReceived = address(this).balance + totalReleased();
        return _pendingPayment(account, totalReceived, released(account));
    }

    /// @notice getter function for checking how much a payee is owed.
    /// @param token the token to check
    /// @param account the address to check
    /// @return the amount of tokens owed to the address
    function releasable(IERC20 token, address account) public view returns (uint256) {
        uint256 totalReceived = token.balanceOf(address(this)) + totalReleased(token);
        return _pendingPayment(account, totalReceived, released(token, account));
    }

    /// @notice function to release the amount owed to a payee.
    /// @param account the address to release the payment to
    /// @dev Throws if the address has no shares.
    /// @dev Throws if the address is not due payment.
    function release(address payable account) public {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 payment = releasable(account);

        require(payment != 0, "PaymentSplitter: account is not due payment");

        // _totalReleased is the sum of all values in _released.
        // If "_totalReleased += payment" does not overflow, then "_released[account] += payment" cannot overflow.
        _totalReleased += payment;
        unchecked {
            _released[account] += payment;
        }

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

   /// @notice returns the tokenURI for a given token.
    /// @dev this function is only callable when the token exists.
    /// @param tokenId the tokenID to get the tokenURI for.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return string(abi.encodePacked(baseURI, _toString(tokenId), baseExtension));
    }

    /// @notice Onlyowner function to set the base URI.
    /// @dev this function is only callable by the owner of the contract.
    /// @param __baseURI the base URI to set.
    function setBaseURI(string memory __baseURI) external onlyOwner {
        baseURI = __baseURI;
        emit BaseURIChanged(baseURI);
    }

    /// @notice Onlyowner function to set the base extension.
    /// @dev this function is only callable by the owner of the contract.
    /// @param _baseExtension the base extension to set.
    function setBaseExtension(string memory _baseExtension) external onlyOwner {
        baseExtension = _baseExtension;
        emit BaseExtensionChanged(_baseExtension);
    }

    /// @notice Onlyowner function to set the mint price for the public sale.
    /// @dev this function is only callable by the owner of the contract.
    /// @param _mintPrice the mint cost to set.
    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
        emit MintCostChanged(mintPrice);
    }

    /// @notice Onlyowner function to set the bulk buy limit.
    /// @dev this function is only callable by the owner of the contract.
    /// @param _bulkBuyLimit the bulk buy limit to set.
    function setBulkBuyLimit(uint16 _bulkBuyLimit) external onlyOwner {
        bulkBuyLimit = _bulkBuyLimit;
        emit BulkBuyLimitChanged(_bulkBuyLimit);
    }

    /// @notice Onlyowner function to set the paused state of the contract.
    /// @dev this function is only callable by the owner of the contract.
    function togglePaused() external onlyOwner {
        isPaused = !isPaused;
        emit isPausedToggled(isPaused);
    }

    /// @notice internal override function that is called before any token transfer.
    /// @dev this function will revert if the contract is paused, pausing transfers of tokens.
    /// @param from The address of the sender.
    /// @param to The address of the receiver.
    /// @param tokenId The token ID.
    /// @param quantity The quantity of tokens to transfer.
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 tokenId,
        uint256 quantity
    ) internal override(ERC721A) {
        if (isPaused) {
            revert("Contract is paused");
        }
        super._beforeTokenTransfers(from, to, tokenId, quantity);
    }

    /// @notice function that returns the dagora contract type
    /// @return the dagora contract type
    function typeOf() public pure returns (string memory) {
        return "dAgora PaymentSplitterNFT";
    }

    /// @notice function that returns the dagora contract version
    /// @return the dagora contract version
    function version() public pure returns (string memory) {
        return "1.0.0";
    }

    /// @notice internal function that handles that starting tokenId of the collection
    /// @return the starting tokenId of the collection eg 1
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    /// @notice internal function that handles any pending payments for a payee.
    /// @param account the address to check
    /// @param totalReceived the total amount of ETH received
    /// @param alreadyReleased the amount of ETH already released
    /// @return the amount of ETH owed to the address
    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) {
        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
    }

    /// @notice internal function that adds a payee to the contract.
    /// @param account the address to add as a payee.
    /// @param shares_ the number of shares the payee has.
    /// @dev Throws if the address is the zero address.
    /// @dev Throws if the number of shares is 0.
    /// @dev Throws if the address already has shares.
    /// @dev Emits a {PayeeAdded} event.
    /// @dev only called by the constructor.
    function _addPayee(address account, uint256 shares_) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares += shares_;
        emit PayeeAdded(account, shares_);
    }
    
    /**
     * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully
     * reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the
     * reliability of the events, and not the actual splitting of Ether.
     *
     * To learn more about this see the Solidity documentation for
     * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback
     * functions].
     */
    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

}