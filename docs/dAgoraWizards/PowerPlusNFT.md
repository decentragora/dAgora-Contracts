# PowerPlusNFT

dAgora Power Plus NFT

Used as a template for creating new NFT contracts.

## Variables

### baseURI

```solidity
string baseURI
```

Where the NFTs metadata is stored.

### baseExtension

```solidity
string baseExtension
```

The file extension for the NFTs baseURI.

### merkleRoot

```solidity
bytes32 merkleRoot
```

Used to store the allowed addresses for minting.

_This is used to store the addresses that are allowed to mint NFTs during presale._
### paused

```solidity
bool paused
```

Used to pause and unpause the contract.

### preSale

```solidity
bool preSale
```

Used to change and set the sale state of the contract.

### bulkBuyLimit

```solidity
uint16 bulkBuyLimit
```

The maximum amount of NFTs that can be minted in one transaction.

### maxAllowListAmount

```solidity
uint16 maxAllowListAmount
```

The maximum amount of NFTs that can be minted by a allowed listed address.

### mintCost

```solidity
uint256 mintCost
```

The price to mint a new NFT.

### maxTotalSupply

```solidity
uint256 maxTotalSupply
```

The maximum amount of NFTs that can be minted.

### royaltyReceiver

```solidity
address royaltyReceiver
```

The address that the royalty % will go to.

### presaleMintBalance

```solidity
mapping(address => uint256) presaleMintBalance
```

Maps a address to the amount of NFTs they have minted.

_This is used to keep track of the amount of NFTs a address has minted during presale._

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

Sets the contracts variables.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_name` | string | The name of the NFT. |
| `_symbol` | string | The symbol of the NFT. |
| `_baseURI` | string | The baseURI of the NFT. |
| `_mintCost` | uint256 | The cost to mint a new NFT. |
| `_bulkBuyLimit` | uint16 | The maximum amount of NFTs that can be minted in one transaction. |
| `_maxAllowListAmount` | uint16 | The max amount of NFTs that can be minted by a allowed listed address. |
| `_maxTotalSupply` | uint256 | The maximum amount of NFTs that can be minted. |
| `_royaltyCut` | uint96 | The amount of the royalty cut. |
| `_newOwner` | address | The address that will be the owner of the contract. |
| `_royaltyReceiver` | address | The address that the royalty % will go to. |
| `_merkleRoot` | bytes32 | The merkle root of the allowed addresses. |

### presaleMint

```solidity
function presaleMint(
    bytes32[] _proof,
    uint256 _amount
) public
```

Function for public to mint NFTs.

Used to mint NFTs during public sale.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_proof` | bytes32[] |  |
| `_amount` | uint256 | The amount of NFTs to mint. |

### mintNFT

```solidity
function mintNFT(
    uint256 _amount
) public
```

Function for public to mint NFTs.

Used to mint NFTs during public sale.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_amount` | uint256 | The amount of NFTs to mint. |

### reserveTokens

```solidity
function reserveTokens(
    uint256 _amount
) public
```

Only Contract Owner can use this function to Mint NFTs.

The total supply of NFTs must be less than or equal to the maxTotalSupply.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_amount` | uint256 | The amount of NFTs to mint. |

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

Allows contract owner to change the contracts paused state.

Used to pause & unpause the contract.

### togglePreSale

```solidity
function togglePreSale() public
```

Allows contract owner to change the contracts sale state.

Used to change the contract from presale to public sale.

### setBaseURI

```solidity
function setBaseURI(
    string _newBaseURI
) public
```

Allows the owner to change the baseURI.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newBaseURI` | string | The new baseURI. |

### setBaseExtension

```solidity
function setBaseExtension(
    string _newBaseExtension
) public
```

Allows the owner to change the Base extension.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newBaseExtension` | string | The new baseExtension. |

### setMerkleRoot

```solidity
function setMerkleRoot(
    bytes32 _merkleRoot
) public
```

Allows the owner to change the merkle root.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_merkleRoot` | bytes32 | The new merkle root. |

### setMintCost

```solidity
function setMintCost(
    uint256 _newMintCost
) public
```

Allows the owner to change the mint cost.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newMintCost` | uint256 | The new mint cost. |

### setBulkBuyLimit

```solidity
function setBulkBuyLimit(
    uint16 _newBulkBuyLimit
) public
```

The bulkBuyLimit must be less than the maxTotalSupply.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newBulkBuyLimit` | uint16 | The new bulkBuyLimit. |

### setMaxAllowListAmount

```solidity
function setMaxAllowListAmount(
    uint16 _newMaxAllowListAmount
) public
```

Allows the owner to change the max allow list amount.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newMaxAllowListAmount` | uint16 | The new max allow list amount. |

### setRoyalties

```solidity
function setRoyalties(
    address _receiver,
    uint96 _value
) public
```

Used to set the royalty receiver & amount.

The value must be less than or equal to 10000. example (250 / 10000) * 100 = 2.5%.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_receiver` | address | The address that the royalty % will go to. |
| `_value` | uint96 | The amount of the royalty cut. |

### withdraw

```solidity
function withdraw() public
```

Allows the owner to withdraw ether from contract.

The owner can only withdraw ether from the contract.

### withdrawErc20s

```solidity
function withdrawErc20s(
    address _tokenAddr
) public
```

Allows owner to withdraw any ERC20 tokens sent to this contract.

Only Contract Owner can use this function.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_tokenAddr` | address | The address of the ERC20 token. |

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

Checks if the contract is paused.

_Used to prevent users from minting NFTs when the contract is paused._

### isValidMerkleProof

```solidity
modifier isValidMerkleProof(bytes32[] merkleProof, bytes32 root)
```

### isPresale

```solidity
modifier isPresale()
```

Checks if the contract is in presale state.

_Used to prevent users not in allow list from minting NFTs when the contract is in presale state._

### isPublic

```solidity
modifier isPublic()
```

Checks if the contract is in public sale state.

