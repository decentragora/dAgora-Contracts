# dAgoraMemberships

This contract is used to manage the memberships and access of DecentrAgora's tools

## Membership

```solidity
struct Membership {
  uint8 tier;
}
```

## Tier

```solidity
enum Tier {
  ECCLESIAE,
  DAGORIAN,
  HOPLITE,
  PERICLESIA
}
```

## cid

```solidity
string cid
```

The storage location of the membership metadata.

## paused

```solidity
bool paused
```

Used to pause and unpause the contract.

## DAI

```solidity
address DAI
```

The address of DAI token.

## USDC

```solidity
address USDC
```

The address of USDC token.

## dAgoraTreasury

```solidity
address dAgoraTreasury
```

DecentrAgora's multisig address.

## GRACE_PERIOD

```solidity
uint256 GRACE_PERIOD
```

Adds a extra day to expiring memberships.

## rewardedRole

```solidity
uint96 rewardedRole
```

## periclesiaPrice

```solidity
uint256 periclesiaPrice
```

The price of periclesia tier.

## hoplitePrice

```solidity
uint256 hoplitePrice
```

The price of hoplite tier.

## dAgorianPrice

```solidity
uint256 dAgorianPrice
```

The price of dagorian tier.

## ecclesiaePrice

```solidity
uint256 ecclesiaePrice
```

The price of ecclesia tier.

## monthlyPrice

```solidity
uint256 monthlyPrice
```

The Membership fee per month

## discountRate

```solidity
uint256 discountRate
```

Discount rate given to members who pay for a year in advance

## tokenTier

```solidity
mapping(uint256 => struct dAgoraMemberships.Membership) tokenTier
```

Token tiers mapped to individual token Ids.

## expires

```solidity
mapping(uint256 => uint256) expires
```

Token Ids mapped to their expiration date.

## tokenIndexedToOwner

```solidity
mapping(uint256 => address) tokenIndexedToOwner
```

Token Ids mapped to their Owner.

## claimed

```solidity
mapping(address => bool) claimed
```

Tracks if a address has minted or not.

## MembershipMinted

```solidity
event MembershipMinted(address _to, uint256 _tokenId, struct dAgoraMemberships.Membership tier, uint256 duration)
```

Event emitted when a membership is purchased.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _to | address | The address of the purchaser. |
| _tokenId | uint256 | The id of the purchased membership. |
| tier | struct dAgoraMemberships.Membership | The tier of the purchased membership. |
| duration | uint256 | The duration of the purchased membership. |

## MembershipRenewed

```solidity
event MembershipRenewed(uint256 tokenId, uint256 duration)
```

Event emitted when a membership is extended.

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The id of the extended membership. |
| duration | uint256 | The duration of the extended membership. |

## MembershipUpgraded

```solidity
event MembershipUpgraded(uint256 tokenId, uint256 oldTier, struct dAgoraMemberships.Membership tier)
```

Event emitted when a membership tier is upgraded

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The id of the upgraded membership. |
| oldTier | uint256 | The old tier of the upgraded membership. |
| tier | struct dAgoraMemberships.Membership | The new tier of the upgraded membership. |

## MembershipCancelled

```solidity
event MembershipCancelled(uint256 tokenId)
```

Event emitted when a membership is cancelled.

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The id of the cancelled membership. |

## MembershipExpired

```solidity
event MembershipExpired(uint256 tokenId)
```

Event emitted when a membership is expired.

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The id of the expired membership. |

## constructor

```solidity
constructor(string _cid, address _DAI, address _USDC, address _dAgoraTreasury, string guildId, uint96 _rewardedRole, address linkToken, address oracleAddress, bytes32 jobId, uint256 oracleFee) public
```

Sets the contracts variables.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _cid | string | The storage location of the membership metadata. |
| _DAI | address | The address of DAI token. |
| _USDC | address | The address of USDC token. |
| _dAgoraTreasury | address | DecentrAgora's multisig address. |
| guildId | string | The Id of the guild, the oracle interacts with. |
| _rewardedRole | uint96 | The role that is checked by oracle for free membership. |
| linkToken | address | The address of the LINK token. |
| oracleAddress | address | The address of the oracle. |
| jobId | bytes32 | The Id of the job, the oracle interacts with. |
| oracleFee | uint256 | The fee the oracle charges for a request. |

