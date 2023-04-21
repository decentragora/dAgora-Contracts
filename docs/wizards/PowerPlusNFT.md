# Solidity API

## PowerPlusNFT

PowerPlusNFT is ERC721A contract that is ownable, has royalties, and a pre-sale.

_This contract is used as a template for creating new NFT contracts._

### Params

```solidity
struct Params {
  string name_;
  string symbol_;
  string baseURI_;
  uint16 _bulkBuyLimit;
  uint16 _maxAllowListAmount;
  uint96 _royaltyBps;
  uint256 _mintPrice;
  uint256 _presaleMintCost;
  uint256 _maxSupply;
  address _royaltyRecipient;
  address _newOwner;
  bytes32 _merkleRoot;
}
```
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

Boolean to determine if the contract is paused.

_default value is true, contract is paused on deployment._

### preSaleActive

```solidity
bool preSaleActive
```

Boolean to determine if the contract is in the pre-sale period.

_default value is true, contract is in presale state on deployment._

### merkleRoot

```solidity
bytes32 merkleRoot
```

The merkle root for the allowList.

### bulkBuyLimit

```solidity
uint16 bulkBuyLimit
```

The maximum number of tokens that can be minted in a single transaction.

### maxAllowListAmount

```solidity
uint16 maxAllowListAmount
```

The maximum number of tokens that can be minted in a single transaction for a whitelist address.

_this is used during the whitelist period._

### mintPrice

```solidity
uint256 mintPrice
```

The cost to mint a token.

### presaleMintPrice

```solidity
uint256 presaleMintPrice
```

The cost to mint a token during the presale period.

### maxSupply

```solidity
uint256 maxSupply
```

The maximum number of tokens that can be minted.

### Minted

```solidity
event Minted(address to, uint256 tokenId)
```

### AllowListMinted

```solidity
event AllowListMinted(address to, uint256 tokenId)
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

### presaleMintPriceChanged

```solidity
event presaleMintPriceChanged(uint256 presaleMintPrice)
```

### BulkBuyLimitChanged

```solidity
event BulkBuyLimitChanged(uint16 bulkBuyLimit)
```

### MaxAllowListAmountChanged

```solidity
event MaxAllowListAmountChanged(uint16 maxAllowListAmount)
```

### PausedToggled

```solidity
event PausedToggled(bool paused)
```

### PreSaleToggled

```solidity
event PreSaleToggled(bool preSaleActive)
```

### RoyaltysChanged

```solidity
event RoyaltysChanged(address royaltyRecipient, uint96 royaltyBps)
```

### allowListMintCount

```solidity
mapping(address => uint256) allowListMintCount
```

Mapping to track the number of tokens minted for each address during presale.

### constructor

```solidity
constructor(struct PowerPlusNFT.Params _params) public
```

The constructor for the contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _params | struct PowerPlusNFT.Params | The struct containing the parameters for the contract. |

### isNotPaused

```solidity
modifier isNotPaused()
```

Modifier to check if the contract is paused.

### isValidMerkleProof

```solidity
modifier isValidMerkleProof(bytes32[] merkleProof, bytes32 root)
```

Modifier to check the address is allowed to mint during the presale period.

_check the proof provided against the root stored in the contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| merkleProof | bytes32[] | The merkle proof for the address. |
| root | bytes32 | The merkle root for the allowList. |

### isPublicSale

```solidity
modifier isPublicSale()
```

a modifier to check if the contract is in the public sale period.

### isPreSale

```solidity
modifier isPreSale()
```

a modifier to check if the contract is in the presale period.

### mintNFT

```solidity
function mintNFT(address to, uint256 amount) public payable
```

Fcuntion to mint nfts.

_this function is used during the public sale period._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address |  |
| amount | uint256 | The number of tokens to mint. |

### presaleMintNFT

```solidity
function presaleMintNFT(bytes32[] _proof, uint256 amount) public payable
```

Function to mint nfts during the presale period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _proof | bytes32[] | The merkle proof for the address. |
| amount | uint256 | The number of tokens to mint. |

### reserveTokens

```solidity
function reserveTokens(uint256 amount) public
```

Function to mint nfts during the presale period.

_this function is used to mint tokens for the team._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | The number of tokens to mint. |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) public view returns (string)
```

returns the token URI for a given token.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The token ID. |

### togglePaused

```solidity
function togglePaused() public
```

Function to toggle the paused state of the contract.

### togglePresale

```solidity
function togglePresale() public
```

OnlyOwner Function to toggle the presale state of the contract.

### setBaseURI

```solidity
function setBaseURI(string _base_URI) public
```

OnlyOwner Function to set the base URI for the token URIs.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _base_URI | string | The new base URI. |

### setBaseExtension

```solidity
function setBaseExtension(string _baseExtension) public
```

OnlyOwner Function to set the base extension for the token URIs.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _baseExtension | string | The new base extension. |

### setMintPrice

```solidity
function setMintPrice(uint256 _mintPrice) public
```

OnlyOwner Function to set the mint cost during the public sale period.

_this function is used to set the mint cost during the public sale period._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _mintPrice | uint256 | The new mint cost during the public sale period. |

### setPresaleMintPrice

```solidity
function setPresaleMintPrice(uint256 _presaleMintPrice) public
```

OnlyOwner Function to set the mint cost during the presale period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _presaleMintPrice | uint256 | The new mint cost during the presale period. |

### setBulkBuyLimit

```solidity
function setBulkBuyLimit(uint16 _bulkBuyLimit) public
```

OnlyOwner Function to set the bulk buy limit per transaction, during the public sale period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _bulkBuyLimit | uint16 | The new bulk buy limit. |

### setMaxAllowListAmount

```solidity
function setMaxAllowListAmount(uint16 _amount) public
```

OnlyOwner Function to set the max allow list amount per address, during the presale period.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _amount | uint16 | The new max allow list amount per address. |

### setMerkleRoot

```solidity
function setMerkleRoot(bytes32 _merkleRoot) public
```

OnlyOwner Function to set the merkle root for the presale.

_this function is used to set the merkle root for the presale, this is used to verify the merkle proof and check if a address is included._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _merkleRoot | bytes32 | The new merkle root. |

### setRoyalties

```solidity
function setRoyalties(address _royaltyRecipient, uint96 _royaltyBps) public
```

Function to set the royalties for the contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _royaltyRecipient | address | The new royalty recipient. |
| _royaltyBps | uint96 | The new royalty bps, denominated by 10000. |

### withdrawETH

```solidity
function withdrawETH() public
```

OnlyOwner Function to withdraw ETH from the contract.

### withdrawERC20

```solidity
function withdrawERC20(address _tokenAddr) public
```

OnlyOwner function to withdraw ERC20 tokens from the contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenAddr | address | The address of the ERC20 token to withdraw. |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool)
```

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

