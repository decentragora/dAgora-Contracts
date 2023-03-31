// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {ERC721AUpgradeable} from 'erc721a-upgradeable/contracts/ERC721AUpgradeable.sol';
import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {ReentrancyGuardUpgradeable} from '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import {IERC20PermitUpgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol';
import {IERC20Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';


contract DagoraMembershipsV1 is
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    ERC721AUpgradeable
{

    /// @notice Enum for membership tiers.
    /// @dev The order of the tiers is important, as it determines the order of the tiers in the enum
    /// @param Ecclesia the lowest tier of membership
    /// @param dAgorian the second lowest tier of membership
    /// @param Hoplite the second highest tier of membership
    /// @param Perclesian the highest tier of membership
    enum Tiers {
        Ecclesia,
        Dagorian,
        Hoplite,
        Perclesian
    }

    /// @notice Struct for membership details.
    /// @param tier the tier of the membership
    /// @param member the address of the member
    /// @param tokenId the tokenId of the membership
    /// @param expiration the expiration of the membership
    struct Membership {
        // Tiers tier;
        uint8 tier;
        address member;
        uint256 tokenId;
        uint256 expiration;
    }


    /// @notice Base URI for the token metadata.
    string public baseURI;

    /// @notice Boolean to check if the contract is paused.
    bool public isPaused;

    /// @notice Boolean to check if the contract has been initialized.
    bool public _isInitialized;

    /// @notice Address of the dagora treasury.
    address public dagoraTreasury;

    /// @notice Address of the DAI token.
    address public DAI;

    /// @notice Address of the Proxy contract.
    address public proxyImplementation;

    /// @notice The price of the Ecclesia membership.
    uint256 public ecclesiaPrice;

    /// @notice The price of the Ecclesia membership renewal.
    uint256 public ecclesiaRenewPrice;

    /// @notice The price of the dAgorian membership.
    uint256 public dagorianPrice;

    /// @notice The price of the dAgorian membership renewal.
    uint256 public dagoraRenewPrice;

    /// @notice The price of the Hoplite membership.
    uint256 public hoplitePrice;

    /// @notice The price of the Hoplite membership renewal.
    uint256 public hopliteRenewPrice;

    /// @notice The price of the Perclesian membership.
    uint256 public percelsiaPrice;

    /// @notice The price of the Perclesian membership renewal.
    uint256 public percelsiaRenewPrice;

    /// @notice The grace period for renewing a membership.
    uint256 public constant GRACE_PERIOD = 1 days;

    /// @notice The discount for renewing a membership for 12 months.
    uint256 public discount;

    /// @notice The event emitted when a membership is purchased.
    /// @param member the address of the member
    /// @param tokenId the tokenId of the membership
    /// @param tier the tier of the membership
    /// @param expiration the expiration of the membership
    event MembershipPurchased(address indexed member, uint256 indexed tokenId, uint8 tier, uint256 expiration);

    /// @notice The event emitted when a free membership is claimed.
    /// @param member the address of the member
    /// @param tokenId the tokenId of the membership
    /// @param tier the tier of the membership
    /// @param expiration the expiration of the membership
    event FreeMembershipClaimed(address indexed member, uint256 indexed tokenId, uint8 tier, uint256 expiration);

    /// @notice The event emitted when a membership is upgraded.
    /// @param member the address of the member
    /// @param tokenId the tokenId of the membership
    /// @param oldTier the old tier of the membership
    /// @param newTier the new tier of the membership
    event MembershipUpgraded(address indexed member, uint256 indexed tokenId, uint8 oldTier, Tiers newTier);

    /// @notice The event emitted when a membership is renewed.
    /// @param member the address of the member
    /// @param tokenId the tokenId of the membership
    /// @param expiration the expiration of the membership
    event MembershipRenewed(address indexed member, uint256 indexed tokenId, uint256 expiration);

    /// @notice The event emitted when a membership is claimed.
    /// @param member the address of the member
    /// @param tokenId the tokenId of the membership
    /// @param tier the tier of the membership
    /// @param expiration the expiration of the membership
    event MembershipGifted(address indexed member, uint256 indexed tokenId, uint8 tier, uint256 expiration);

    /// @notice The event emitted when a membership is canceled.
    /// @param member the address of the member
    /// @param tokenId the tokenId of the membership
    /// @param expiration the expiration of the membership
    event MembershipCanceled(address indexed member, uint256 indexed tokenId, uint256 expiration);

    /// @notice The event emitted when a delegate is removed.
    /// @param member the address of the member
    /// @param tokenId the tokenId of the membership
    /// @param delegatee the address of the delegatee
    event DelegateRemoved(address indexed member, uint256 indexed tokenId, address delegatee);

    /// @notice The event emitted when a delegate is added.
    /// @param member the address of the member
    /// @param tokenId the tokenId of the membership
    /// @param delegatee the address of the delegatee
    event DelegateAdded(address indexed member, uint256 indexed tokenId, address delegatee);

    /// @notice The event emitted when a delegate is swapped.
    /// @param member the address of the member
    /// @param tokenId the tokenId of the membership
    /// @param oldDelegatee the address of the old delegatee
    /// @param newDelegatee the address of the new delegatee
    event DelegateSwapped(address indexed member, uint256 indexed tokenId, address oldDelegatee, address newDelegatee);


    /// @notice mapping that stores the membership details.
    mapping (uint256 => Membership) public memberships;

    /// @notice mapping that stores a tokenids expiration.
    mapping (uint256 => uint256) public experation;

    /// @notice mapping that sets true if a membership is claimed.
    mapping(address => bool) public claimed;

    /// @notice mapping that stores the delegates of a tokenId
    mapping(uint256 => address[]) public tokenDelegates;

    function initialize(
        string memory _name,
        string memory _symbol,
        string memory baseURI_,
        address _dagoraTreasury,
        address _DAI
    ) public initializerERC721A initializer  {
        require(!_isInitialized, 'DagoraMemberships: Already initialized');
        __ERC721A_init(_name, _symbol);
        __Ownable_init();
        __ReentrancyGuard_init();
        dagoraTreasury = _dagoraTreasury;
        transferOwnership(_dagoraTreasury);
        DAI = _DAI;
        baseURI = baseURI_;
        isPaused = true;
        ecclesiaPrice = 0;
        ecclesiaRenewPrice = 5 * 10 ** 18;
        dagorianPrice = 50 * 10 ** 18;
        dagoraRenewPrice = 5 * 10 ** 18;
        hoplitePrice = 80 * 10 ** 18;
        hopliteRenewPrice = 10 * 10 ** 18;
        percelsiaPrice = 1000 * 10 ** 18;
        percelsiaRenewPrice = 50 * 10 ** 18;
        discount = 5 * 10 ** 18;
        _isInitialized = true;
    }

    /// @notice Modifier to check if the contract is paused or, not paused.
    modifier isNotPaused() {
        require(!isPaused, 'DagoraMemberships: Contract is paused');
        _;
    }

    /// @notice Modifier to check if the msg.sender has already claimed their membership.
    modifier isNotMember() {
        require(!claimed[msg.sender], 'DagoraMemberships: Already a member');
        _;
    }

    /// @notice Modifier to check if the membership is renewable.
    /// @dev the membership must be within 30 days of expiration to be renewable.
    /// @param tokenId the tokenId of the membership.
    modifier isRenewable(uint256 tokenId) {
        require(
            block.timestamp + 30 days + GRACE_PERIOD >= experation[tokenId],
            "DagoraMemberships: Membership is not renewable"
        );
        _;
    }

    /// @notice Modifier to check if the tokenId tier is Perclesian.
    modifier isPerclesian(uint256 tokenId) {
        require(
            memberships[tokenId].tier == uint8(Tiers.Perclesian),
            "DagoraMemberships: Only Percelsia members can delegate"
        );
        _;
    }

    /// @notice Modifier to check if the membership is not expired.
    modifier _isValidMembership(uint256 _tokenId) {
        require(experation[_tokenId] > block.timestamp, "dAgoraMemberships: Membership expired, Please renew");
        _;
    }

    /// @notice Modifier to check if the duration is valid.
    /// @dev duration must be greater than 0 and less than 12 months.
    modifier durationCheck(uint256 _dur) {
        require(_dur > 0 && _dur <= 12, "dAgoraMemberships: Invalid duration");
        _;
    }

    /// @notice Modifier to check if the msg.sender is the owner of the membership.
    modifier onlyController(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender, "dAgoraMemberships: Only controller");
        _;
    }

    /// @notice Modifier to check if the msg.sender is the owner or delegatee of the membership.
    modifier onlyDelegateeAndOwner(uint256 _tokenId) {
        require(
            _isDelegatee(_tokenId, msg.sender) || ownerOf(_tokenId) == msg.sender, "dAgoraMemberships: Only delegatee"
        );
        _;
    }

    /// @notice Function to mint a membership.
    /// @param _durationInMonths The duration of the membership in months. (1-12)
    /// @param _tier The tier of the membership. (Perclesian, Hoplite, dAgorian, Ecclesia)
    /// @param _deadline The deadline for the permit signature.
    /// @param _proxy The address of the proxy contract.
    /// @param _v The v value of the permit signature.
    /// @param _r The r value of the permit signature.
    /// @param _s The s value of the permit signature.
    /// @dev The permit signature is used to transfer the DAI from the msg.sender to the dAgoraTreasury.
    function mintMembership(
        uint8 _tier,
        uint96 _durationInMonths,
        uint256 _deadline,
        address _proxy,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )   public
        isNotPaused
        isNotMember
        durationCheck(_durationInMonths)
        nonReentrant
    {
        require(_tier > 0 && _tier < 4, "dAgoraMemberships: Invalid tier");
        require(_proxy == proxyImplementation, "dAgoraMemberships: Invalid proxy");
        uint256 _duration = _durationInMonths * 30 days;
        uint256 _price = getMintPrice(_durationInMonths, _tier);
        uint256 _tokenId = _getNextTokenId();

        require(IERC20Upgradeable(DAI).balanceOf(msg.sender) >= _price, "dAgoraMemberships: Insufficient balance");
        IERC20PermitUpgradeable(DAI).permit(msg.sender, _proxy, _price, _deadline, _v, _r, _s);
        bool success = IERC20Upgradeable(DAI).transferFrom(msg.sender, dagoraTreasury, _price);
        require(success, "dAgoraMemberships: Transfer failed");

        experation[_tokenId] = block.timestamp + (_duration + GRACE_PERIOD);
        memberships[_tokenId] = Membership(_tier, msg.sender, _tokenId,  experation[_tokenId]);
        claimed[msg.sender] = true;
        _mint(msg.sender, 1);
        emit MembershipPurchased(msg.sender, _tokenId, _tier, experation[_tokenId]);
    }


    /// @notice Function to claim a ecclesia membership.
    function freeMint() public isNotPaused isNotMember nonReentrant {
        uint256 _tokenId = _getNextTokenId();
        uint256 _duration = (3 * 30 days ) + block.timestamp;

        experation[_tokenId] = _duration + GRACE_PERIOD;
        memberships[_tokenId] = Membership(0, msg.sender, _tokenId, experation[_tokenId]);
        claimed[msg.sender] = true;
        _mint(msg.sender, 1);
        emit FreeMembershipClaimed(msg.sender, _tokenId, 0, experation[_tokenId]);
    }


    /// @notice Function to Renew a membership.
    /// @param _tokenId The tokenId of the membership.
    /// @param _deadline The deadline for the permit signature.
    /// @param _durationInMonths The duration of the membership in months. (1-12)
    /// @param _proxy The address of the proxy contract.
    /// @param _v The v value of the permit signature.
    /// @param _r The r value of the permit signature.
    /// @param _s The s value of the permit signature.
    /// @dev The permit signature is used to transfer the DAI from the msg.sender to the dAgoraTreasury.
    function renewMembership(
        uint96 _durationInMonths,
        uint256 _tokenId,
        uint256 _deadline,
        address _proxy,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )   external
        isNotPaused
        isRenewable(_tokenId)
        durationCheck(_durationInMonths)
        onlyDelegateeAndOwner(_tokenId)
        nonReentrant
    {
        require(_proxy == proxyImplementation, "dAgoraMemberships: Invalid proxy");
        uint256 _duration = _durationInMonths * 30 days;
        uint256 _price = getRenewalPrice(_durationInMonths, memberships[_tokenId].tier);
        IERC20PermitUpgradeable(DAI).permit(msg.sender, _proxy, _price, _deadline, _v, _r, _s);
        bool success = IERC20Upgradeable(DAI).transferFrom(msg.sender, dagoraTreasury, _price);
        require(success, "dAgoraMemberships: Transfer failed");

        uint256 __experation = experation[_tokenId] + _duration;
        experation[_tokenId] = __experation;
        memberships[_tokenId].expiration = __experation;
        emit MembershipRenewed(msg.sender, _tokenId, __experation);
    }

    /// @notice Function to upgrade a membership.
    /// @param newTier The new tier of the membership.
    /// @param oldTier The old tier of the membership.
    /// @param tokenId The tokenId of the membership.
    /// @param deadline The deadline for the permit signature.
    /// @param _proxy The address of the proxy contract.
    /// @param v The v value of the permit signature.
    /// @param r The r value of the permit signature.
    /// @param s The s value of the permit signature.
    /// @dev The permit signature is used to transfer the DAI from the msg.sender to the dAgoraTreasury.
    function upgradeMembership(
        uint8 newTier,
        uint8 oldTier,
        uint256 tokenId,
        uint256 deadline,
        address _proxy,
        uint8 v,
        bytes32 r,
        bytes32 s
    )   public
        isNotPaused
        onlyController(tokenId)
        _isValidMembership(tokenId)
        nonReentrant
    {
        require(newTier > oldTier, "dAgoraMemberships: Invalid upgrade");
        require(newTier > 0 && newTier < 4, "dAgoraMemberships: Invalid tier");
        require(_proxy == proxyImplementation, "dAgoraMemberships: Invalid proxy");
        uint256 _price = _getUpgradePrice(tokenId, oldTier, newTier);
        IERC20PermitUpgradeable(DAI).permit(msg.sender, _proxy, _price, deadline, v, r, s);
        bool success = IERC20Upgradeable(DAI).transferFrom(msg.sender, dagoraTreasury, _price);
        require(success, "dAgoraMemberships: Transfer failed");
        memberships[tokenId].tier = newTier;
    }

    /// @notice Function to cancel a membership.
    /// @param tokenId The tokenId of the membership.
    function cancelMembership(uint256 tokenId) public isNotPaused onlyController(tokenId) _isValidMembership(tokenId) nonReentrant {
        /// set Token as expired and add grace period
        experation[tokenId] = block.timestamp + GRACE_PERIOD;
        memberships[tokenId].expiration = block.timestamp + GRACE_PERIOD;
        emit MembershipCanceled(msg.sender, tokenId, block.timestamp + GRACE_PERIOD);
    }

    /// @notice Function to add a delegate to a membership.
    /// @param _delegatee The address of the delegatee.
    /// @param _tokenId The tokenId of the membership.
    function addDelegate(
        address _delegatee,
        uint256 _tokenId
    )   external
        isNotPaused
        _isValidMembership(_tokenId)
        onlyController(_tokenId)
        isPerclesian(_tokenId)
    {
        require(tokenDelegates[_tokenId].length < 10, "dAgoraMemberships: Too many delegates");
        require(!_contains(_tokenId, _delegatee), "dAgoraMemberships: Delegatee is already included");
        require(_delegatee != msg.sender, "dAgoraMemberships: Cannot delegate to self");
        require(_delegatee != address(0), "dAgoraMemberships: Cannot delegate to address(0)");
        require(_delegatee != address(this), "dAgoraMemberships: Cannot delegate to address(this)");
        require(tokenDelegates[_tokenId].length <= 10, "dAgoraMemberships: Too many delegates");
        tokenDelegates[_tokenId].push(_delegatee);
        emit DelegateAdded(msg.sender, _tokenId, _delegatee);
    }

    /// @notice Function to remove a delegate from a membership.
    /// @param _delegatee The address of the delegatee.
    /// @param _tokenId The tokenId of the membership.
    /// @param slot The slot of the delegatee.
    function removeDelegate(address _delegatee, uint256 _tokenId, uint8 slot)
        public
        isNotPaused
        onlyController(_tokenId)
        _isValidMembership(_tokenId)
        isPerclesian(_tokenId)
        nonReentrant
    {
        require(_exists(_tokenId), "dAgoraMemberships: Token does not exist");
        require(_contains(_tokenId, _delegatee), "dAgoraMemberships: Delegatee is not included");
        require(slot <= tokenDelegates[_tokenId].length, "dAgoraMemberships: Slot is out of range");
        require(tokenDelegates[_tokenId][slot] == _delegatee, "dAgoraMemberships: Delegatee is not in slot");

        delete tokenDelegates[_tokenId][slot];
        tokenDelegates[_tokenId][slot] = tokenDelegates[_tokenId][tokenDelegates[_tokenId].length - 1];
        tokenDelegates[_tokenId].pop();
        emit DelegateRemoved(msg.sender, _tokenId, _delegatee);
    }

    /// @notice Function to swap a delegate from a membership.
    /// @param _tokenId The tokenId of the membership.
    /// @param oldDelegate The address of the old delegate.
    /// @param newDelegate The address of the new delegate.
    function swapDelegate(uint256 _tokenId, address oldDelegate, address newDelegate)
        public
        isNotPaused
        onlyController(_tokenId)
        _isValidMembership(_tokenId)
        isPerclesian(_tokenId)
        nonReentrant
    {
        require(_exists(_tokenId), "dAgoraMemberships: Token does not exist");
        require(!_contains(_tokenId, newDelegate), "dAgoraMemberships: New delegate is already included");
        require(newDelegate != msg.sender, "dAgoraMemberships: Cannot delegate to self");
        require(newDelegate != address(0), "dAgoraMemberships: Cannot delegate to address(0)");
        require(newDelegate != address(this), "dAgoraMemberships: Cannot delegate to address(this)");

        for (uint8 i = 0; i < tokenDelegates[_tokenId].length; i++) {
            if (tokenDelegates[_tokenId][i] == oldDelegate) {
                tokenDelegates[_tokenId][i] = newDelegate;
            }
        }
        emit DelegateSwapped(msg.sender, _tokenId, oldDelegate, newDelegate);
    }

    /// @notice only owner function to gift membership to an address, that address must not already have a membership.
    /// @param to The address to gift membership to.
    /// @param tier The tier of the membership.
    /// @param durationInMonths The duration of the membership in months.
    function giftMembership(
        address to,
        uint8 tier,
        uint96 durationInMonths
    )   external
        durationCheck(durationInMonths)
        onlyOwner
    {
        require(to != address(0), "DagoraMemberships: cannot gift to 0 address");
        require(tier < 4, "dAgoraMemberships: Invalid tier");
        require(!claimed[to], "dAgoraMemberships: Address already has a membership");
        uint256 _duration = block.timestamp + (durationInMonths * 30 days);
        uint256 _tokenId = _getNextTokenId();

        experation[_tokenId] = _duration + GRACE_PERIOD;
        memberships[_tokenId] = Membership(tier, to, _tokenId, _duration);
        claimed[to] = true;
        _mint(to, 1);
        emit MembershipGifted(to, _tokenId, tier, experation[_tokenId]);
    }

    /// @notice only owner function to gift a upgrade to an existing membership.
    /// @param tokenId The tokenId of the membership.
    /// @param tier The tier of the membership.
    function giftUpgrade(uint256 tokenId, uint8 tier) external onlyOwner {
        uint8 _tier = memberships[tokenId].tier;
        require(tier > 0 && tier < 4, "dAgoraMemberships: Invalid tier");
        require(_exists(tokenId), "dAgoraMemberships: Invalid tokenId");
        require(tier > _tier, "dAgoraMemberships: Invalid tier");
        memberships[tokenId].tier = tier;
    }

    /// @notice only owner function to gift a extension to an existing membership.
    /// @param tokenId The tokenId of the membership.
    /// @param durationInMonths The duration of the membership in months.
    function giftExtension(
        uint256 tokenId,
        uint96 durationInMonths
    )   external
        durationCheck(durationInMonths)
        onlyOwner
    {
        require(_exists(tokenId), "dAgoraMemberships: Invalid tokenId");
        uint256 _duration = (durationInMonths * 30 days);
        experation[tokenId] = experation[tokenId] + _duration;
        memberships[tokenId].expiration = experation[tokenId];
    }

    /// @notice Function to pause the contract.
    /// @dev Only owner can call this function.
    function togglePaused() external onlyOwner {
        isPaused = !isPaused;
    }

    /// @notice Function to set the baseURI.
    /// @dev Only owner can call this function.
    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }

    /// @notice Function to set the Discount price.
    /// @dev Only owner can call this function.
    function setDiscount(uint256 _discount) external onlyOwner {
        discount = _discount;
    }

    /// @notice Function to set the price of a Percelsia tier membership.
    /// @dev Only owner can call this function.
    function setPercelsiaPrice(uint256 _price) external onlyOwner {
        percelsiaPrice = _price;
    }

    /// @notice Function to set the price of a Hoplite tier membership.
    /// @dev Only owner can call this function.
    function setHoplitePrice(uint256 _price) external onlyOwner {
        hoplitePrice = _price;
    }

    /// @notice Function to set the price of a Dagorian tier membership.
    /// @dev Only owner can call this function.
    function setDagorianPrice(uint256 _price) external onlyOwner {
        dagorianPrice = _price;
    }

    /// @notice Function to set the price of a Ecclesia tier membership.
    /// @dev Only owner can call this function.
    function setEcclesiaPrice(uint256 _price) external onlyOwner {
        ecclesiaPrice = _price;
    }

    /// @notice Function to set the price of a Percelsia tier membership renewal.
    /// @dev Only owner can call this function.
    function setPercelsiaRenewPrice(uint256 _price) external onlyOwner {
        percelsiaRenewPrice = _price;
    }

    /// @notice Function to set the price of a Hoplite tier membership renewal.
    /// @dev Only owner can call this function.
    function setHopliteRenewPrice(uint256 _price) external onlyOwner {
        hopliteRenewPrice = _price;
    }

    /// @notice Function to set the price of a Dagorian tier membership renewal.
    /// @dev Only owner can call this function.
    function setDagorianRenewPrice(uint256 _price) external onlyOwner {
        dagoraRenewPrice = _price;
    }

    /// @notice Function to set the price of a Ecclesia tier membership renewal.
    /// @dev Only owner can call this function.
    function setDagoraTreasury(address _dagoraTreasury) external onlyOwner {
        dagoraTreasury = _dagoraTreasury;
    }

    /// @notice Function to set the address of the proxy contract.
    /// @dev Only owner can call this function.
    /// @param _proxyAddress The address of the proxy contract.
    function setProxyAddress(address _proxyAddress) external onlyOwner {
        proxyImplementation = _proxyAddress;
    }

    /// @notice Function to withdraw ERC20 tokens from the contract.
    /// @dev Only owner can call this function.
    function withdrawERC20(address _token) external onlyOwner {
        uint256 balance = IERC20Upgradeable(_token).balanceOf(address(this));
        bool success = IERC20Upgradeable(_token).transfer(msg.sender, balance);
        require(success, "dAgoraMemberships: Transfer failed");
    }

    /// @notice Function to withdraw ETH from the contract.
    /// @dev Only owner can call this function.
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(dagoraTreasury).transfer(balance);
    }

    /// @notice Function to get a tokenId membership details.
    /// @param _tokenId The tokenId of the membership.
    /// @return Membership struct.
    function getMembership(uint256 _tokenId) external view returns (Membership memory) {
        return memberships[_tokenId];
    }

    /// @notice Function to get a tokenId membership tier.
    /// @param _tokenId The tokenId of the membership.
    /// @return uint8 tier.
    function getMembershipTier(uint256 _tokenId) external view returns (uint8) {
        return memberships[_tokenId].tier;
    }

    /// @notice Function to get a tokenId membership expiration.
    /// @param _tokenId The tokenId of the membership.
    /// @return uint256 expiration.
    function getExpiration(uint256 _tokenId) external view returns (uint256) {
        return experation[_tokenId];
    }

    /// @notice Function to get a tokenId membership expiration.
    /// @param _tokenId The tokenId of the membership.
    /// @return bool isValid.
    function isValidMembership(uint256 _tokenId) external view returns (bool) {
        return experation[_tokenId] > block.timestamp;
    }

    function addressTokenIds(address _owner) external view returns (uint256 _tokenId) {
        //// Check all memberships.member to see if they match the owner
        uint256 totalMemberships = totalSupply();
        for (uint256 i = 1; i < totalMemberships; i++) {
            if (memberships[i].member == _owner) {
                return i;
            } 
        }
    }

    /// @notice Function to get a tokenIds delegates.
    /// @param _tokenId The tokenId of the membership.
    /// @return address[] delegates.
    function getTokenDelegates(uint256 _tokenId) external view returns (address[] memory) {
        return tokenDelegates[_tokenId];
    }


    /// @notice Function to check is a address is a owner or delegate of a tokenid
    /// @param tokenId The tokenId of the membership.
    /// @param addrs The address to check.
    /// @return _isOwnerOrDelegate bool.
    function isOwnerOrDelegate(uint256 tokenId, address addrs) public view returns (bool _isOwnerOrDelegate) {
        if (_isDelegatee(tokenId, addrs) || ownerOf(tokenId) == addrs) {
            _isOwnerOrDelegate = true;
        } else {
            _isOwnerOrDelegate = false;
        }
    }

    /// @notice Function to get the mint price of a membership
    /// @param _durationInMonths The duration of the membership in months.
    /// @param _tier The tier of the membership.
    /// @return _price The price of the membership.
    function getMintPrice(uint96 _durationInMonths, uint8 _tier) public view returns (uint256 _price) {
        if (_durationInMonths == 12) {
            if (_tier == uint8(Tiers.Perclesian)) {
                uint256 monthlyCost = percelsiaRenewPrice * _durationInMonths;
                _price = (percelsiaPrice + monthlyCost) - percelsiaRenewPrice;
            } else if (_tier == uint8(Tiers.Hoplite)) {
                uint256 monthlyCost = hopliteRenewPrice * _durationInMonths;
                _price = (hoplitePrice + monthlyCost) - hopliteRenewPrice;
            } else if (_tier == uint8(Tiers.Dagorian)) {
                uint256 monthlyCost = dagoraRenewPrice * _durationInMonths;
                _price = (dagorianPrice + monthlyCost) - dagoraRenewPrice;
            } else if (_tier == uint8(Tiers.Ecclesia)) {
                _price = ecclesiaPrice;
            }
        } else {
            if (_tier == uint8(Tiers.Perclesian)) {
                uint256 monthlyCost = percelsiaRenewPrice * _durationInMonths;
                _price = percelsiaPrice + monthlyCost;
            } else if (_tier == uint8(Tiers.Hoplite)) {
                uint256 monthlyCost = hopliteRenewPrice * _durationInMonths;
                _price = hoplitePrice + monthlyCost;
            } else if (_tier == uint8(Tiers.Dagorian)) {
                uint256 monthlyCost = dagoraRenewPrice * _durationInMonths;
                _price = dagorianPrice + monthlyCost;
            } else if (_tier == uint8(Tiers.Ecclesia)) {
                _price = ecclesiaPrice;
            }
        }
        return _price;
    }

    /// @notice Function to get the upgrade price of a membership
    /// @param tokenId The tokenId of the membership.
    /// @param oldTier The old tier of the membership.
    /// @param newTier The new tier of the membership.
    /// @return _price The price of the membership.
    function _getUpgradePrice(uint256 tokenId, uint8 oldTier, uint8 newTier) public view returns(uint256 _price) {
        require(_exists(tokenId), "dAgoraMemberships: Membership does not exist");
        require(newTier != uint8(Tiers.Ecclesia), "dAgoraMemberships: Cannot upgrade to Ecclesia membership");
        require(newTier != oldTier, "dAgoraMemberships: Cannot upgrade to same tier");
        require(oldTier != uint8(Tiers.Perclesian), "dAgroaMemberships: Cannot upgrade from Perclesian membership");
        //find time left in months
        uint256 timeLeft = (experation[tokenId] - block.timestamp) / 30 days;
        if (oldTier == uint8(Tiers.Ecclesia)) {
            if (newTier == uint8(Tiers.Dagorian)) {
                _price = dagorianPrice + (dagoraRenewPrice * timeLeft);
            } else if (newTier == uint8(Tiers.Hoplite)) {
                _price = hoplitePrice + (hopliteRenewPrice * timeLeft);
            } else if (newTier == uint8(Tiers.Perclesian)) {
                _price = percelsiaPrice + (percelsiaRenewPrice * timeLeft);
            }
        } else if (oldTier == uint8(Tiers.Dagorian)) {
            if (newTier == uint8(Tiers.Hoplite)) {
               _price = (hoplitePrice - dagorianPrice) + ((hopliteRenewPrice * timeLeft) - (dagoraRenewPrice * timeLeft));
            } else if (newTier == uint8(Tiers.Perclesian)) {
                _price = (percelsiaPrice - dagorianPrice) + ((percelsiaRenewPrice * timeLeft) - (dagoraRenewPrice * timeLeft));
            }
        } else if (oldTier == uint8(Tiers.Hoplite)) {
            _price = (percelsiaPrice - hoplitePrice) + ((percelsiaRenewPrice * timeLeft) - (hopliteRenewPrice * timeLeft));
        }
        return _price;
    }

    /// @notice Function to get the renewal price of a membership
    /// @param _newDuration The new duration of the membership.
    /// @param currentTier The current tier of the membership.
    /// @return _price The price of the membership.
    function getRenewalPrice(uint96 _newDuration, uint8 currentTier) public view returns(uint256 _price) {
        if(_newDuration == 12) {
            if (currentTier == uint8(Tiers.Perclesian)) {
                uint256 monthlyCost = percelsiaRenewPrice * _newDuration;
                _price = monthlyCost - percelsiaRenewPrice;
            } else if (currentTier == uint8(Tiers.Hoplite)) {
                uint256 monthlyCost = hopliteRenewPrice * _newDuration;
                _price = monthlyCost - hopliteRenewPrice;
            } else if (currentTier == uint8(Tiers.Dagorian)) {
                uint256 monthlyCost = dagoraRenewPrice * _newDuration;
                _price = monthlyCost - dagoraRenewPrice;
            } else if (currentTier == uint8(Tiers.Ecclesia)) {
                uint256 monthlyCost = ecclesiaRenewPrice * _newDuration;
                _price = monthlyCost - ecclesiaRenewPrice;
            }
        } else {
            if (currentTier == uint8(Tiers.Perclesian)) {
                _price = percelsiaRenewPrice * _newDuration;
            } else if (currentTier == uint8(Tiers.Hoplite)) {
                _price = hopliteRenewPrice * _newDuration;
            } else if (currentTier == uint8(Tiers.Dagorian)) {
                _price = dagoraRenewPrice * _newDuration;
            } else if (currentTier == uint8(Tiers.Ecclesia)) {
                _price = ecclesiaRenewPrice * _newDuration;
            }
        }
        return _price;
    }

    /// @notice Returns a tokenIds URI.
    /// @param tokenId The tokenId of the membership.
    /// @return The URI of the token.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(baseURI, _toString(tokenId)));
    }


    /// @notice Internal function to check if an address is a delegate of a specfic tokenId.
    /// @param _tokenId The tokenId of the membership.
    /// @param _delegate The address to check.
    /// @dev This function is used in the isOwnerOrDelegate function.
    /// @return True if the address is a delegate of the tokenId. False if not.
    function _isDelegatee(uint256 _tokenId, address _delegate) internal view returns (bool) {
        for (uint256 i = 0; i < tokenDelegates[_tokenId].length; i++) {
            if (tokenDelegates[_tokenId][i] == _delegate) {
                return true;
            }
        }
        return false;
    }

    /// @notice Internal function to set the starting tokenId.
    /// @return The starting tokenId.
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    /// @notice Internal function to get the next tokenId
    /// @return The next tokenId.
    function _getNextTokenId() internal view returns (uint256) {
        return totalSupply() + 1;
    }

    /// @notice Internal override function to enable soulbound memberships.
    /// @dev if sender is not address(0), then transfer is not allowed.
    /// @param from the address of the sender.
    /// @param to the address of the receiver.
    /// @param tokenId the tokenId.
    /// @param quantity the quantity.
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 tokenId,
        uint256 quantity
    ) internal override(ERC721AUpgradeable) {
        require(
            from == address(0),
            "dAgoraMemberships: Soulbound membership"
        );
        super._beforeTokenTransfers(from, to, tokenId, quantity);
    }

    

    /// @notice Internal function to check if an address is a contained in a specfic tokenId.
    /// @param _tokenId The tokenId of the membership.
    /// @param user The address to check.
    /// @dev This function is used in the isOwnerOrDelegate function.
    /// @return True if the address is a delegate of the tokenId. False if not.
    function _contains(uint256 _tokenId, address user) internal view returns (bool) {
        for (uint256 i = 0; i < tokenDelegates[_tokenId].length; i++) {
            if (tokenDelegates[_tokenId][i] == user) {
                return true;
            } else {
                return false;
            }
        }
        return false;
    }

}