# NFTAPlus

## Variables

### baseURI

```solidity
string baseURI
```

### baseExtension

```solidity
string baseExtension
```

### merkleRoot

```solidity
bytes32 merkleRoot
```

### paused

```solidity
bool paused
```

### preSale

```solidity
bool preSale
```

### maxAllowListAmount

```solidity
uint16 maxAllowListAmount
```

### bulkBuyLimit

```solidity
uint16 bulkBuyLimit
```

### mintCost

```solidity
uint256 mintCost
```

### maxTotalSupply

```solidity
uint256 maxTotalSupply
```

### presaleMintBalance

```solidity
mapping(address => uint256) presaleMintBalance
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
    uint16 _maxAllowListAmount,
    uint256 _maxTotalSupply,
    address _newOwner,
    bytes32 _merkleRoot
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
| `_maxAllowListAmount` | uint16 |  |
| `_maxTotalSupply` | uint256 |  |
| `_newOwner` | address |  |
| `_merkleRoot` | bytes32 |  |

### preSaleMint

```solidity
function preSaleMint(
    bytes32[] proof,
    uint256 _amount
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `proof` | bytes32[] |  |
| `_amount` | uint256 |  |

### publicMint

```solidity
function publicMint(
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

### togglePaused

```solidity
function togglePaused() public
```

### togglePreSale

```solidity
function togglePreSale() public
```

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
    string _baseExtension
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_baseExtension` | string |  |

### setMerkleRoot

```solidity
function setMerkleRoot(
    bytes32 _merkleRoot
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_merkleRoot` | bytes32 |  |

### setMintCost

```solidity
function setMintCost(
    uint256 _mintCost
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_mintCost` | uint256 |  |

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

### setMaxAllowListAmount

```solidity
function setMaxAllowListAmount(
    uint16 _newAllowListAmount
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newAllowListAmount` | uint16 |  |

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

### notPaused

```solidity
modifier notPaused()
```

### isValidMerkleProof

```solidity
modifier isValidMerkleProof(bytes32[] merkleProof, bytes32 root)
```

### isPresale

```solidity
modifier isPresale()
```

### isPublic

```solidity
modifier isPublic()
```

