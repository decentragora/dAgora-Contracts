# Solidity API

## DagoraMembershipsV1

This contract manages the memberships for the Dagora platform.

_This contract is upgradeable in order to add new features._

### Tiers

```solidity
enum Tiers {
  Ecclesia,
  Dagorian,
  Hoplite,
  Perclesian
}
```
### Membership

```solidity
struct Membership {
  uint8 tier;
  address member;
  uint256 tokenId;
  uint256 expiration;
}
```
### baseURI

```solidity
string baseURI
```

Base URI for the token metadata.

### isPaused

```solidity
bool isPaused
```

Boolean to check if the contract is paused.

### _isInitialized

```solidity
bool _isInitialized
```

Boolean to check if the contract has been initialized.

### dagoraTreasury

```solidity
address dagoraTreasury
```

Address of the dagora treasury.

### DAI

```solidity
address DAI
```

Address of the DAI token.

### proxyImplementation

```solidity
address proxyImplementation
```

Address of the Proxy contract.

### ecclesiaPrice

```solidity
uint256 ecclesiaPrice
```

The price of the Ecclesia membership.

### ecclesiaRenewPrice

```solidity
uint256 ecclesiaRenewPrice
```

The price of the Ecclesia membership renewal.

### dagorianPrice

```solidity
uint256 dagorianPrice
```

The price of the dAgorian membership.

### dagoraRenewPrice

```solidity
uint256 dagoraRenewPrice
```

The price of the dAgorian membership renewal.

### hoplitePrice

```solidity
uint256 hoplitePrice
```

The price of the Hoplite membership.

### hopliteRenewPrice

```solidity
uint256 hopliteRenewPrice
```

The price of the Hoplite membership renewal.

### percelsiaPrice

```solidity
uint256 percelsiaPrice
```

The price of the Perclesian membership.

### percelsiaRenewPrice

```solidity
uint256 percelsiaRenewPrice
```

The price of the Perclesian membership renewal.

### GRACE_PERIOD

```solidity
uint256 GRACE_PERIOD
```

The grace period for renewing a membership.

### discount

```solidity
uint256 discount
```

The discount for renewing a membership for 12 months.

### MembershipPurchased

```solidity
event MembershipPurchased(address member, uint256 tokenId, uint8 tier, uint256 expiration)
```

The event emitted when a membership is purchased.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| member | address | the address of the member |
| tokenId | uint256 | the tokenId of the membership |
| tier | uint8 | the tier of the membership |
| expiration | uint256 | the expiration of the membership |

### FreeMembershipClaimed

```solidity
event FreeMembershipClaimed(address member, uint256 tokenId, uint8 tier, uint256 expiration)
```

The event emitted when a free membership is claimed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| member | address | the address of the member |
| tokenId | uint256 | the tokenId of the membership |
| tier | uint8 | the tier of the membership |
| expiration | uint256 | the expiration of the membership |

### MembershipUpgraded

```solidity
event MembershipUpgraded(address member, uint256 tokenId, uint8 oldTier, enum DagoraMembershipsV1.Tiers newTier)
```

The event emitted when a membership is upgraded.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| member | address | the address of the member |
| tokenId | uint256 | the tokenId of the membership |
| oldTier | uint8 | the old tier of the membership |
| newTier | enum DagoraMembershipsV1.Tiers | the new tier of the membership |

### MembershipRenewed

```solidity
event MembershipRenewed(address member, uint256 tokenId, uint256 expiration)
```

The event emitted when a membership is renewed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| member | address | the address of the member |
| tokenId | uint256 | the tokenId of the membership |
| expiration | uint256 | the expiration of the membership |

### MembershipGifted

```solidity
event MembershipGifted(address member, uint256 tokenId, uint8 tier, uint256 expiration)
```

The event emitted when a membership is claimed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| member | address | the address of the member |
| tokenId | uint256 | the tokenId of the membership |
| tier | uint8 | the tier of the membership |
| expiration | uint256 | the expiration of the membership |

### MembershipCanceled

```solidity
event MembershipCanceled(address member, uint256 tokenId, uint256 expiration)
```

The event emitted when a membership is canceled.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| member | address | the address of the member |
| tokenId | uint256 | the tokenId of the membership |
| expiration | uint256 | the expiration of the membership |

### DelegateRemoved

```solidity
event DelegateRemoved(address member, uint256 tokenId, address delegatee)
```

