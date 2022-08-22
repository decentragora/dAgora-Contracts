# SimpleNFTA

## Variables

### baseURI

```solidity
string baseURI
```

### baseExtension

```solidity
string baseExtension
```

### paused

```solidity
bool paused
```

### mintCost

```solidity
uint256 mintCost
```

### bulkBuyLimit

```solidity
uint256 bulkBuyLimit
```

### maxTotalSupply

```solidity
uint256 maxTotalSupply
```

## Functions

### constructor

```solidity
constructor(
    string _name,
    string _symbol,
    string _baseURI,
    uint256 _mintCost,
    uint256 _bulkBuyLimit,
    uint256 _maxTotalSupply,
    address _newOwner
) 
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_name` | string |  |
| `_symbol` | string |  |
| `_baseURI` | string |  |
| `_mintCost` | uint256 |  |
| `_bulkBuyLimit` | uint256 |  |
| `_maxTotalSupply` | uint256 |  |
| `_newOwner` | address |  |

### mintNFT

```solidity
function mintNFT(
    uint256 _amount
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_amount` | uint256 |  |

### reserveTokens

```solidity
function reserveTokens(
    uint256 _quanitity
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_quanitity` | uint256 |  |

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

### setBaseURI

```solidity
function setBaseURI(
    string _newBaseURI
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newBaseURI` | string |  |

### setMintCost

```solidity
function setMintCost(
    uint256 _newMintCost
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newMintCost` | uint256 |  |

### setBulkBuyLimit

```solidity
function setBulkBuyLimit(
    uint256 _newBulkBuyLimit
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newBulkBuyLimit` | uint256 |  |

### setBaseExtension

```solidity
function setBaseExtension(
    string _newBaseExtension
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newBaseExtension` | string |  |

### togglePaused

```solidity
function togglePaused() public
```

### withdraw

```solidity
function withdraw() public
```

### withdrawErc20s

```solidity
function withdrawErc20s(
    address _tokenAddr
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenAddr` | address |  |

### _startTokenId

```solidity
function _startTokenId() internal returns (uint256)
```

Returns the starting token ID.
To change the starting token ID, please override this function.

## Modifiers

### isPaused

```solidity
modifier isPaused()
```

