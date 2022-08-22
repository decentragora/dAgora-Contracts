// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "ERC721A/ERC721A.sol";
import {RequestGuildRole} from "./RequestGuildRole.sol";
import "./IdAgoraMemberships.sol";

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
    address public DAI;

    /// @notice The address of USDC token.
    address public USDC;

    /// @notice DecentrAgora's multisig address.
    address public dAgoraTreasury;

    /// @notice Adds a extra day to expiring memberships.
    uint256 public constant GRACE_PERIOD = 86400; // 1 days in seconds


    uint96 public rewardedRole;
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
    /// @param _USDC The address of USDC token.
    /// @param _dAgoraTreasury DecentrAgora's multisig address.
    /// @param guildId The Id of the guild, the oracle interacts with.
    /// @param _rewardedRole The role that is checked by oracle for free membership.
    /// @param linkToken The address of the LINK token.
    /// @param oracleAddress The address of the oracle.
    /// @param jobId The Id of the job, the oracle interacts with.
    /// @param oracleFee The fee the oracle charges for a request.
    constructor(
        string memory _cid,
        address _DAI,
        address _USDC,
        address _dAgoraTreasury,
        string memory guildId,
        uint96 _rewardedRole,
        address linkToken,
        address oracleAddress,
        bytes32 jobId,
        uint256 oracleFee
    )
        RequestGuildRole(linkToken, oracleAddress, jobId, oracleFee, guildId)
        ERC721A("dAgora Memberships", "DAMS")
    {
        cid = _cid;
        DAI = _DAI;
        USDC = _USDC;
        dAgoraTreasury = _dAgoraTreasury;
        rewardedRole = _rewardedRole;
    }

    /*////////////////////////////////////// Modifiers //////////////////////////////////////////////////*/
    /// @notice Checks if the contract is paused.
    modifier isPaused() {
        require(!paused);
        _;
    }


    /// @notice Checks if users address has already minted or not.
    modifier isNotMember() {
        require(!claimed[msg.sender], "You are already a member");
        _;
    }


    /// @notice checks the transfer amount of Stable coins for membership.
    /// @param _ERC20 The address of the stablecoin used to purchase membership.
    modifier correctPayment(address _ERC20) {
        require(_ERC20 == DAI || _ERC20 == USDC, "Payment must be DAI or USDC");
        _;
    }


    /// @notice Checks new duration amount is greater than 0 and less than 12.
    /// @param duration The duration of the membership in months.
    modifier durationCheck(uint256 duration) {
        require(
            duration > 0 && duration <= 12,
            "Membership duration must be between 1 and 12 months"
        );
        _;
    }


    /// @notice Checks if the tokenId membership is expiring soon.
    /// @param tokenId The id of the membership.
    modifier isExpiredSoon(uint256 tokenId) {
        require(
            block.timestamp + 30 days + GRACE_PERIOD >= expires[tokenId], 
            "Token isn't expiring soon"
        );
        _;
    }

    /// @notice Checks that the msg.sender is the tokenId owner
    /// @dev Modifier for functions
    /// @dev Used on funcs where we only want token owner to interact
    /// @dev example being a token owner can renew a token but not a random user.
    modifier onlyController(uint256 _tokenId) {
        require(
            msg.sender == tokenIndexedToOwner[_tokenId], "Not owner of token"
        );
        _;
    }

    /*////////////////////////////////////// Public Mint Functions //////////////////////////////////////////////////*/

    /// @notice Mints a DAgorian membership for the msg.sender.
    /// @param _durationInMonths The duration of the membership in months.
    /// @param _ERC20 The address of the stablecoin used to purchase membership.
    function mintdAgoraianTier(uint96 _durationInMonths, address _ERC20)
        public
        isPaused
        isNotMember
        durationCheck(_durationInMonths)
        correctPayment(_ERC20)
        nonReentrant
    {
        uint256 _tokenId = totalSupply() + 1;
        uint256 _duration = block.timestamp + (_durationInMonths * 30 days);
        uint256 price;

        if (_durationInMonths == 12) {
            price =
                ((monthlyPrice * _durationInMonths) + dAgorianPrice) - discountRate;
        } else {
            price = ((monthlyPrice * _durationInMonths) + dAgorianPrice);
        }

        require(
            IERC20(_ERC20).balanceOf(msg.sender) >= price, "Not enough funds"
        );
        require(IERC20(_ERC20).transferFrom(msg.sender, dAgoraTreasury, price));

        tokenIndexedToOwner[_tokenId] = msg.sender;
        tokenTier[_tokenId] = Membership(1);
        expires[_tokenId] = _duration + GRACE_PERIOD;
        claimed[msg.sender] = true;
        _safeMint(msg.sender, 1);
    }


    /// @notice Mints a Hoptile Tier membership for the msg.sender.
    /// @param _durationInMonths The duration of the membership in months.
    /// @param _ERC20 The address of the stablecoin used to purchase membership.
    function mintHoptileTier(uint96 _durationInMonths, address _ERC20)
        public
        isPaused
        isNotMember
        durationCheck(_durationInMonths)
        correctPayment(_ERC20)
        nonReentrant
    {
        uint256 tokenId = totalSupply() + 1;
        uint256 _duration = block.timestamp + (_durationInMonths * 30 days);
        uint256 price;
        if (_durationInMonths == 12) {
            price =
                ((monthlyPrice * _durationInMonths) + hoplitePrice) - discountRate;
        } else {
            price = ((monthlyPrice * _durationInMonths) + hoplitePrice);
        }
        require(
            IERC20(_ERC20).balanceOf(msg.sender) >= price, "Not enough funds"
        );
        require(IERC20(_ERC20).transferFrom(msg.sender, dAgoraTreasury, price));
        tokenIndexedToOwner[tokenId] = msg.sender;
        tokenTier[tokenId] = Membership(2);
        expires[tokenId] = _duration + GRACE_PERIOD;
        claimed[msg.sender] = true;
        _safeMint(msg.sender, 1);
    }


    /// @notice Mints a Periclesia Tier membership for the msg.sender.
    /// @param _durationInMonths The duration of the membership in months.
    /// @param _ERC20 The address of the stablecoin used to purchase membership.
    function mintPericlesiaTier(uint96 _durationInMonths, address _ERC20)
        public
        isPaused
        isNotMember
        durationCheck(_durationInMonths)
        correctPayment(_ERC20)
        nonReentrant
    {
        uint256 tokenId = totalSupply() + 1;
        uint256 _duration = block.timestamp + (_durationInMonths * 30 days);
        uint256 price;
        if (_durationInMonths == 12) {
            price = ((monthlyPrice * _durationInMonths) + periclesiaPrice)
                - discountRate;
        } else {
            price = ((monthlyPrice * _durationInMonths) + periclesiaPrice);
        }
        require(
            IERC20(_ERC20).balanceOf(msg.sender) >= price, "Not enough funds"
        );
        require(IERC20(_ERC20).transferFrom(msg.sender, dAgoraTreasury, price));
        tokenIndexedToOwner[tokenId] = msg.sender;
        tokenTier[tokenId] = Membership(3);
        expires[tokenId] = _duration + GRACE_PERIOD;
        claimed[msg.sender] = true;
        _safeMint(msg.sender, 1);
    }


    /// @notice Sends request to oracle to mint Ecclesia Tier membership for the msg.sender.
    function freeClaim() public isPaused isNotMember nonReentrant override {
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
        // Add token as claimed
        claimed[receiver] = true;
        tokenTier[tokenId] = Membership(0);
        expires[tokenId] = 0;
        tokenIndexedToOwner[tokenId] = receiver;
        emit Claimed(receiver);
        _safeMint(receiver, 1);
    }

    /*////////////////////////////////////// Public Renew Functions //////////////////////////////////////////////////*/ 
    /// @notice Renews time of a membership for the msg.sender.
    /// @param _tokenId The id of the membership.
    /// @param _newDuration The new added duration of the membership in months.
    /// @param _ERC20 The address of the stablecoin used to purchase time for membership.
    function renewMembership(
        uint256 _tokenId,
        uint256 _newDuration,
        address _ERC20
    )
        public
        isPaused
        onlyController(_tokenId)
        durationCheck(_newDuration)
        correctPayment(_ERC20)
        isExpiredSoon(_tokenId)
        nonReentrant
    {
        require(tokenTier[_tokenId].tier != 0, "Token is not a member");
        uint256 duration = (_newDuration * 30 days);
        uint256 price;
        if (_newDuration == 12) {
            price = (monthlyPrice * _newDuration) - discountRate;
        } else {
            price = (monthlyPrice * _newDuration);
        }

        require(
            IERC20(_ERC20).balanceOf(msg.sender) >= price, "Not enough funds"
        );
        require(IERC20(_ERC20).transferFrom(msg.sender, dAgoraTreasury, price));

        emit MembershipRenewed(_tokenId, expires[_tokenId]);
        expires[_tokenId] = expires[_tokenId] + (duration + GRACE_PERIOD);    
    }

    /// @notice Upgrades a membership tier if msg.sender is owner of the token.
    /// @param _tokenId The id of the membership.
    /// @param newTier The new tier of the membership.
    /// @param _ERC20 The address of the stablecoin used to purchase time for membership.
    function upgradeMemebership(
        uint256 _tokenId,
        Membership calldata newTier,
        address _ERC20
    )
        public
        isPaused
        onlyController(_tokenId)
        correctPayment(_ERC20)
        nonReentrant
    {
        uint8 oldTier = tokenTier[_tokenId].tier;
        require(
            newTier.tier > oldTier,
            "New tier is the same as current tier"
        );
        require(newTier.tier != 0, "Cannot upgrade to tier 0");
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
        require(
            IERC20(_ERC20).balanceOf(msg.sender) >= price, "Not enough funds"
        );
        require(
            IERC20(_ERC20).transferFrom(msg.sender, dAgoraTreasury, price),
            "Failed to transfer funds"
        );
        tokenTier[_tokenId] = newTier;
        emit MembershipUpgraded(_tokenId, oldTier, tokenTier[_tokenId]);
    }

    /// @notice Cancels a membership if msg.sender is owner of the token.
    /// @param _tokenId The id of the membership to be cancelled.
    function cancelMembership(uint256 _tokenId) public isPaused onlyController(_tokenId) nonReentrant {
        expires[_tokenId] = block.timestamp + GRACE_PERIOD;
        emit MembershipCancelled(_tokenId);
    }

    /*////////////////////////////////////// Only Owner Functions //////////////////////////////////////////////////*/
    /// @notice Allows contract owner to gift a membership to a address.
    /// @param _to The address of the receiver.
    /// @param _durationInMonths The duration of the membership in months.
    /// @param tier The tier of the gifted membership.
    function giftMembership(address _to, uint96 _durationInMonths, Membership calldata tier) 
        public 
        onlyOwner 
        durationCheck(_durationInMonths)
        nonReentrant
    {
        require(tier.tier  < 3, "Membership tier must be 0,1,2");
        require(claimed[_to] != true, "Can't Gift user who already has membership");
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
        require(newTier.tier  < 3, "Membership tier must be 0,1,2");
        require(tokenTier[_tokenId].tier < newTier.tier, "Cannot upgrade to a tier that is less than current tier");
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
        uint256 duration =(_durationInMonths * 30 days);
        expires[_tokenId] = expires[_tokenId] + (duration + GRACE_PERIOD);
        emit MembershipRenewed(_tokenId, expires[_tokenId]);
    }


    /// @notice Allows contract owner to set the USDC contract address.
    /// @param _USDC The address of the USDC contract.
    function setUSDCAddress(address _USDC) public onlyOwner {
        USDC = _USDC;
    }


    /// @notice Allows contract owner to set the DAI contract address.
    /// @param _DAI The address of the DAI contract.
    function setDAIAddress(address _DAI) public onlyOwner {
        DAI = _DAI;
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
        (bool success, ) = dAgoraTreasury.call{value: address(this).balance}("");
        require(success, "Failed to send to lead.");
    }
    

    /// @notice Allows contract owner to withdraw ERC20 tokens sent to contract.
    /// @param _ERC20 The address of the ERC20 token to withdraw.
    function emergERC20Withdrawal(address _ERC20) public onlyOwner {
        uint balance = IERC20(_ERC20).balanceOf(address(this));
        require(IERC20(_ERC20).transfer(dAgoraTreasury, balance), "Failed to transfer tokens");
    }


    /*////////////////////////////////////// Public View Functions //////////////////////////////////////////////////*/
    /// @notice Checks if a tokenId is a vaild member.
    /// @param _tokenId The id of the membership to check.
    /// @return Boolean based off membership expiry.
    function isValidMembership(uint256 _tokenId) public view returns (bool) {
        if (tokenTier[_tokenId].tier == 0) {
            return true;
        } else {
            return expires[_tokenId] > block.timestamp;
        }
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
    function checkTokenIndexedToOwner(uint256 _tokenId) external view returns (address) {
        return tokenIndexedToOwner[_tokenId];
    }


    function tokenURI(uint256 _tokenId) 
        public 
        view 
        virtual 
        override(ERC721A, IERC721A)
        returns(string memory) 
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory tokenId = _toString(_tokenId);
        string memory  generationPath = "/";
        uint256 _tokenTier = tokenTier[_tokenId].tier;
        if (_tokenTier == 0) {
            generationPath = "dagorian/";
        } else if (_tokenTier == 1) {
            generationPath = "hoplite/";
        } else if (_tokenTier == 2) {
            generationPath = "periclesia/";
        }

        return bytes(cid).length > 0
        ? string(
            abi.encodePacked(
                cid, 
                generationPath, 
                tokenId, 
                ".json"
            )
        ) : "";    
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }
}