## isPaused

```solidity
modifier isPaused()
```

Checks if the contract is paused.

## isNotMember

```solidity
modifier isNotMember()
```

Checks if users address has already minted or not.

## correctPayment

```solidity
modifier correctPayment(address _ERC20)
```

checks the transfer amount of Stable coins for membership.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _ERC20 | address | The address of the stablecoin used to purchase membership. |

## durationCheck

```solidity
modifier durationCheck(uint256 duration)
```

Checks new duration amount is greater than 0 and less than 12.

| Name | Type | Description |
| ---- | ---- | ----------- |
| duration | uint256 | The duration of the membership in months. |

## isExpiredSoon

```solidity
modifier isExpiredSoon(uint256 tokenId)
```

Checks if the tokenId membership is expiring soon.

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The id of the membership. |

## onlyController

```solidity
modifier onlyController(uint256 _tokenId)
```

Checks that the msg.sender is the tokenId owner

_Modifier for functions
Used on funcs where we only want token owner to interact
example being a token owner can renew a token but not a random user._

## mintdAgoraianTier

```solidity
function mintdAgoraianTier(uint96 _durationInMonths, address _ERC20) public
```

Mints a DAgorian membership for the msg.sender.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _durationInMonths | uint96 | The duration of the membership in months. |
| _ERC20 | address | The address of the stablecoin used to purchase membership. |

## mintHoptileTier

```solidity
function mintHoptileTier(uint96 _durationInMonths, address _ERC20) public
```

Mints a Hoptile Tier membership for the msg.sender.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _durationInMonths | uint96 | The duration of the membership in months. |
| _ERC20 | address | The address of the stablecoin used to purchase membership. |

## mintPericlesiaTier

```solidity
function mintPericlesiaTier(uint96 _durationInMonths, address _ERC20) public
```

Mints a Periclesia Tier membership for the msg.sender.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _durationInMonths | uint96 | The duration of the membership in months. |
| _ERC20 | address | The address of the stablecoin used to purchase membership. |

## freeClaim

```solidity
function freeClaim() public
```

Sends request to oracle to mint Ecclesia Tier membership for the msg.sender.

## fulfillClaim

```solidity
function fulfillClaim(bytes32 requestId, uint256 access) public
```

Mints a Ecclesia Tier membership for the msg.sender, if checks pass.

| Name | Type | Description |
| ---- | ---- | ----------- |
| requestId | bytes32 | The address of the user. |
| access | uint256 | The id of the membership. |

## renewMembership

```solidity
function renewMembership(uint256 _tokenId, uint256 _newDuration, address _ERC20) public
```

Renews time of a membership for the msg.sender.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The id of the membership. |
| _newDuration | uint256 | The new added duration of the membership in months. |
| _ERC20 | address | The address of the stablecoin used to purchase time for membership. |

## upgradeMemebership

```solidity
function upgradeMemebership(uint256 _tokenId, struct dAgoraMemberships.Membership newTier, address _ERC20) public
```

Upgrades a membership tier if msg.sender is owner of the token.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The id of the membership. |
| newTier | struct dAgoraMemberships.Membership | The new tier of the membership. |
| _ERC20 | address | The address of the stablecoin used to purchase time for membership. |

## cancelMembership

```solidity
function cancelMembership(uint256 _tokenId) public
```

Cancels a membership if msg.sender is owner of the token.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The id of the membership to be cancelled. |

## giftMembership

```solidity
function giftMembership(address _to, uint96 _durationInMonths, struct dAgoraMemberships.Membership tier) public
```

Allows contract owner to gift a membership to a address.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _to | address | The address of the receiver. |
| _durationInMonths | uint96 | The duration of the membership in months. |
| tier | struct dAgoraMemberships.Membership | The tier of the gifted membership. |

## giftUpgrade

```solidity
function giftUpgrade(uint256 _tokenId, struct dAgoraMemberships.Membership newTier) public
```

