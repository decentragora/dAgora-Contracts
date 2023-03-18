# Solidity API

## IDagoraMembershipsV1

### DAI

```solidity
function DAI() external view returns (address)
```

### GRACE_PERIOD

```solidity
function GRACE_PERIOD() external view returns (uint256)
```

### _getUpgradePrice

```solidity
function _getUpgradePrice(uint256 tokenId, uint8 oldTier, uint8 newTier) external view returns (uint256 _price)
```

### _isInitialized

```solidity
function _isInitialized() external view returns (bool)
```

### addDelegate

```solidity
function addDelegate(address _delegatee, uint256 _tokenId) external
```

### approve

```solidity
function approve(address to, uint256 tokenId) external
```

### balanceOf

```solidity
function balanceOf(address owner) external view returns (uint256)
```

### baseURI

```solidity
function baseURI() external view returns (string)
```

### cancelMembership

```solidity
function cancelMembership(uint256 tokenId) external
```

### claimed

```solidity
function claimed(address) external view returns (bool)
```

### dagoraRenewPrice

```solidity
function dagoraRenewPrice() external view returns (uint256)
```

### dagoraTreasury

```solidity
function dagoraTreasury() external view returns (address)
```

### dagorianPrice

```solidity
function dagorianPrice() external view returns (uint256)
```

### discount

```solidity
function discount() external view returns (uint256)
```

### ecclesiaPrice

```solidity
function ecclesiaPrice() external view returns (uint256)
```

### experation

```solidity
function experation(uint256) external view returns (uint256)
```

### freeMint

```solidity
function freeMint() external
```

### getApproved

```solidity
function getApproved(uint256 tokenId) external view returns (address)
```

### getExpereation

```solidity
function getExpereation(uint256 _tokenId) external view returns (uint256)
```

### getMembershipTier

```solidity
function getMembershipTier(uint256 _tokenId) external view returns (uint8)
```

### getMintPrice

```solidity
function getMintPrice(uint96 _durationInMonths, uint8 _tier) external view returns (uint256 _price)
```

### getRenewalPrice

```solidity
function getRenewalPrice(uint96 _newDuration, uint8 currentTier) external view returns (uint256 _price)
```

### getTokenDelegates

```solidity
function getTokenDelegates(uint256 _tokenId) external view returns (address[])
```

### giftExtension

```solidity
function giftExtension(uint256 tokenId, uint96 durationInMonths) external
```

### giftMembership

```solidity
function giftMembership(address to, uint8 tier, uint96 durationInMonths) external
```

### giftUpgrade

```solidity
function giftUpgrade(uint256 tokenId, uint8 tier) external
```

### hoplitePrice

```solidity
function hoplitePrice() external view returns (uint256)
```

### hopliteRenewPrice

```solidity
function hopliteRenewPrice() external view returns (uint256)
```

### isApprovedForAll

```solidity
function isApprovedForAll(address owner, address operator) external view returns (bool)
```

### isOwnerOrDelegate

```solidity
function isOwnerOrDelegate(uint256 tokenId, address addrs) external view returns (bool _isOwnerOrDelegate)
```

### isPaused

```solidity
function isPaused() external view returns (bool)
```

### isValidMembership

```solidity
function isValidMembership(uint256 _tokenId) external view returns (bool)
```

### memberships

```solidity
function memberships(uint256) external view returns (uint8 tier, address member, uint256 tokenId, uint256 expiration)
```

### mintMembership

```solidity
function mintMembership(uint96 _durationInMonths, uint8 _tier, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) external
```

### name

```solidity
function name() external view returns (string)
```

### owner

```solidity
function owner() external view returns (address)
```

### ownerOf

```solidity
function ownerOf(uint256 tokenId) external view returns (address)
```

### percelsiaPrice

```solidity
function percelsiaPrice() external view returns (uint256)
```

### percelsiaRenewPrice

```solidity
function percelsiaRenewPrice() external view returns (uint256)
```

### removeDelegate

```solidity
function removeDelegate(address _delegatee, uint256 _tokenId, uint8 slot) external
```

### renewMembership

```solidity
function renewMembership(uint256 _tokenId, uint256 _deadline, uint96 _durationInMonths, uint8 _v, bytes32 _r, bytes32 _s) external
```

### renounceOwnership

```solidity
function renounceOwnership() external
```

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) external
```

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes _data) external
```

### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool approved) external
```

### setBaseURI

```solidity
function setBaseURI(string _baseURI) external
```

### setDagoraTreasury

```solidity
function setDagoraTreasury(address _dagoraTreasury) external
```

### setDagorianPrice

```solidity
function setDagorianPrice(uint256 _price) external
```

### setDagorianRenewPrice

```solidity
function setDagorianRenewPrice(uint256 _price) external
```

### setDiscount

```solidity
function setDiscount(uint256 _discount) external
```

### setEcclesiaPrice

```solidity
function setEcclesiaPrice(uint256 _price) external
```

### setHoplitePrice

```solidity
function setHoplitePrice(uint256 _price) external
```

### setHopliteRenewPrice

```solidity
function setHopliteRenewPrice(uint256 _price) external
```

### setPercelsiaPrice

```solidity
function setPercelsiaPrice(uint256 _price) external
```

### setPercelsiaRenewPrice

```solidity
function setPercelsiaRenewPrice(uint256 _price) external
```

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```

### swapDelegate

```solidity
function swapDelegate(uint256 _tokenId, address oldDelegate, address newDelegate) external
```

### symbol

```solidity
function symbol() external view returns (string)
```

### togglePaused

```solidity
function togglePaused() external
```

### tokenDelegates

```solidity
function tokenDelegates(uint256, uint256) external view returns (address)
```

### tokenURI

```solidity
function tokenURI(uint256 tokenId) external view returns (string)
```

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 tokenId) external
```

### transferOwnership

```solidity
function transferOwnership(address newOwner) external
```

### upgrgadeMembership

```solidity
function upgrgadeMembership(uint8 newTier, uint8 oldTier, uint256 tokenId, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external
```

### withdrawERC20

```solidity
function withdrawERC20(address _token) external
```

### withdrawETH

```solidity
function withdrawETH() external
```

