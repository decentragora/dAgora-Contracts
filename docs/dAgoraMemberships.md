# dAgoraMemberships

DecentrAgora Memberships

This contract is used to manage the memberships and access of DecentrAgora's tools

## Variables

### cid

```solidity
string cid
```

The storage location of the membership metadata.

### paused

```solidity
bool paused
```

Used to pause and unpause the contract.

### DAI

```solidity
address DAI
```

The address of DAI token.

### dAgoraTreasury

```solidity
address dAgoraTreasury
```

DecentrAgora's multisig address.

### rewardedRole

```solidity
uint96 rewardedRole
```

### GRACE_PERIOD

```solidity
uint256 GRACE_PERIOD
```

Adds a extra day to expiring memberships.

### periclesiaPrice

```solidity
uint256 periclesiaPrice
```

The price of periclesia tier.

### hoplitePrice

```solidity
uint256 hoplitePrice
```

The price of hoplite tier.

### dAgorianPrice

```solidity
uint256 dAgorianPrice
```

The price of dagorian tier.

### ecclesiaePrice

```solidity
uint256 ecclesiaePrice
```

The price of ecclesia tier.

### monthlyPrice

```solidity
uint256 monthlyPrice
```

The Membership fee per month

### discountRate

```solidity
uint256 discountRate
```

Discount rate given to members who pay for a year in advance

### expires

```solidity
mapping(uint256 => uint256) expires
```

Token Ids mapped to their expiration date.

### tokenIndexedToOwner

```solidity
mapping(uint256 => address) tokenIndexedToOwner
```

Token Ids mapped to their Owner.

### claimed

```solidity
mapping(address => bool) claimed
```

Tracks if a address has minted or not.

### _tokenDelegates

```solidity
mapping(uint256 => address[]) _tokenDelegates
```

Tracks delegated addresses for a tokenId.
TokenId must be Percelisia tier.

## Functions

### constructor

```solidity
constructor(
    string _cid,
    address _DAI,
    address _dAgoraTreasury,
    string guildId,
    uint96 _rewardedRole,
    address linkToken,
    address oracleAddress,
    bytes32 jobId,
    uint256 oracleFee
) 
```

Sets the contracts variables.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_cid` | string | The storage location of the membership metadata. |
| `_DAI` | address | The address of DAI token. |
| `_dAgoraTreasury` | address | DecentrAgora's multisig address. |
| `guildId` | string | The Id of the guild, the oracle interacts with. |
| `_rewardedRole` | uint96 | The role that is checked by oracle for free membership. |
| `linkToken` | address | The address of the LINK token. |
| `oracleAddress` | address | The address of the oracle. |
| `jobId` | bytes32 | The Id of the job, the oracle interacts with. |
| `oracleFee` | uint256 | The fee the oracle charges for a request. |

### mintdAgoraianTier

```solidity
function mintdAgoraianTier(
    uint96 _durationInMonths,
    uint256 _deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
) public
```

Mints a DAgorian membership for the msg.sender using ERC20Permit.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_durationInMonths` | uint96 | The duration of the membership in months. |
| `_deadline` | uint256 | The deadline for the transaction. |
| `v` | uint8 | The v value of the signature. |
| `r` | bytes32 | The r value of the signature. |
| `s` | bytes32 | The s value of the signature. |

### mintHoptileTier

```solidity
function mintHoptileTier(
    uint96 _durationInMonths,
    uint256 _deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
) public
```

Mints a Hoptile Tier membership for the msg.sender using ERC20Permit.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_durationInMonths` | uint96 | The duration of the membership in months. |
| `_deadline` | uint256 | The deadline for the transaction. |
| `v` | uint8 | The v value of the signature. |
| `r` | bytes32 | The r value of the signature. |
| `s` | bytes32 | The s value of the signature. |

### mintPericlesiaTier

```solidity
function mintPericlesiaTier(
    uint96 _durationInMonths,
    uint256 _deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
) public
```

Mints a Periclesia Tier membership for the msg.sender using ERC20Permit.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_durationInMonths` | uint96 | The duration of the membership in months. |
| `_deadline` | uint256 | The deadline for the transaction. |
| `v` | uint8 | The v value of the signature. |
| `r` | bytes32 | The r value of the signature. |
| `s` | bytes32 | The s value of the signature. |

