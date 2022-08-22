# BasicNFTOZ

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
uint16 bulkBuyLimit
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
    uint16 _bulkBuyLimit,
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
| `_bulkBuyLimit` | uint16 |  |
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
    uint256 _amount
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_amount` | uint256 |  |

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
    string _baseURI
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_baseURI` | string |  |

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
    uint16 _newBulkBuyLimit
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newBulkBuyLimit` | uint16 |  |

### togglePaused

```solidity
function togglePaused() public
```

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
) internal
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `from` | address |  |
| `to` | address |  |
| `tokenId` | uint256 |  |

### supportsInterface

```solidity
function supportsInterface(
    bytes4 interfaceId
) public returns (bool)
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `interfaceId` | bytes4 |  |

### withdraw

```solidity
function withdraw() public
```

## Modifiers

### isPaused

```solidity
modifier isPaused()
```