The event emitted when a delegate is removed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| member | address | the address of the member |
| tokenId | uint256 | the tokenId of the membership |
| delegatee | address | the address of the delegatee |

### DelegateAdded

```solidity
event DelegateAdded(address member, uint256 tokenId, address delegatee)
```

The event emitted when a delegate is added.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| member | address | the address of the member |
| tokenId | uint256 | the tokenId of the membership |
| delegatee | address | the address of the delegatee |

### DelegateSwapped

```solidity
event DelegateSwapped(address member, uint256 tokenId, address oldDelegatee, address newDelegatee)
```

The event emitted when a delegate is swapped.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| member | address | the address of the member |
| tokenId | uint256 | the tokenId of the membership |
| oldDelegatee | address | the address of the old delegatee |
| newDelegatee | address | the address of the new delegatee |

### memberships

```solidity
mapping(uint256 => struct DagoraMembershipsV1.Membership) memberships
```

mapping that stores the membership details.

### experation

```solidity
mapping(uint256 => uint256) experation
```

mapping that stores a tokenids expiration.

### claimed

```solidity
mapping(address => bool) claimed
```

mapping that sets true if a membership is claimed.

### tokenDelegates

```solidity
mapping(uint256 => address[]) tokenDelegates
```

mapping that stores the delegates of a tokenId

### initialize

```solidity
function initialize(string _name, string _symbol, string baseURI_, address _dagoraTreasury, address _DAI) public
```

The initializer function that replaces the constructor.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _name | string | the name of the token |
| _symbol | string | the symbol of the token |
| baseURI_ | string | the base URI for the token metadata |
| _dagoraTreasury | address | the address of the dagora treasury |
| _DAI | address | the address of the DAI token. |

### isNotPaused

```solidity
modifier isNotPaused()
```

Modifier to check if the contract is paused or, not paused.

### isNotMember

```solidity
modifier isNotMember()
```

Modifier to check if the msg.sender has already claimed their membership.

### isPerclesian

```solidity
modifier isPerclesian(uint256 tokenId)
```

Modifier to check if the tokenId tier is Perclesian.

### _isValidMembership

```solidity
modifier _isValidMembership(uint256 _tokenId)
```

Modifier to check if the membership is not expired.

### durationCheck

```solidity
modifier durationCheck(uint256 _dur)
```

Modifier to check if the duration is valid.

_duration must be greater than 0 and less than 12 months._

### onlyController

```solidity
modifier onlyController(uint256 _tokenId)
```

Modifier to check if the msg.sender is the owner of the membership.

### onlyDelegateeAndOwner

```solidity
modifier onlyDelegateeAndOwner(uint256 _tokenId)
```

Modifier to check if the msg.sender is the owner or delegatee of the membership.

### mintMembership

```solidity
function mintMembership(uint8 _tier, uint96 _durationInMonths, uint256 _deadline, address _proxy, uint8 _v, bytes32 _r, bytes32 _s) public
```

Function to mint a membership.

_The permit signature is used to transfer the DAI from the msg.sender to the dAgoraTreasury._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tier | uint8 | The tier of the membership. (Perclesian, Hoplite, dAgorian, Ecclesia) |
| _durationInMonths | uint96 | The duration of the membership in months. (1-12) |
| _deadline | uint256 | The deadline for the permit signature. |
| _proxy | address | The address of the proxy contract. |
| _v | uint8 | The v value of the permit signature. |
| _r | bytes32 | The r value of the permit signature. |
| _s | bytes32 | The s value of the permit signature. |

### freeMint

```solidity
function freeMint() public
```

Function to claim a ecclesia membership.

### renewMembership

```solidity
function renewMembership(uint96 _durationInMonths, uint256 _tokenId, uint256 _deadline, address _proxy, uint8 _v, bytes32 _r, bytes32 _s) external
```

Function to Renew a membership.

_The permit signature is used to transfer the DAI from the msg.sender to the dAgoraTreasury._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _durationInMonths | uint96 | The duration of the membership in months. (1-12) |
| _tokenId | uint256 | The tokenId of the membership. |
| _deadline | uint256 | The deadline for the permit signature. |
| _proxy | address | The address of the proxy contract. |
| _v | uint8 | The v value of the permit signature. |
| _r | bytes32 | The r value of the permit signature. |
| _s | bytes32 | The s value of the permit signature. |

### upgradeMembership

```solidity
function upgradeMembership(uint8 newTier, uint8 oldTier, uint256 tokenId, uint256 deadline, address _proxy, uint8 v, bytes32 r, bytes32 s) public
```

