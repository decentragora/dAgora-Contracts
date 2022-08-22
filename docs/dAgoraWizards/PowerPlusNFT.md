# PowerPlusNFT

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

### royaltyReceiver

```solidity
address royaltyReceiver
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
    uint96 _royaltyCut,
    address _newOwner,
    address _royaltyReceiver,
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
| `_royaltyCut` | uint96 |  |
| `_newOwner` | address |  |
| `_royaltyReceiver` | address |  |
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
    uint16 _newMaxAllowListAmount
) public
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newMaxAllowListAmount` | uint16 |  |

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

### withdraw

```solidity
function withdraw() public
```

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

