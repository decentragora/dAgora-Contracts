// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "ERC721A/ERC721A.sol";
import {RequestGuildRole} from "./RequestGuildRole.sol";
import "./IdAgoraMemberships.sol";

contract dAgoraMemberships is
    RequestGuildRole,
    IdAgoraMembership,
    ERC721A,
    Ownable,
    ReentrancyGuard
{
    struct Membership {
        uint8 tier;
    }

    enum Tier {
        ECCLESIAE,
        DAGORIAN,
        HOPLITE,
        PERICLESIA
    }

    string public cid;

    bool public paused = true;

    address public DAI;
    address public USDC;
    address public dAgoraTreasury;

    uint256 public constant GRACE_PERIOD = 86400; // 1 days in seconds

    uint96 public rewardedRole;
    uint256 public periclesiaPrice = 1000 * 10 ** 18;
    uint256 public hoplitePrice = 80 * 10 ** 18;
    uint256 public dAgorianPrice = 50 * 10 ** 18;
    uint256 public ecclesiaePrice = 0;
    uint256 public monthlyPrice = 5 * 10 ** 18;
    uint256 public discountRate = 5 * 10 ** 18;

    mapping(uint256 => Membership) private tokenTier;
    mapping(uint256 => uint256) public expires;
    mapping(uint256 => address) public tokenIndexedToOwner;
    mapping(address => bool) public claimed;

    event MembershipMinted(
        address indexed _to,
        uint256 indexed _tokenId,
        Membership tier,
        uint256 duration
    );

    event MembershipRenewed(uint256 tokenId, Membership tier, uint256 duration);
    event MembershipUpgraded(uint256 tokenId, uint256 oldTier, Membership tier);
    event MembershipCancelled(uint256 tokenId);
    event MembershipExpired(uint256 tokenId);

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
    modifier isPaused() {
        require(!paused);
        _;
    }

    modifier isNotMember() {
        require(!claimed[msg.sender], "You are already a member");
        _;
    }

    modifier correctPayment(address _ERC20) {
        require(_ERC20 == DAI || _ERC20 == USDC, "Payment must be DAI or USDC");
        _;
    }

    modifier durationCheck(uint256 duration) {
        require(
            duration > 0 && duration <= 12,
            "Membership duration must be between 1 and 12 months"
        );
        _;
    }

    modifier isExpiredSoon(uint256 tokenId) {
        require(
            block.timestamp + 30 days + GRACE_PERIOD >= expires[tokenId], 
            "Token isn't expiring soon"
        );
        _;
    }

    // @dev Modifier for functions
    // @dev Used on funcs where we only want token owner to interact
    // @dev example being a token owner can renew a token but not a random user.
    modifier onlyController(uint256 _tokenId) {
        require(
            msg.sender == tokenIndexedToOwner[_tokenId], "Not owner of token"
        );
        _;
    }

    /*////////////////////////////////////// Public Mint Functions //////////////////////////////////////////////////*/

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

    // Allows Token Owner to renew membership
    //require new time to be greater than 30days from current time
    //require new time to be less than 1 year from current time
    //require msg.sender to be tokenId owner CAN USE MODIFIER onlyController
    //require now + 5 days + GRACE_PERIOD to be greater than expires[tokenId] so token is expiring soon
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

        emit MembershipRenewed(_tokenId, tokenTier[_tokenId], expires[_tokenId]);
        expires[_tokenId] = expires[_tokenId] + (duration + GRACE_PERIOD);    
    }

    // tier 0 = 0, tier 1 = 50, tier 2 = 80, tier 3 = 1000
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

    function cancelMembership(uint256 _tokenId) public isPaused onlyController(_tokenId) nonReentrant {
        expires[_tokenId] = block.timestamp + GRACE_PERIOD;
        emit MembershipCancelled(_tokenId);
    }

    /*////////////////////////////////////// Only Owner Functions //////////////////////////////////////////////////*/

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

    function addTimeForMembership(uint256 _tokenId, uint96 _durationInMonths)
        public
        onlyOwner
        durationCheck(_durationInMonths)
        nonReentrant
    {
        uint256 duration =(_durationInMonths * 30 days);
        expires[_tokenId] = expires[_tokenId] + (duration + GRACE_PERIOD);
        emit MembershipRenewed(_tokenId, tokenTier[_tokenId], expires[_tokenId]);
    }

    function setUSDCAddress(address _USDC) public onlyOwner {
        USDC = _USDC;
    }

    function setDAIAddress(address _DAI) public onlyOwner {
        DAI = _DAI;
    }

    function togglePaused() external onlyOwner {
        paused = !paused;
    }

    function setRewardedRole(uint96 _newRole) public onlyOwner {
        rewardedRole = _newRole;
    }

    function setDiscountRate(uint256 _discountRate) public onlyOwner {
        discountRate = _discountRate;
    }

    function setMonthlyPrice(uint256 _monthlyPrice) public onlyOwner {
        monthlyPrice = _monthlyPrice;
    }

    function setdAgorianPrice(uint256 _dAgorianPrice) public onlyOwner {
        dAgorianPrice = _dAgorianPrice;
    }

    function setHoplitePrice(uint256 _hoplitePrice) public onlyOwner {
        hoplitePrice = _hoplitePrice;
    }

    function setPericlesiaPrice(uint256 _periclesiaPrice) public onlyOwner {
        periclesiaPrice = _periclesiaPrice;
    }

    function setdAgoraTreasury(address _dAgoraTreasury) public onlyOwner {
        dAgoraTreasury = _dAgoraTreasury;
    }

    function setGuildId(string memory _guildId) public onlyOwner {
        guildId = _guildId;
    }

    function emergWithdrawal() public onlyOwner {
        (bool success, ) = dAgoraTreasury.call{value: address(this).balance}("");
        require(success, "Failed to send to lead.");
    }
    
    function emergERC20Withdrawal(address _ERC20) public onlyOwner {
        uint balance = IERC20(_ERC20).balanceOf(address(this));
        require(IERC20(_ERC20).transfer(dAgoraTreasury, balance), "Failed to transfer tokens");
    }


    /*////////////////////////////////////// Public View Functions //////////////////////////////////////////////////*/

    function isValidMembership(uint256 _tokenId) public view returns (bool) {
        if (tokenTier[_tokenId].tier == 0) {
            return true;
        } else {
            return expires[_tokenId] > block.timestamp;
        }
    }

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

    function checkTokenTier(uint256 _tokenId) external view returns (uint256) {
        return tokenTier[_tokenId].tier;
    }

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
