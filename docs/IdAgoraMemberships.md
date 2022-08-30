# IdAgoraMembership

dAgora Memberships NFT Interface

Used to interact with the dAgora Memberships NFT

## Functions

### freeClaim

```solidity
function freeClaim() external
```

Checks that the msg.sender is the tokenId owner

Modifier for functions
Used on funcs where we only want token owner to interact
example being a token owner can renew a token but not a random user.

### checkTokenTier

```solidity
function checkTokenTier(
    uint256 _tokenId
) external returns (uint256)
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 |  |

### isValidMembership

```solidity
function isValidMembership(
    uint256 _tokenId
) external returns (bool)
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 |  |

### isOwnerOrDelegate

```solidity
function isOwnerOrDelegate(
    uint256 _tokenId,
    address _owner
) external returns (bool)
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 |  |
| `_owner` | address |  |

### membershipExpiresIn

```solidity
function membershipExpiresIn(
    uint256 _tokenId
) external returns (uint256)
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 |  |

### checkTokenIndexedToOwner

```solidity
function checkTokenIndexedToOwner(
    uint256 _tokenId
) external returns (address)
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenId` | uint256 |  |

## Events

### Claimed

```solidity
event Claimed(
    address receiver
)
```

Emitted when a new membership is created and minted to a user address.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `receiver` | address | The address of the minter |
### ClaimRequested

```solidity
event ClaimRequested(
    address receiver
)
```

Event emitted whenever a claim is requested.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `receiver` | address | The address that receives the tokens. |