### freeClaim

```solidity
function freeClaim() public
```

Sends request to oracle to mint Ecclesia Tier membership for the msg.sender.

### fulfillClaim

```solidity
function fulfillClaim(
    bytes32 requestId,
    uint256 access
) public
```

Mints a Ecclesia Tier membership for the msg.sender, if checks pass.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `requestId` | bytes32 | The address of the user. |
| `access` | uint256 | The id of the membership. |

### renewMembership

```solidity
function renewMembership(
    uint256 _tokenId,
    uint256 _newDuration,
    uint256 _deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
) public
```

Renews time of a membership for tokenId Using ERC20 Permit for Transaction.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 | The id of the membership. |
| `_newDuration` | uint256 | The new added duration of the membership in months. |
| `_deadline` | uint256 | The deadline for the transaction. |
| `v` | uint8 | The v value of the signature. |
| `r` | bytes32 | The r value of the signature. |
| `s` | bytes32 | The s value of the signature. |

### upgradeMemebership

```solidity
function upgradeMemebership(
    uint256 _tokenId,
    struct dAgoraMemberships.Membership newTier,
    uint256 _deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
) public
```

Upgrades a membership tier if tier isn't already fully upgraded to the highest tier.

Only the owner of the membership can upgrade it.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 | The id of the membership. |
| `newTier` | struct dAgoraMemberships.Membership | The new tier of the membership. |
| `_deadline` | uint256 | The deadline for the transaction. |
| `v` | uint8 | The v value of the signature. |
| `r` | bytes32 | The r value of the signature. |
| `s` | bytes32 | The s value of the signature. |

### cancelMembership

```solidity
function cancelMembership(
    uint256 _tokenId
) public
```

Cancels a membership if msg.sender is owner of the token.

Only the owner of the membership can cancel it.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 | The id of the membership to be cancelled. |

### giftMembership

```solidity
function giftMembership(
    address _to,
    uint96 _durationInMonths,
    struct dAgoraMemberships.Membership tier
) public
```

Allows contract owner to gift a membership to a address.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_to` | address | The address of the receiver. |
| `_durationInMonths` | uint96 | The duration of the membership in months. |
| `tier` | struct dAgoraMemberships.Membership | The tier of the gifted membership. |

### giftUpgrade

```solidity
function giftUpgrade(
    uint256 _tokenId,
    struct dAgoraMemberships.Membership newTier
) public
```

Allows contract owner to gift a upgrade for an existing membership.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 | The id of the membership to be upgraded. |
| `newTier` | struct dAgoraMemberships.Membership | The new tier of the membership. |

### addTimeForMembership

```solidity
function addTimeForMembership(
    uint256 _tokenId,
    uint96 _durationInMonths
) public
```

Allows contract owner to gift a renewal for an existing membership.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 | The id of the membership to be renewed. |
| `_durationInMonths` | uint96 | The new added duration of the membership in months. |

### addDelegatee

```solidity
function addDelegatee(
    uint256 _tokenId,
    address _delegatee
) public
```

Allows a membership owner to add delegates to their membership.

Tokens Tier must be Precisian to add delegates.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 | The id of the membership. |
| `_delegatee` | address | The addresses of the delegatee. |

### swapDelegate

```solidity
function swapDelegate(
    uint256 _tokenId,
    address _oldDelegatee,
    address _newDelegatee
) public
```

Allows a membership owner to swap a delegatee for another delegatee.

Tokens Tier must be Precisian to swap delegates.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 | The id of the membership. |
| `_oldDelegatee` | address | The addresses of the delegatee. |
| `_newDelegatee` | address | The addresses of the new delegatee. |

### removeDelegatee

```solidity
function removeDelegatee(
    uint256 _tokenId,
    address _delegatee,
    uint8 _slot
) public
```

Allows a membership owner to remove a delegatee from their membership.

Tokens Tier must be Precisian to remove delegates.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 | The id of the membership. |
| `_delegatee` | address | The addresses of the delegatee. |
| `_slot` | uint8 | of the delegatee to be removed. |

### togglePaused

```solidity
function togglePaused() external
```

Allows contract owner to change contracts paused state.

### setRewardedRole

```solidity
function setRewardedRole(
    uint96 _newRole
) public
```

Allows contract owner to change the rewardedRole.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newRole` | uint96 | The new rewardedRole. |

