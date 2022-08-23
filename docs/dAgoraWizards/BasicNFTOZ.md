# BasicNFTOZ

dAgora Basic NFT OZ

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

### paused

```solidity
bool paused
```

Used to pause and unpause the contract.

### mintCost

```solidity
uint256 mintCost
```

The price to mint a new NFT.

### bulkBuyLimit

```solidity
uint16 bulkBuyLimit
```

The maximum amount of NFTs that can be minted in one transaction.

### maxTotalSupply

```solidity
uint256 maxTotalSupply
```

The maximum amount of NFTs that can be minted.

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

Event emitted when a membership is purchased.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_name` | string | The name of the NFT. |
| `_symbol` | string | The symbol of the NFT. |
| `_baseURI` | string | The baseURI of the NFT. |
| `_mintCost` | uint256 | The cost to mint a new NFT. |
| `_bulkBuyLimit` | uint16 | The maximum amount of NFTs that can be minted in one transaction. |
| `_maxTotalSupply` | uint256 | The maximum amount of NFTs that can be minted. |
| `_newOwner` | address | The address of the owner/ msg.sender. |

### mintNFT

```solidity
function mintNFT(
    uint256 _amount
) public
```

Main function used to mint NFTs.

The amount of NFTs to mint must be less than or equal to the bulkBuyLimit.
The total supply of NFTs must be less than or equal to the maxTotalSupply.
The Contracts paused state must be false.

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

### setBaseURI

```solidity
function setBaseURI(
    string _newBaseURI
) public
```

Only Contract Owner can use this function to set the baseURI.

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

Only Contract Owner can use this function to set the baseExtension.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newBaseExtension` | string | The new baseExtension. |

### setMintCost

```solidity
function setMintCost(
    uint256 _newMintCost
) public
```

Only Contract Owner can use this function to set the mintCost.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newMintCost` | uint256 | The new mintCost. |

### setBulkBuyLimit

```solidity
function setBulkBuyLimit(
    uint16 _newBulkBuyLimit
) public
```

Only Contract Owner can use this function to pause the contract.

The bulkBuyLimit must be less than the maxTotalSupply.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_newBulkBuyLimit` | uint16 | The new bulkBuyLimit. |

### togglePaused

```solidity
function togglePaused() public
```

Only Contract Owner can use this function to pause the contract.

Used to prevent users from minting NFTs.

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

Withdraws the funds from the contract to contract owner.

Only Contract Owner can use this function.

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

## Modifiers

### isPaused

```solidity
modifier isPaused()
```

Checks if the contract is paused.

_Used to prevent users from minting NFTs when the contract is paused._