Function to upgrade a membership.

_The permit signature is used to transfer the DAI from the msg.sender to the dAgoraTreasury._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| newTier | uint8 | The new tier of the membership. |
| oldTier | uint8 | The old tier of the membership. |
| tokenId | uint256 | The tokenId of the membership. |
| deadline | uint256 | The deadline for the permit signature. |
| _proxy | address | The address of the proxy contract. |
| v | uint8 | The v value of the permit signature. |
| r | bytes32 | The r value of the permit signature. |
| s | bytes32 | The s value of the permit signature. |

### cancelMembership

```solidity
function cancelMembership(uint256 tokenId) public
```

Function to cancel a membership.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The tokenId of the membership. |

### addDelegate

```solidity
function addDelegate(address _delegatee, uint256 _tokenId) external
```

Function to add a delegate to a membership.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _delegatee | address | The address of the delegatee. |
| _tokenId | uint256 | The tokenId of the membership. |

### removeDelegate

```solidity
function removeDelegate(address _delegatee, uint256 _tokenId, uint8 slot) public
```

Function to remove a delegate from a membership.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _delegatee | address | The address of the delegatee. |
| _tokenId | uint256 | The tokenId of the membership. |
| slot | uint8 | The slot of the delegatee. |

### swapDelegate

```solidity
function swapDelegate(uint256 _tokenId, address oldDelegate, address newDelegate) public
```

Function to swap a delegate from a membership.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The tokenId of the membership. |
| oldDelegate | address | The address of the old delegate. |
| newDelegate | address | The address of the new delegate. |

### giftMembership

```solidity
function giftMembership(address to, uint8 tier, uint96 durationInMonths) external
```

only owner function to gift membership to an address, that address must not already have a membership.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address to gift membership to. |
| tier | uint8 | The tier of the membership. |
| durationInMonths | uint96 | The duration of the membership in months. |

### giftUpgrade

```solidity
function giftUpgrade(uint256 tokenId, uint8 tier) external
```

only owner function to gift a upgrade to an existing membership.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The tokenId of the membership. |
| tier | uint8 | The tier of the membership. |

### giftExtension

```solidity
function giftExtension(uint256 tokenId, uint96 durationInMonths) external
```

only owner function to gift a extension to an existing membership.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The tokenId of the membership. |
| durationInMonths | uint96 | The duration of the membership in months. |

### togglePaused

```solidity
function togglePaused() external
```

Function to pause the contract.

_Only owner can call this function._

### setBaseURI

```solidity
function setBaseURI(string baseURI_) external
```

Function to set the baseURI.

_Only owner can call this function._

### setDiscount

```solidity
function setDiscount(uint256 _discount) external
```

Function to set the Discount price.

_Only owner can call this function._

### setPercelsiaPrice

```solidity
function setPercelsiaPrice(uint256 _price) external
```

Function to set the price of a Percelsia tier membership.

_Only owner can call this function._

### setHoplitePrice

```solidity
function setHoplitePrice(uint256 _price) external
```

Function to set the price of a Hoplite tier membership.

_Only owner can call this function._

### setDagorianPrice

```solidity
function setDagorianPrice(uint256 _price) external
```

Function to set the price of a Dagorian tier membership.

_Only owner can call this function._

### setEcclesiaPrice

```solidity
function setEcclesiaPrice(uint256 _price) external
```

Function to set the price of a Ecclesia tier membership.

_Only owner can call this function._

### setPercelsiaRenewPrice

```solidity
function setPercelsiaRenewPrice(uint256 _price) external
```

Function to set the price of a Percelsia tier membership renewal.

_Only owner can call this function._

### setHopliteRenewPrice

```solidity
function setHopliteRenewPrice(uint256 _price) external
```

Function to set the price of a Hoplite tier membership renewal.

_Only owner can call this function._

### setDagorianRenewPrice

```solidity
function setDagorianRenewPrice(uint256 _price) external
```

Function to set the price of a Dagorian tier membership renewal.

_Only owner can call this function._

### setDagoraTreasury

```solidity
function setDagoraTreasury(address _dagoraTreasury) external
```

Function to set the price of a Ecclesia tier membership renewal.

_Only owner can call this function._

### setProxyAddress

```solidity
function setProxyAddress(address _proxyAddress) external
```

Function to set the address of the proxy contract.

_Only owner can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _proxyAddress | address | The address of the proxy contract. |