Allows contract owner to gift a upgrade for an existing membership.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The id of the membership to be upgraded. |
| newTier | struct dAgoraMemberships.Membership | The new tier of the membership. |

## addTimeForMembership

```solidity
function addTimeForMembership(uint256 _tokenId, uint96 _durationInMonths) public
```

Allows contract owner to gift a renewal for an existing membership.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The id of the membership to be renewed. |
| _durationInMonths | uint96 | The new added duration of the membership in months. |

## setUSDCAddress

```solidity
function setUSDCAddress(address _USDC) public
```

Allows contract owner to set the USDC contract address.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _USDC | address | The address of the USDC contract. |

## setDAIAddress

```solidity
function setDAIAddress(address _DAI) public
```

Allows contract owner to set the DAI contract address.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _DAI | address | The address of the DAI contract. |

## togglePaused

```solidity
function togglePaused() external
```

Allows contract owner to change contracts paused state.

## setRewardedRole

```solidity
function setRewardedRole(uint96 _newRole) public
```

Allows contract owner to change the rewardedRole.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newRole | uint96 | The new rewardedRole. |

## setDiscountRate

```solidity
function setDiscountRate(uint256 _discountRate) public
```

Allows contract owner to change the discountRate

| Name | Type | Description |
| ---- | ---- | ----------- |
| _discountRate | uint256 | The new discount rate. |

## setMonthlyPrice

```solidity
function setMonthlyPrice(uint256 _monthlyPrice) public
```

Allows contract owner to change the monthly price of membership.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _monthlyPrice | uint256 | The new monthly price of membership. |

## setdAgorianPrice

```solidity
function setdAgorianPrice(uint256 _dAgorianPrice) public
```

Allows contract owner to change the dAgorian tier price.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _dAgorianPrice | uint256 | The new dAgorian tier price. |

## setHoplitePrice

```solidity
function setHoplitePrice(uint256 _hoplitePrice) public
```

Allows contract owner to change the hoplite tier price.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _hoplitePrice | uint256 | The new hoplite tier price. |

## setPericlesiaPrice

```solidity
function setPericlesiaPrice(uint256 _periclesiaPrice) public
```

Allows contract owner to change the periclesia tier price.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _periclesiaPrice | uint256 | The new periclesia tier price. |

## setdAgoraTreasury

```solidity
function setdAgoraTreasury(address _dAgoraTreasury) public
```

Allows contract owner to set the dAgoraTreasury address.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _dAgoraTreasury | address | The address of the dAgoraTreasury. |

## setGuildId

```solidity
function setGuildId(string _guildId) public
```

Allows contract owner to set the GuildId.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _guildId | string | The string of the GuildId. |

## emergWithdrawal

```solidity
function emergWithdrawal() public
```

Allows contract owner to withdraw Ether sent to contract.

## emergERC20Withdrawal

```solidity
function emergERC20Withdrawal(address _ERC20) public
```

Allows contract owner to withdraw ERC20 tokens sent to contract.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _ERC20 | address | The address of the ERC20 token to withdraw. |

## isValidMembership

```solidity
function isValidMembership(uint256 _tokenId) public view returns (bool)
```

Checks if a tokenId is a vaild member.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The id of the membership to check. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | Boolean based off membership expiry. |

## membershipExpiresIn

```solidity
function membershipExpiresIn(uint256 _tokenId) public view returns (uint256)
```

Check when a tokenId expires.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The id of the membership to check. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The timestamp of when the membership expires. |

## checkTokenTier

```solidity
function checkTokenTier(uint256 _tokenId) external view returns (uint256)
```

Check the tier of a tokenId.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The id of the membership to check. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The tier of the membership. |

## checkTokenIndexedToOwner

```solidity
function checkTokenIndexedToOwner(uint256 _tokenId) external view returns (address)
```

Check the owner of a tokenId.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The id of the membership to check. |

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The owner of the membership. |

## tokenURI

```solidity
function tokenURI(uint256 _tokenId) public view virtual returns (string)
```

## _startTokenId

```solidity
function _startTokenId() internal view virtual returns (uint256)
```

_Returns the starting token ID.
To change the starting token ID, please override this function._

