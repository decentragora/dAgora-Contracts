# Solidity API

## PowerNFT

PowerNFT is ERC721A contract that is ownable and has royalties.

_This contract is used as a template for creating new NFT contracts._

### baseURI

```solidity
string baseURI
```

The base URI for all tokens.

### baseExtension

```solidity
string baseExtension
```

The file extension of the metadata can be set to nothing.

_default value is json_

### royaltyRecipient

```solidity
address royaltyRecipient
```

The address that will receive the royalties.

### isPaused

```solidity
bool isPaused
```

Boolean to determine if the contract is isPaused.

_default value is true, contract is isPaused on deployment._

### mintPrice

```solidity
uint256 mintPrice
```

The cost to mint a token.

### maxSupply

```solidity
uint256 maxSupply
```

The maximum number of tokens that can be minted.

### bulkBuyLimit

```solidity
uint16 bulkBuyLimit
```

The maximum number of tokens that can be minted in a single transaction.

### Minted

```solidity
event Minted(address to, uint256 tokenId)
```

### BaseURIChanged

```solidity
event BaseURIChanged(string baseURI)
```

### BaseExtensionChanged

```solidity
event BaseExtensionChanged(string baseExtension)
```

### MintCostChanged

```solidity
event MintCostChanged(uint256 mintPrice)
```

### BulkBuyLimitChanged

```solidity
event BulkBuyLimitChanged(uint16 bulkBuyLimit)
```

### PausedToggled

```solidity
event PausedToggled(bool isPaused)
```

### RoyaltysChanged

```solidity
event RoyaltysChanged(address royaltyRecipient, uint96 royaltyBps)
```

### constructor

```solidity
constructor(string _name, string _symbol, string __baseURI, uint16 _bulkBuyLimit, uint96 _royaltyBps, uint256 _mintPrice, uint256 _maxTotalSupply, address _royaltyRecipient, address _newOwner) public
```

The constructor for the PowerNFT contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _name | string | The name of the NFT. |
| _symbol | string | The symbol of the NFT. |
| __baseURI | string | The base URI for the NFT. |
| _bulkBuyLimit | uint16 | The maximum number of tokens that can be minted in a single transaction. |
| _royaltyBps | uint96 | The royalty percentage, is denominated by 10000. |
| _mintPrice | uint256 | The cost to mint a token. |
| _maxTotalSupply | uint256 | The maximum number of tokens that can be minted. |
| _royaltyRecipient | address | The address that will receive the royalties. |
| _newOwner | address | The address that will be the owner of the contract. |

### isNotPaused

```solidity
modifier isNotPaused()
```

Modifer to check if the contract is isPaused.

### mintNFT

```solidity
function mintNFT(uint256 amount) public payable
```

Function to Mint nfts.

_The amount of tokens to mint must be less than or equal to the bulk buy limit, and contract must not be isPaused._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | The number of tokens to mint. |

### reserveTokens

```solidity
function reserveTokens(uint256 amount) public
```

Function to reserve nfts.

_only the owner can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | The number of tokens to mint. |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) public view virtual returns (string)
```

returns the Uri for a token.

_The token must exist._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The id of the token. |

### setBaseURI

```solidity
function setBaseURI(string __baseURI) public
```

OnlyOwner function to set the baseURI.

_only the owner can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| __baseURI | string | The base URI for the NFT. |

### setBaseExtension

```solidity
function setBaseExtension(string _baseExtension) public
```

OnlyOwner function to set the baseExstension.

_only the owner can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _baseExtension | string | The file extension of the metadata can be set to nothing. |

### setMintPrice

```solidity
function setMintPrice(uint256 _mintPrice) public
```

OnlyOwner function to set the mint cost of a nft.

_only the owner can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _mintPrice | uint256 | The cost to mint a token. |

### setBulkBuyLimit

```solidity
function setBulkBuyLimit(uint16 _bulkBuyLimit) public
```

OnlyOwner function to set the bulk buy limit.

_only the owner can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _bulkBuyLimit | uint16 | The maximum number of tokens that can be minted in a single transaction. |

### togglePaused

```solidity
function togglePaused() public
```

OnlyOwner function to toggle the isPaused state of the contract.

_only the owner can call this function._

### setRoyalties

```solidity
function setRoyalties(address _royaltyRecipient, uint96 _royaltyBps) public
```

OnlyOwner function to set the royalties.

_only the owner can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _royaltyRecipient | address | The address that will receive the royalties. |
| _royaltyBps | uint96 | The royalty percentage, is denominated by 10000. |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool)
```

### withdrawETH

```solidity
function withdrawETH() public
```

OnlyOwner function to withdraw ETH.

_only the owner can call this function.
the owner can withdraw the ETH from the contract._

### withdrawERC20

```solidity
function withdrawERC20(address _tokenAddr) public
```

OnlyOwner function to withdraw ERC20 tokens.

_only the owner can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenAddr | address | The address of the ERC20 token. |

### _beforeTokenTransfers

```solidity
function _beforeTokenTransfers(address from, address to, uint256 tokenId, uint256 quantity) internal
```

internal override function that is called before any token transfer.

_this function will revert if the contract is paused, pausing transfers of tokens._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | The address of the sender. |
| to | address | The address of the receiver. |
| tokenId | uint256 | The token ID. |
| quantity | uint256 | The quantity of tokens to transfer. |

### typeOf

```solidity
function typeOf() public pure virtual returns (string)
```

function that returns the dagora contract type

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string | the dagora contract type |

### version

```solidity
function version() public pure returns (string)
```

function that returns the dagora contract version

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string | the dagora contract version |

### _startTokenId

```solidity
function _startTokenId() internal view virtual returns (uint256)
```

internal function that handles that starting tokenId of the collection

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the starting tokenId of the collection eg 1 |

