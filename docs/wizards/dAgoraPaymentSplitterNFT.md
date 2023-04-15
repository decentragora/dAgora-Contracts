# Solidity API

## DagoraPaymentSplitterNFT

### PayeeShare

```solidity
struct PayeeShare {
  address payee;
  uint256 shareAmount;
}
```
### isPaused

```solidity
bool isPaused
```

Boolean to determine if the contract is isPaused.

_default value is true, contract is isPaused on deployment._

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

### bulkBuyLimit

```solidity
uint16 bulkBuyLimit
```

The maximum number of tokens that can be minted in a single transaction.

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

### payeeCount

```solidity
uint256 payeeCount
```

The number of payees.

### payeeShares

```solidity
mapping(uint256 => struct DagoraPaymentSplitterNFT.PayeeShare) payeeShares
```

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

### isPausedToggled

```solidity
event isPausedToggled(bool isPaused)
```

### PayeeAdded

```solidity
event PayeeAdded(address account, uint256 shares)
```

### PaymentReleased

```solidity
event PaymentReleased(address to, uint256 amount)
```

### ERC20PaymentReleased

```solidity
event ERC20PaymentReleased(contract IERC20 token, address to, uint256 amount)
```

### PaymentReceived

```solidity
event PaymentReceived(address from, uint256 amount)
```

### constructor

```solidity
constructor(string name_, string symbol_, address[] payees, uint256[] shares_, uint256 _mintPrice, uint256 _maxSupply, uint16 _bulkBuyLimit, string _baseURI, string _baseExtension, address newOwner) public
```

Constructor for the contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name_ | string | the name of the contract and token |
| symbol_ | string | the symbol of the token |
| payees | address[] | the addresses of the payees |
| shares_ | uint256[] | the amount of shares each payee has |
| _mintPrice | uint256 | the cost to mint a token |
| _maxSupply | uint256 | the maximum number of tokens that can be minted |
| _bulkBuyLimit | uint16 | the maximum number of tokens that can be minted in a single transaction |
| _baseURI | string | the base URI for all tokens |
| _baseExtension | string | the file extension of the metadata can be set to nothing |
| newOwner | address | the address of the new owner |

### isNotPaused

```solidity
modifier isNotPaused()
```

Modifier to check if the contract is isPaused.

_Throws if the contract is isPaused._

### mintNFT

```solidity
function mintNFT(uint256 amonut) public payable
```

Funtion to mint one or more tokens.

_Throws if the number of tokens to mint exceeds the bulk buy limit.
Throws if the number of tokens to mint exceeds the max supply.
Throws if the amount of ETH sent is less than the cost to mint a token._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amonut | uint256 | the number of tokens to mint |

### reserveTokens

```solidity
function reserveTokens(uint256 amount) public
```

onlyOwner function to mint one or more tokens.

_Throws if the number of tokens to mint exceeds the max supply._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | the number of tokens to mint |

### totalShares

```solidity
function totalShares() public view returns (uint256)
```

getter function for the total shares.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the total shares |

### totalReleased

```solidity
function totalReleased() public view returns (uint256)
```

getter function for the total released.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the total released |

### totalReleased

```solidity
function totalReleased(contract IERC20 token) public view returns (uint256)
```

getter function for the total released.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | contract IERC20 | the token to check |

### shares

```solidity
function shares(address account) public view returns (uint256)
```

getter function for the shares.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | the address to check |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the shares for the address |

### released

```solidity
function released(address account) public view returns (uint256)
```

getter function for the released.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | the address to check |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the released for the address |

### released

```solidity
function released(contract IERC20 token, address account) public view returns (uint256)
```

getter function for the released.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | contract IERC20 | the token to check |
| account | address | the address to check |

### payee

```solidity
function payee(uint256 index) public view returns (address)
```

getter function for the payees.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| index | uint256 | the index of the payee |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | the address of the payee |

### releasable

```solidity
function releasable(address account) public view returns (uint256)
```

getter function for checking how much a payee is owed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | the address to check |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the amount of ETH owed to the address |

### releasable

```solidity
function releasable(contract IERC20 token, address account) public view returns (uint256)
```

getter function for checking how much a payee is owed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token | contract IERC20 | the token to check |
| account | address | the address to check |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the amount of tokens owed to the address |

### release

```solidity
function release(address payable account) public
```

function to release the amount owed to a payee.

_Throws if the address has no shares.
Throws if the address is not due payment._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address payable | the address to release the payment to |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) public view returns (string)
```

returns the tokenURI for a given token.

_this function is only callable when the token exists._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | the tokenID to get the tokenURI for. |

### setBaseURI

```solidity
function setBaseURI(string __baseURI) external
```

Onlyowner function to set the base URI.

_this function is only callable by the owner of the contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| __baseURI | string | the base URI to set. |

### setBaseExtension

```solidity
function setBaseExtension(string _baseExtension) external
```

Onlyowner function to set the base extension.

_this function is only callable by the owner of the contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _baseExtension | string | the base extension to set. |

### setMintPrice

```solidity
function setMintPrice(uint256 _mintPrice) external
```

Onlyowner function to set the mint price for the public sale.

_this function is only callable by the owner of the contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _mintPrice | uint256 | the mint cost to set. |

### setBulkBuyLimit

```solidity
function setBulkBuyLimit(uint16 _bulkBuyLimit) external
```

Onlyowner function to set the bulk buy limit.

_this function is only callable by the owner of the contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _bulkBuyLimit | uint16 | the bulk buy limit to set. |

### togglePaused

```solidity
function togglePaused() external
```

Onlyowner function to set the paused state of the contract.

_this function is only callable by the owner of the contract._

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
function _startTokenId() internal view virtual returns (uint256)
```

internal function that handles that starting tokenId of the collection

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | the starting tokenId of the collection eg 1 |

### receive

```solidity
receive() external payable virtual
```

_The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully
reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the
reliability of the events, and not the actual splitting of Ether.

To learn more about this see the Solidity documentation for
https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback
functions]._

