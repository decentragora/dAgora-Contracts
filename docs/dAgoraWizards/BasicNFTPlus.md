# BasicNFTPlus

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
uint256 maxAllowListAmount
```

### bulkBuyLimit

```solidity
uint256 bulkBuyLimit
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

### presaleMint

```solidity
function presaleMint(
    bytes32[] _proof,
    uint256 _amount
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_proof` | bytes32[] |  |
| `_amount` | uint256 |  |

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

### togglePreSale

```solidity
function togglePreSale() public
```

### togglePaused

```solidity
function togglePaused() public
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

### setMaxAllowListAmount

```solidity
function setMaxAllowListAmount(
    uint256 _newMaxAllowListAmount
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newMaxAllowListAmount` | uint256 |  |

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

### totalSupply

```solidity
function totalSupply() public returns (uint256)
```

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

### withdraw

```solidity
function withdraw() public
```

## Modifiers

### isPaused

```solidity
modifier isPaused()
```

### isValidMerkleProof

```solidity
modifier isValidMerkleProof(bytes32[] merkleProof, bytes32 root)
```

### isPreSale

```solidity
modifier isPreSale()
```

### isPublic

```solidity
modifier isPublic()
```

