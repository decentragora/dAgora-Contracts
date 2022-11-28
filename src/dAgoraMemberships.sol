// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "ERC721A/ERC721A.sol";
import {RequestGuildRole} from "./RequestGuildRole.sol";
import {IdAgoraMembership} from "./IdAgoraMemberships.sol";


/// @title DecentrAgora Memberships
/// @author DadlessNsad || 0xOrphan
/// @notice This contract is used to manage the memberships and access of DecentrAgora's tools
contract dAgoraMemberships is
    RequestGuildRole,
    IdAgoraMembership,
    ERC721A,
    Ownable,
    ReentrancyGuard
{

    /// @notice Stores a tokenId's membership tier.
    struct Membership {
        uint8 tier;
    }

    /// @notice The level of tier for each membership
    enum Tier {
        ECCLESIAE,
        DAGORIAN,
        HOPLITE,
        PERICLESIA
    }

    /// @notice The storage location of the membership metadata.
    string public cid;

    /// @notice Used to pause and unpause the contract.
    bool public paused = true;

    /// @notice The address of DAI token.
    address public immutable DAI;

    /// @notice DecentrAgora's multisig address.
    address public dAgoraTreasury;

    uint96 public rewardedRole;

    /// @notice Adds a extra day to expiring memberships.
    uint256 public constant GRACE_PERIOD = 86400; // 1 days in seconds

    /// @notice The price of periclesia tier.
    uint256 public periclesiaPrice = 1000 * 10 ** 18;

    /// @notice The price of hoplite tier.
    uint256 public hoplitePrice = 80 * 10 ** 18;

    /// @notice The price of dagorian tier.
    uint256 public dAgorianPrice = 50 * 10 ** 18;

    /// @notice The price of ecclesia tier.
    uint256 public ecclesiaePrice = 0;

    /// @notice The Membership fee per month
    uint256 public monthlyPrice = 5 * 10 ** 18;

    /// @notice Discount rate given to members who pay for a year in advance
    uint256 public discountRate = 5 * 10 ** 18;

    /// @notice Token tiers mapped to individual token Ids.
    mapping(uint256 => Membership) private tokenTier;

    /// @notice Token Ids mapped to their expiration date.
    mapping(uint256 => uint256) public expires;

    /// @notice Token Ids mapped to their Owner.
    mapping(uint256 => address) public tokenIndexedToOwner;

    /// @notice Tracks if a address has minted or not.
    mapping(address => bool) public claimed;

    /// @notice Tracks delegated addresses for a tokenId.
    /// @notice TokenId must be Percelisia tier.
    mapping(uint256 => address[]) internal _tokenDelegates;

    /// @notice Event emitted when a membership is purchased.
    /// @param _to The address of the purchaser.
    /// @param _tokenId The id of the purchased membership.
    /// @param tier The tier of the purchased membership.
    /// @param duration The duration of the purchased membership.
    event MembershipMinted(
        address indexed _to,
        uint256 indexed _tokenId,
        Membership tier,
        uint256 duration
    );

    /// @notice Event emitted when a membership is extended.
    /// @param tokenId The id of the extended membership.
    /// @param duration The duration of the extended membership.
    event MembershipRenewed(uint256 tokenId, uint256 duration);

    /// @notice Event emitted when a membership tier is upgraded
    /// @param tokenId The id of the upgraded membership.
    /// @param oldTier The old tier of the upgraded membership.
    /// @param tier The new tier of the upgraded membership.
    event MembershipUpgraded(uint256 tokenId, uint256 oldTier, Membership tier);

    /// @notice Event emitted when a membership is cancelled.
    /// @param tokenId The id of the cancelled membership.
    event MembershipCancelled(uint256 tokenId);
    /// @notice Event emitted when a membership is expired.
    /// @param tokenId The id of the expired membership.
    event MembershipExpired(uint256 tokenId);

    /// @notice Sets the contracts variables.
    /// @param _cid The storage location of the membership metadata.
    /// @param _DAI The address of DAI token.
    /// @param _dAgoraTreasury DecentrAgora's multisig address.
    /// @param _guildId The Id of the guild, the oracle interacts with.
    /// @param _rewardedRole The role that is checked by oracle for free membership.
    /// @param linkToken The address of the LINK token.
    /// @param oracleAddress The address of the oracle.
    /// @param _jobId The Id of the job, the oracle interacts with.
    /// @param _oracleFee The fee the oracle charges for a request.
    constructor(
        string memory _cid,
        address _DAI,
        address _dAgoraTreasury,
        string memory _guildId,
        uint96 _rewardedRole,
        address linkToken,
        address oracleAddress,
        bytes32 _jobId,
        uint256 _oracleFee
    )
        RequestGuildRole(linkToken, oracleAddress, _jobId, _oracleFee, _guildId)
        ERC721A("dAgora Memberships", "DAMS")
    {
        cid = _cid;
        DAI = _DAI;
        dAgoraTreasury = _dAgoraTreasury;
        rewardedRole = _rewardedRole;
    }

    /*////////////////////////////////////// Modifiers //////////////////////////////////////////////////*/
    /// @notice Checks if the contract is paused.
    modifier isNotPaused() {
        require(!paused);
        _;
    }

    /// @notice Checks if users address has already minted or not.
    modifier isNotMember() {
        _isNotMember();
        _;
    }

    /// @notice Checks new duration amount is greater than 0 and less than 12.
    /// @param duration The duration of the membership in months.
    modifier durationCheck(uint256 duration) {
        _durationCheck(duration);
        _;
    }

    /// @notice Checks if the tokenId membership is expiring soon.
    /// @param tokenId The id of the membership.
    modifier isExpiredSoon(uint256 tokenId) {
        _isExpiredSoon(tokenId);
        _;
    }

    /// @notice Checks that the msg.sender is the tokenId owner
    /// @dev Modifier for functions
    /// @dev Used on funcs where we only want token owner to interact
    /// @dev example being a token owner can renew a token but not a random user.
    modifier onlyController(uint256 _tokenId) {
        _onlyController(_tokenId);
        _;
    }

    /// @notice Checks that the tokens tier is Periclesia.
    /// @param _tokenId The id of the membership.
    modifier isPerclesia(uint256 _tokenId) {
        _isPerclesia(_tokenId);
        _;
    }

    /// @notice Checks that the msg.sender is either the tokenId owner or a delegate.
    /// @dev Modifier guard for delegate & owner functions
    /// @param _tokenId The id of the membership.
    modifier isDelegateOrOwner(uint256 _tokenId) {
        _isDelegateOrOwner(_tokenId);
        _;
    }

    /*////////////////////////////////////// Public Mint Functions //////////////////////////////////////////////////*/

    /// @notice Mints a membership for the msg.sender using ERC20Permit.
    /// @param _durationInMonths The duration of the membership in months.
    /// @param tier The tier of the membership.
    /// @param _deadline The deadline for the transaction.
    /// @param v The v value of the signature.
    /// @param r The r value of the signature.
    /// @param s The s value of the signature.
    function mintdAgoraMembership(
        uint96 _durationInMonths,
        Membership calldata tier,
        uint256 _deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) 
        public
        isNotPaused
        isNotMember
        durationCheck(_durationInMonths)
        nonReentrant
    {
        require(tier.tier != 0, "Cannot mint Ecclesiae tier");
        require(tier.tier < 4, "Cannot mint Periclesia tier");
        uint256 _tokenId = totalSupply() + 1;
        uint256 _duration = block.timestamp + (_durationInMonths * 30 days);
        uint256 price = _getPrice(_durationInMonths, tier);

        IERC20Permit(DAI).permit(
            msg.sender,
            address(this),
            price,
            _deadline,
            v,
            r,
            s
        );

        IERC20(DAI).transferFrom(msg.sender, dAgoraTreasury, price);
       

        tokenIndexedToOwner[_tokenId] = msg.sender;
        tokenTier[_tokenId] = tier;
        expires[_tokenId] = _duration + GRACE_PERIOD;
        claimed[msg.sender] = true;
        _safeMint(msg.sender, 1);

    }

    /// @notice Sends request to oracle to mint Ecclesia Tier membership for the msg.sender.
    function freeClaim() public override isNotPaused isNotMember nonReentrant {
        uint256 tokenId = totalSupply() + 1;
        requestAccessCheck(
            msg.sender,
            rewardedRole,
            this.fulfillClaim.selector,
            abi.encode(msg.sender, tokenId)
        );
        emit ClaimRequested(msg.sender);
    }

    /// @notice Mints a Ecclesia Tier membership for the msg.sender, if checks pass.
    /// @param requestId The address of the user.
    /// @param access The id of the membership.
    function fulfillClaim(bytes32 requestId, uint256 access)
        public
        checkRole(requestId, access)
    {
        (address receiver, uint256 tokenId) =
            abi.decode(requests[requestId].args, (address, uint256));
        // Free 3 month trial
        uint256 _duration = block.timestamp + (3 * 30 days);
        // Add token as claimed
        claimed[receiver] = true;
        tokenTier[tokenId] = Membership(0);
        expires[tokenId] = _duration + GRACE_PERIOD;
        tokenIndexedToOwner[tokenId] = receiver;
        emit Claimed(receiver);
        _safeMint(receiver, 1);
    }

    /*////////////////////////////////////// Public Renew Functions //////////////////////////////////////////////////*/
    /// @notice Renews time of a membership for tokenId Using ERC20 Permit for Transaction.
    /// @param _tokenId The id of the membership.
    /// @param _newDuration The new added duration of the membership in months.
    /// @param _deadline The deadline for the transaction.
    /// @param v The v value of the signature.
    /// @param r The r value of the signature.
    /// @param s The s value of the signature.
    function renewMembership(
        uint256 _tokenId,
        uint256 _newDuration,
        uint256 _deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        isNotPaused
        isDelegateOrOwner(_tokenId)
        durationCheck(_newDuration)
        isExpiredSoon(_tokenId)
        nonReentrant
    {
        uint256 duration = (_newDuration * 30 days);
        uint256 price;
        if (_newDuration == 12) {
            price = (monthlyPrice * _newDuration) - discountRate;
        } else {
            price = (monthlyPrice * _newDuration);
        }

        IERC20Permit(DAI).permit(
            msg.sender,
            address(this),
            price,
            _deadline,
            v,
            r,
            s
        );

        IERC20(DAI).transferFrom(msg.sender, dAgoraTreasury, price);

        expires[_tokenId] = expires[_tokenId] + (duration + GRACE_PERIOD);
        emit MembershipRenewed(_tokenId, expires[_tokenId]);
    }

    /// @notice Upgrades a membership tier if tier isn't already fully upgraded to the highest tier.
    /// @dev Only the owner of the membership can upgrade it.
    /// @param _tokenId The id of the membership.
    /// @param newTier The new tier of the membership.
    /// @param _deadline The deadline for the transaction.
    /// @param v The v value of the signature.
    /// @param r The r value of the signature.
    /// @param s The s value of the signature.
    function upgradeMembership(
        uint256 _tokenId,
        Membership calldata newTier,
        uint256 _deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        isNotPaused
        onlyController(_tokenId)
        nonReentrant
    {
        uint8 oldTier = tokenTier[_tokenId].tier;
        require(newTier.tier > oldTier, "New tier is the same as current tier");
        require(newTier.tier < 4, "Token is already a precisian member");
        uint256 price;
        if (newTier.tier == 1 && oldTier == 0) {
            price = dAgorianPrice;
        } else if (newTier.tier == 2 && oldTier == 0) {
            price = dAgorianPrice + hoplitePrice;
        } else if (newTier.tier == 3 && oldTier == 0) {
            price = dAgorianPrice + hoplitePrice + periclesiaPrice;
        } else if (newTier.tier == 2 && oldTier == 1) {
            price = hoplitePrice - dAgorianPrice;
        } else if (newTier.tier == 3 && oldTier == 1) {
            price = (hoplitePrice - dAgorianPrice) + periclesiaPrice;
        } else if (newTier.tier == 3 && oldTier == 2) {
            price = periclesiaPrice - (hoplitePrice + dAgorianPrice);
        } else {
            require(false, "Invalid tier");
        }
        
        IERC20Permit(DAI).permit(
            msg.sender,
            address(this),
            price,
            _deadline,
            v,
            r,
            s
        );

        IERC20(DAI).transferFrom(msg.sender, dAgoraTreasury, price);

        tokenTier[_tokenId] = newTier;
        emit MembershipUpgraded(_tokenId, oldTier, tokenTier[_tokenId]);
    }

    /// @notice Cancels a membership if msg.sender is owner of the token.
    /// @dev Only the owner of the membership can cancel it.
    /// @param _tokenId The id of the membership to be cancelled.
    function cancelMembership(uint256 _tokenId)
        public
        isNotPaused
        onlyController(_tokenId)
        nonReentrant
    {
        expires[_tokenId] = block.timestamp + GRACE_PERIOD;
        emit MembershipCancelled(_tokenId);
    }

    /*////////////////////////////////////// Only Owner Functions //////////////////////////////////////////////////*/
    /// @notice Allows contract owner to gift a membership to a address.
    /// @param _to The address of the receiver.
    /// @param _durationInMonths The duration of the membership in months.
    /// @param tier The tier of the gifted membership.
    function giftMembership(
        address _to,
        uint96 _durationInMonths,
        Membership calldata tier
    )
        public
        onlyOwner
        durationCheck(_durationInMonths)
        nonReentrant
    {
        require(tier.tier < 4, "Cannot gift a precisian membership");
        require(
            claimed[_to] != true, "Can't Gift user who already has membership"
        );
        uint256 tokenId = totalSupply() + 1;
        uint256 duration = block.timestamp + (_durationInMonths * 30 days);

        tokenTier[tokenId] = tier;
        expires[tokenId] = duration + GRACE_PERIOD;
        tokenIndexedToOwner[tokenId] = _to;
        claimed[_to] = true;
        emit MembershipMinted(_to, tokenId, tier, expires[tokenId]);
        _safeMint(_to, 1);
    }

    /// @notice Allows contract owner to gift a upgrade for an existing membership.
    /// @param _tokenId The id of the membership to be upgraded.
    /// @param newTier The new tier of the membership.
    function giftUpgrade(uint256 _tokenId, Membership calldata newTier)
        public
        onlyOwner
        nonReentrant
    {
        require(newTier.tier < 4, "Cannot gift a precisian membership");
        require(
            tokenTier[_tokenId].tier < newTier.tier,
            "Cannot upgrade to a tier that is less than current tier"
        );
        uint256 oldTier = tokenTier[_tokenId].tier;
        tokenTier[_tokenId] = newTier;

        emit MembershipUpgraded(_tokenId, oldTier, tokenTier[_tokenId]);
    }

    /// @notice Allows contract owner to gift a renewal for an existing membership.
    /// @param _tokenId The id of the membership to be renewed.
    /// @param _durationInMonths The new added duration of the membership in months.
    function addTimeForMembership(uint256 _tokenId, uint96 _durationInMonths)
        public
        onlyOwner
        durationCheck(_durationInMonths)
        nonReentrant
    {
        uint256 duration = (_durationInMonths * 30 days);
        expires[_tokenId] = expires[_tokenId] + (duration + GRACE_PERIOD);
        emit MembershipRenewed(_tokenId, expires[_tokenId]);
    }

    /// @notice Allows a membership owner to add delegates to their membership.
    /// @dev Tokens Tier must be Precisian to add delegates.
    /// @param _tokenId The id of the membership.
    /// @param _delegatee The addresses of the delegatee.
    function addDelegatee(
        uint256 _tokenId, 
        address _delegatee
    )
        public
        isNotPaused
        isPerclesia(_tokenId)
        onlyController(_tokenId)
        nonReentrant
    {
        uint256 currentLen = _tokenDelegates[_tokenId].length;
        require(
            1 + currentLen <= 10,
            "Cannot delegate more than 10 addresses"
        );

        require(
            _delegatee != address(0),
            "Cannot delegate to address 0"
        );

        require(
            _delegatee != msg.sender,
            "Cannot delegate to self"
        );

        require(
            _delegatee != address(this),
            "Cannot delegate to contract"
        );
        require(
            !_contains(_tokenId, _delegatee),
            "Already delegated"
        );
        
        _tokenDelegates[_tokenId].push(_delegatee);
    }

    /// @notice Allows a membership owner to swap a delegatee for another delegatee.
    /// @dev Tokens Tier must be Precisian to swap delegates.
    /// @param _tokenId The id of the membership.
    /// @param _oldDelegatee The addresses of the delegatee.
    /// @param _newDelegatee The addresses of the new delegatee.
    function swapDelegate(
        uint256 _tokenId,
        address _oldDelegatee,
        address _newDelegatee
    )
        public 
        isNotPaused
        isPerclesia(_tokenId)
        onlyController(_tokenId)
        nonReentrant
    {
        require(
            _oldDelegatee != _newDelegatee,
            "Cannot swap to the same address"
        );

        require(
            _newDelegatee != address(0),
            "Cannot swap to address 0"
        );

        require(
            _newDelegatee != msg.sender,
            "Cannot swap to self"
        );

        require(
            _newDelegatee != address(this),
            "Cannot swap to contract"
        );

        for(uint i = 0; i < _tokenDelegates[_tokenId].length; i++) {
            if(_tokenDelegates[_tokenId][i] == _oldDelegatee) {
                _tokenDelegates[_tokenId][i] = _newDelegatee;
                break;
            }
        }
    }

    /// @notice Allows a membership owner to remove a delegatee from their membership.
    /// @dev Tokens Tier must be Precisian to remove delegates.
    /// @param _tokenId The id of the membership.
    /// @param _delegatee The addresses of the delegatee.
    /// @param _slot of the delegatee to be removed.
    function removeDelegatee(
        uint256 _tokenId,
        address _delegatee,
        uint8 _slot
    ) 
        public 
        isNotPaused
        isPerclesia(_tokenId)
        onlyController(_tokenId)
        nonReentrant 
    {
        require(
            _slot <= _tokenDelegates[_tokenId].length,
            "Cannot remove a delegatee that is not in the slot"
        );

        require(
            _tokenDelegates[_tokenId][_slot] == _delegatee,
            "Cannot remove a delegatee that is not in the slot"
        );

        delete _tokenDelegates[_tokenId][_slot];
        _tokenDelegates[_tokenId][_slot] = _tokenDelegates[_tokenId][_tokenDelegates[_tokenId].length - 1];
        _tokenDelegates[_tokenId].pop();
    }

    /// @notice Allows contract owner to change contracts paused state.
    function togglePaused() external onlyOwner {
        paused = !paused;
    }

    /// @notice Allows contract owner to change the rewardedRole.
    /// @param _newRole The new rewardedRole.
    function setRewardedRole(uint96 _newRole) public onlyOwner {
        rewardedRole = _newRole;
    }

    /// @notice Allows contract owner to change the discountRate
    /// @param _discountRate The new discount rate.
    function setDiscountRate(uint256 _discountRate) public onlyOwner {
        discountRate = _discountRate;
    }

    /// @notice Allows contract owner to change the monthly price of membership.
    /// @param _monthlyPrice The new monthly price of membership.
    function setMonthlyPrice(uint256 _monthlyPrice) public onlyOwner {
        monthlyPrice = _monthlyPrice;
    }

    /// @notice Allows contract owner to change the dAgorian tier price.
    /// @param _dAgorianPrice The new dAgorian tier price.
    function setdAgorianPrice(uint256 _dAgorianPrice) public onlyOwner {
        dAgorianPrice = _dAgorianPrice;
    }

    /// @notice Allows contract owner to change the hoplite tier price.
    /// @param _hoplitePrice The new hoplite tier price.
    function setHoplitePrice(uint256 _hoplitePrice) public onlyOwner {
        hoplitePrice = _hoplitePrice;
    }

    /// @notice Allows contract owner to change the periclesia tier price.
    /// @param _periclesiaPrice The new periclesia tier price.
    function setPericlesiaPrice(uint256 _periclesiaPrice) public onlyOwner {
        periclesiaPrice = _periclesiaPrice;
    }

    /// @notice Allows contract owner to set the dAgoraTreasury address.
    /// @param _dAgoraTreasury The address of the dAgoraTreasury.
    function setdAgoraTreasury(address _dAgoraTreasury) public onlyOwner {
        dAgoraTreasury = _dAgoraTreasury;
    }

    /// @notice Allows contract owner to set the GuildId.
    /// @param _guildId The string of the GuildId.
    function setGuildId(string memory _guildId) public onlyOwner {
        guildId = _guildId;
    }

    /// @notice Allows contract owner to withdraw Ether sent to contract.
    function emergWithdrawal() public onlyOwner {
        uint256 balance = address(this).balance;
        require(
            balance > 0,
            "Contract has no Ether to withdraw"
        );
        require(
            payable(msg.sender).send(balance),
            "Withdrawal failed"
        );
    }

    /// @notice Allows contract owner to withdraw ERC20 tokens sent to contract.
    /// @param _ERC20 The address of the ERC20 token to withdraw.
    function emergERC20Withdrawal(address _ERC20) public onlyOwner {
        uint256 balance = IERC20(_ERC20).balanceOf(address(this));
        require(
            IERC20(_ERC20).transfer(dAgoraTreasury, balance),
            "Failed to transfer tokens"
        );
    }

    /*////////////////////////////////////// Public View Functions //////////////////////////////////////////////////*/
    /// @notice Checks if a tokenId is a vaild member.
    /// @param _tokenId The id of the membership to check.
    /// @return Boolean based off membership expiry.
    function isValidMembership(uint256 _tokenId) public view returns (bool) {
        return expires[_tokenId] > block.timestamp;
        
    }

    /// @notice Check when a tokenId expires.
    /// @param _tokenId The id of the membership to check.
    /// @return The timestamp of when the membership expires.
    function membershipExpiresIn(uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        if (block.timestamp > expires[_tokenId]) {
            return 0;
        } else {
            return expires[_tokenId] - block.timestamp;
        }
    }

    /// @notice Check the tier of a tokenId.
    /// @param _tokenId The id of the membership to check.
    /// @return The tier of the membership.
    function checkTokenTier(uint256 _tokenId) external view returns (uint256) {
        return tokenTier[_tokenId].tier;
    }

    /// @notice Check the owner of a tokenId.
    /// @param _tokenId The id of the membership to check.
    /// @return The owner of the membership.
    function checkTokenIndexedToOwner(uint256 _tokenId)
        external
        view
        returns (address)
    {
        return tokenIndexedToOwner[_tokenId];
    }

    /// @notice Check all the delegatees of a tokenId.
    /// @param _tokenId The id of the membership to check.
    /// @return The delegatees addresses of the membership.
    function checkTokenDelegates(uint256 _tokenId)
        external
        view
        returns (address[] memory)
    {
        return _tokenDelegates[_tokenId];
    }

    /// @notice IERC20Permit tx count.
    /// @param owner The address of the owner of the ERC20.
    /// @return the current nonce.
    function nonces(address owner) public view virtual returns (uint256) {
        return IERC20Permit(DAI).nonces(owner);
    }

    /// @notice View function to see if a address is a delegatee or owner of a tokenId.
    /// @param _tokenId The id of the membership to check.
    /// @param _address The address to check.
    /// @return Boolean based off if the address is a delegatee or owner of the tokenId.
    function isOwnerOrDelegate(uint256 _tokenId, address _address)
        public
        view
        returns (bool)
    {
        if (tokenIndexedToOwner[_tokenId] == _address) {
            return true;
        } else {
            for (uint256 i = 0; i < _tokenDelegates[_tokenId].length; i++) {
                if (_tokenDelegates[_tokenId][i] == _address) {
                    return true;
                }
            }
        }
        return false;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override (ERC721A, IERC721A)
        returns (string memory)
    {
        require(
            _exists(_tokenId), "ERC721Metadata: URI query for nonexistent token"
        );

        string memory tokenId = _toString(_tokenId);
        string memory generationPath = "/";
        uint256 _tokenTier = tokenTier[_tokenId].tier;
        if (_tokenTier == 0) {
            generationPath = "dagorian/";
        } else if (_tokenTier == 1) {
            generationPath = "hoplite/";
        } else if (_tokenTier == 2) {
            generationPath = "periclesia/";
        }

        return
            bytes(cid).length > 0
            ? string(abi.encodePacked(cid, generationPath, tokenId, ".json"))
            : "";
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _durationCheck(uint256 duration) private pure {
        require(
            duration > 0 && duration <= 12,
            "Membership duration must be between 1 and 12 months"
        );
    }

    function _isNotPaused() private view {
        require(!paused, "Contract is paused");
    }

    function _isNotMember() private view {
        require(!claimed[msg.sender], "You are already a member");
    }

    function _isExpiredSoon(uint256 tokenId) private view {
        require(
            block.timestamp + 30 days + GRACE_PERIOD >= expires[tokenId],
            "Token isn't expiring soon"
        );
    }

    function _onlyController(uint256 _tokenId) private view {
        require(
            msg.sender == tokenIndexedToOwner[_tokenId],
            "Not owner of token"
        );
    }

    function _isPerclesia(uint256 _tokenId) private view {
        require(
            tokenTier[_tokenId].tier == 3,
            "Token is not Periclesia"
        );
    }

    function _isDelegateOrOwner(uint256 _tokenId) private view {
        require(
            _contains(_tokenId, msg.sender) == true ||
            tokenIndexedToOwner[_tokenId] == msg.sender,
            "Not a delegate or Owner"
        );
    }

    function _getPrice(uint96 duration, Membership calldata tier) private view returns (uint256) {
        uint256 price;
        uint256 monthlyCost = duration * monthlyPrice;
        if(duration == 12) {
            if(tier.tier == 1) {
                price = (monthlyCost + dAgorianPrice) - discountRate;
            } else if(tier.tier == 2) {
                price = (monthlyCost + hoplitePrice) - discountRate;
            } else if(tier.tier == 3) {
                price = (monthlyCost + periclesiaPrice) - discountRate;
            }
        } else {
            if(tier.tier == 1) {
                price = (monthlyCost + dAgorianPrice);
            } else if(tier.tier == 2) {
                price = (monthlyCost + hoplitePrice);
            } else if(tier.tier == 3) {
                price = (monthlyCost + periclesiaPrice);
            }
        }
        return price;
    }

    function _contains(uint256 _tokenId, address user) internal view returns (bool) {
        for(uint256 i = 0; i < _tokenDelegates[_tokenId].length; i++) {
            if(_tokenDelegates[_tokenId][i] == user) {
                return true;
            }   else {
                return false;
            }
        }
    }
}