### setDiscountRate

```solidity
function setDiscountRate(
    uint256 _discountRate
) public
```

Allows contract owner to change the discountRate

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_discountRate` | uint256 | The new discount rate. |

### setMonthlyPrice

```solidity
function setMonthlyPrice(
    uint256 _monthlyPrice
) public
```

Allows contract owner to change the monthly price of membership.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_monthlyPrice` | uint256 | The new monthly price of membership. |

### setdAgorianPrice

```solidity
function setdAgorianPrice(
    uint256 _dAgorianPrice
) public
```

Allows contract owner to change the dAgorian tier price.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_dAgorianPrice` | uint256 | The new dAgorian tier price. |

### setHoplitePrice

```solidity
function setHoplitePrice(
    uint256 _hoplitePrice
) public
```

Allows contract owner to change the hoplite tier price.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_hoplitePrice` | uint256 | The new hoplite tier price. |

### setPericlesiaPrice

```solidity
function setPericlesiaPrice(
    uint256 _periclesiaPrice
) public
```

Allows contract owner to change the periclesia tier price.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_periclesiaPrice` | uint256 | The new periclesia tier price. |

### setdAgoraTreasury

```solidity
function setdAgoraTreasury(
    address _dAgoraTreasury
) public
```

Allows contract owner to set the dAgoraTreasury address.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_dAgoraTreasury` | address | The address of the dAgoraTreasury. |

### setGuildId

```solidity
function setGuildId(
    string _guildId
) public
```

Allows contract owner to set the GuildId.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_guildId` | string | The string of the GuildId. |

### emergWithdrawal

```solidity
function emergWithdrawal() public
```

Allows contract owner to withdraw Ether sent to contract.

### emergERC20Withdrawal

```solidity
function emergERC20Withdrawal(
    address _ERC20
) public
```

Allows contract owner to withdraw ERC20 tokens sent to contract.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_ERC20` | address | The address of the ERC20 token to withdraw. |

### isValidMembership

```solidity
function isValidMembership(
    uint256 _tokenId
) public returns (bool)
```

Checks if a tokenId is a vaild member.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 | The id of the membership to check. |

#### Return Values

| Name | Type | Description |
| :--- | :--- | :---------- |
| `[0]` | bool | Boolean based off membership expiry. |
### membershipExpiresIn

```solidity
function membershipExpiresIn(
    uint256 _tokenId
) public returns (uint256)
```

Check when a tokenId expires.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 | The id of the membership to check. |

#### Return Values

| Name | Type | Description |
| :--- | :--- | :---------- |
| `[0]` | uint256 | The timestamp of when the membership expires. |
### checkTokenTier

```solidity
function checkTokenTier(
    uint256 _tokenId
) external returns (uint256)
```

Check the tier of a tokenId.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 | The id of the membership to check. |

#### Return Values

| Name | Type | Description |
| :--- | :--- | :---------- |
| `[0]` | uint256 | The tier of the membership. |
### checkTokenIndexedToOwner

```solidity
function checkTokenIndexedToOwner(
    uint256 _tokenId
) external returns (address)
```

Check the owner of a tokenId.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 | The id of the membership to check. |

#### Return Values

| Name | Type | Description |
| :--- | :--- | :---------- |
| `[0]` | address | The owner of the membership. |
### checkTokenDelegates

```solidity
function checkTokenDelegates(
    uint256 _tokenId
) external returns (address[])
```

Check all the delegatees of a tokenId.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 | The id of the membership to check. |

#### Return Values

| Name | Type | Description |
| :--- | :--- | :---------- |
| `[0]` | address[] | The delegatees addresses of the membership. |
### nonces

```solidity
function nonces(
    address owner
) public returns (uint256)
```

IERC20Permit tx count.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `owner` | address | The address of the owner of the ERC20. |

