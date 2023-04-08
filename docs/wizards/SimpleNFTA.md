# Solidity API

## SimpleNFTA

### isPaused

```solidity
bool isPaused
```

State variable to track if the contract is paused

### baseURI

```solidity
string baseURI
```

The base URI for all tokens

### baseExtension

```solidity
string baseExtension
```

The Extension at the end of the URI

### bulkBuyLimit

```solidity
uint16 bulkBuyLimit
```

The maximum number of tokens that can be minted in a single transaction

### mintPrice

```solidity
uint256 mintPrice
```

The price of a single token

### maxSupply

```solidity
uint256 maxSupply
```

The maximum number of tokens that can be minted

### Minted

```solidity
event Minted(address to, uint256 tokenId)
```

the event that is emitted when a token is minted

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address that received the token |
| tokenId | uint256 | The id of the token that was minted |

### BaseURIChanged

```solidity
event BaseURIChanged(string baseURI)
```

the event that is emitted when the baseURI is changed

_The baseURI is the URI at the beginning of the tokenURI_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| baseURI | string | The new baseURI |

### BaseExtensionChanged

```solidity
event BaseExtensionChanged(string baseExtension)
```

the event that is emitted when the baseExtension is changed

_The baseExtension is the extension at the end of the baseURI_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| baseExtension | string | The new baseExtension |

### MintCostChanged

```solidity
event MintCostChanged(uint256 mintPrice)
```

the event that is emitted when the mintPrice is changed

_The mintPrice is the price of a single token can only be changed by the owner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| mintPrice | uint256 | The new mintPrice |

### BulkBuyLimitChanged

```solidity
event BulkBuyLimitChanged(uint256 bulkBuyLimit)
```

the event that is emitted when the bulkBuyLimit is changed

_The bulkBuyLimit is the maximum number of tokens that can be minted in a single transaction_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| bulkBuyLimit | uint256 | The new bulkBuyLimit |

### PausedToggled

```solidity
event PausedToggled(bool paused)
```

the event that is emitted when the contract is paused or unpaused

_The contract can only be paused or unpaused by the owner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| paused | bool | The new paused state |

### constructor

```solidity
constructor(string name_, string symbol_, string baseURI_, uint16 _bulkBuyLimit, uint256 _mintPrice, uint256 _maxSupply, address _newOwner) public
```

The constructor for the contract

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name_ | string | The name of the token |
| symbol_ | string | The symbol of the token |
| baseURI_ | string | The base URI for the token |
| _bulkBuyLimit | uint16 | The maximum number of tokens that can be minted in a single transaction |
| _mintPrice | uint256 | The price of a single token |
| _maxSupply | uint256 | The maximum number of tokens that can be minted |
| _newOwner | address | The address that will be the owner of the contract |

### isNotPaused

```solidity
modifier isNotPaused()
```

Modifier to check if the contract is paused

_Throws if the contract is paused_

### mintNFT

```solidity
function mintNFT(uint256 amount) public payable
```

the function to mint nft tokens can be one or up to bulkBuyLimit

_the function can only be called if the contract is not paused_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | The number of tokens to mint can be one or up to bulkBuyLimit |

### reserveTokens

```solidity
function reserveTokens(uint256 amount) public
```

onlyOwner function to mint nft tokens can be one or up to bulkBuyLimit

_the function can only be called if the contract is not paused_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | The number of tokens to mint can be one or up to bulkBuyLimit |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) public view returns (string)
```

function that returns the tokenURI for a given token

_the function can only be called if the token exists_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The id of the token |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string | the tokenURI for the given token |

### setBaseURI

```solidity
function setBaseURI(string _baseURI) public
```

onlyInOwner function to change the baseURI

_the function can only be called by the owner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _baseURI | string | The new baseURI |

### setBaseExtension

```solidity
function setBaseExtension(string _baseExtension) public
```

onlyInOwner function to change the baseExtension

_the function can only be called by the owner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _baseExtension | string | The new baseExtension |

### setMintPrice

```solidity
function setMintPrice(uint256 _mintPrice) public
```

onlyInOwner function to change the mintPrice

_the function can only be called by the owner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _mintPrice | uint256 | The new mintPrice |

### setBulkBuyLimit

```solidity
function setBulkBuyLimit(uint16 _bulkBuyLimit) public
```

onlyInOwner function to change the bulkBuyLimit

_the function can only be called by the owner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _bulkBuyLimit | uint16 | The new bulkBuyLimit |

### togglePaused

```solidity
function togglePaused() public
```

onlyInOwner function to change the isPaused state

_the function can only be called by the owner_

### withdrawETH

```solidity
function withdrawETH() public
```

onlyInOwner function to withdraw ETH from the contract

_the function can only be called by the owner_

### withdrawERC20

```solidity
function withdrawERC20(address token) public
```

onlyInOwner function to withdraw ERC20 tokens from the contract

_the function can only be called by the owner_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | address | The address of the ERC20 token |

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
function typeOf() public pure returns (string)
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
function _startTokenId() internal pure returns (uint256)
```

internal function that handles that starting tokenId of the collection

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the starting tokenId of the collection eg 1 |