### withdrawERC20

```solidity
function withdrawERC20(address _token) external
```

Function to withdraw ERC20 tokens from the contract.

_Only owner can call this function._

### withdrawETH

```solidity
function withdrawETH() external
```

Function to withdraw ETH from the contract.

_Only owner can call this function._

### getMembership

```solidity
function getMembership(uint256 _tokenId) external view returns (struct DagoraMembershipsV1.Membership)
```

Function to get a tokenId membership details.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The tokenId of the membership. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct DagoraMembershipsV1.Membership | Membership struct. |

### getMembershipTier

```solidity
function getMembershipTier(uint256 _tokenId) external view returns (uint8)
```

Function to get a tokenId membership tier.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The tokenId of the membership. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint8 | uint8 tier. |

### getExpiration

```solidity
function getExpiration(uint256 _tokenId) external view returns (uint256)
```

Function to get a tokenId membership expiration.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The tokenId of the membership. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | uint256 expiration. |

### isValidMembership

```solidity
function isValidMembership(uint256 _tokenId) external view returns (bool)
```

Function to get a tokenId membership expiration.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The tokenId of the membership. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | bool isValid. |

### addressTokenIds

```solidity
function addressTokenIds(address _owner) external view returns (uint256 _tokenId)
```

### getTokenDelegates

```solidity
function getTokenDelegates(uint256 _tokenId) external view returns (address[])
```

Function to get a tokenIds delegates.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The tokenId of the membership. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address[] | address[] delegates. |

### isOwnerOrDelegate

```solidity
function isOwnerOrDelegate(uint256 tokenId, address addrs) public view returns (bool _isOwnerOrDelegate)
```

Function to check is a address is a owner or delegate of a tokenid

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The tokenId of the membership. |
| addrs | address | The address to check. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| _isOwnerOrDelegate | bool | bool. |

### getMintPrice

```solidity
function getMintPrice(uint96 _durationInMonths, uint8 _tier) public view returns (uint256 _price)
```

Function to get the mint price of a membership

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _durationInMonths | uint96 | The duration of the membership in months. |
| _tier | uint8 | The tier of the membership. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| _price | uint256 | The price of the membership. |

### _getUpgradePrice

```solidity
function _getUpgradePrice(uint256 tokenId, uint8 oldTier, uint8 newTier) public view returns (uint256 _price)
```

Function to get the upgrade price of a membership

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The tokenId of the membership. |
| oldTier | uint8 | The old tier of the membership. |
| newTier | uint8 | The new tier of the membership. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| _price | uint256 | The price of the membership. |

### getRenewalPrice

```solidity
function getRenewalPrice(uint96 _newDuration, uint8 currentTier) public view returns (uint256 _price)
```

Function to get the renewal price of a membership

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _newDuration | uint96 | The new duration of the membership. |
| currentTier | uint8 | The current tier of the membership. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| _price | uint256 | The price of the membership. |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) public view returns (string)
```

Returns a tokenIds URI.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The tokenId of the membership. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string | The URI of the token. |

### _isDelegatee

```solidity
function _isDelegatee(uint256 _tokenId, address _delegate) internal view returns (bool)
```

Internal function to check if an address is a delegate of a specfic tokenId.

_This function is used in the isOwnerOrDelegate function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The tokenId of the membership. |
| _delegate | address | The address to check. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if the address is a delegate of the tokenId. False if not. |

### _startTokenId

```solidity
function _startTokenId() internal pure returns (uint256)
```

Internal function to set the starting tokenId.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The starting tokenId. |

### _getNextTokenId

```solidity
function _getNextTokenId() internal view returns (uint256)
```

Internal function to get the next tokenId

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The next tokenId. |

### _beforeTokenTransfers

```solidity
function _beforeTokenTransfers(address from, address to, uint256 tokenId, uint256 quantity) internal
```

Internal override function to enable soulbound memberships.

_if sender is not address(0), then transfer is not allowed._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | the address of the sender. |
| to | address | the address of the receiver. |
| tokenId | uint256 | the tokenId. |
| quantity | uint256 | the quantity. |

### _contains

```solidity
function _contains(uint256 _tokenId, address user) internal view returns (bool)
```

Internal function to check if an address is a contained in a specfic tokenId.

_This function is used in the isOwnerOrDelegate function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenId | uint256 | The tokenId of the membership. |
| user | address | The address to check. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if the address is a delegate of the tokenId. False if not. |

