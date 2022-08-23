# IdAgoraMembership

## Functions

### freeClaim

```solidity
function freeClaim() external
```

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

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `receiver` | address |  |
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

# IdAgoraMembership

## Functions

### freeClaim

```solidity
function freeClaim() external
```

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

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `receiver` | address |  |
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