#### Return Values

| Name | Type | Description |
| :--- | :--- | :---------- |
| `[0]` | uint256 | the current nonce. |
### isOwnerOrDelegate

```solidity
function isOwnerOrDelegate(
    uint256 _tokenId,
    address _address
) public returns (bool)
```

View function to see if a address is a delegatee or owner of a tokenId.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 | The id of the membership to check. |
| `_address` | address | The address to check. |

#### Return Values

| Name | Type | Description |
| :--- | :--- | :---------- |
| `[0]` | bool | Boolean based off if the address is a delegatee or owner of the tokenId. |
### tokenURI

```solidity
function tokenURI(
    uint256 _tokenId
) public returns (string)
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 |  |

### _startTokenId

```solidity
function _startTokenId() internal returns (uint256)
```

Returns the starting token ID.
To change the starting token ID, please override this function.

### contains

```solidity
function contains(
    uint256 _tokenId,
    address user
) internal returns (bool)
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 |  |
| `user` | address |  |

## Modifiers

### isPaused

```solidity
modifier isPaused()
```

Checks if the contract is paused.

### isNotMember

```solidity
modifier isNotMember()
```

Checks if users address has already minted or not.

### durationCheck

```solidity
modifier durationCheck(uint256 duration)
```

Checks new duration amount is greater than 0 and less than 12.

| Name | Type | Description |
| ---- | ---- | ----------- |
| duration | uint256 | The duration of the membership in months. |

### isExpiredSoon

```solidity
modifier isExpiredSoon(uint256 tokenId)
```

Checks if the tokenId membership is expiring soon.

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The id of the membership. |

### onlyController

```solidity
modifier onlyController(uint256 _tokenId)
```

Checks that the msg.sender is the tokenId owner

_Modifier for functions
Used on funcs where we only want token owner to interact
example being a token owner can renew a token but not a random user._

### isPerclesia

```solidity
modifier isPerclesia(uint256 _tokenId)
```

Checks that the tokens tier is Periclesia.

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The id of the membership. |

### isDelegateOrOwner

```solidity
modifier isDelegateOrOwner(uint256 _tokenId)
```

Checks that the msg.sender is either the tokenId owner or a delegate.

_Modifier guard for delegate & owner functions_

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The id of the membership. |

## Events

### MembershipMinted

```solidity
event MembershipMinted(
    address _to,
    uint256 _tokenId,
    struct dAgoraMemberships.Membership tier,
    uint256 duration
)
```

Event emitted when a membership is purchased.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_to` | address | The address of the purchaser. |
| `_tokenId` | uint256 | The id of the purchased membership. |
| `tier` | struct dAgoraMemberships.Membership | The tier of the purchased membership. |
| `duration` | uint256 | The duration of the purchased membership. |
### MembershipRenewed

```solidity
event MembershipRenewed(
    uint256 tokenId,
    uint256 duration
)
```

Event emitted when a membership is extended.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `tokenId` | uint256 | The id of the extended membership. |
| `duration` | uint256 | The duration of the extended membership. |
### MembershipUpgraded

```solidity
event MembershipUpgraded(
    uint256 tokenId,
    uint256 oldTier,
    struct dAgoraMemberships.Membership tier
)
```

Event emitted when a membership tier is upgraded

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `tokenId` | uint256 | The id of the upgraded membership. |
| `oldTier` | uint256 | The old tier of the upgraded membership. |
| `tier` | struct dAgoraMemberships.Membership | The new tier of the upgraded membership. |
### MembershipCancelled

```solidity
event MembershipCancelled(
    uint256 tokenId
)
```

Event emitted when a membership is cancelled.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `tokenId` | uint256 | The id of the cancelled membership. |
### MembershipExpired

```solidity
event MembershipExpired(
    uint256 tokenId
)
```

Event emitted when a membership is expired.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `tokenId` | uint256 | The id of the expired membership. |

## Custom types

### Membership

```solidity
struct Membership {
  uint8 tier;
}
```
### Tier

```solidity
enum Tier {
  ECCLESIAE,
  DAGORIAN,
  HOPLITE,
  PERICLESIA
}
```

