# PowerNFT

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

### royaltyReceiver

```solidity
address royaltyReceiver
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
    uint96 _royaltyCut,
    address _newOwner,
    address _royaltyReceiver
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
| `_royaltyCut` | uint96 |  |
| `_newOwner` | address |  |
| `_royaltyReceiver` | address |  |

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

### setRoyalties

```solidity
function setRoyalties(
    address _receiver,
    uint96 _value
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_receiver` | address |  |
| `_value` | uint96 |  |

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

### togglePause

```solidity
function togglePause() public
```

### withdraw

```solidity
function withdraw() public
```

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

