# Solidity API

## NFTAPlus

### isPaused

```solidity
bool isPaused
```

Boolean to determine if the contract is isPaused.

_default value is true, contract is isPaused on deployment._

### isPresale

```solidity
bool isPresale
```

Boolean to determine if the contract is in the presale period.

_default value is true._

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

### merkleRoot

```solidity
bytes32 merkleRoot
```

The merkle root for the allowList, this is used to verify the allowList.

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

### PresaleMinted

```solidity
event PresaleMinted(address to, uint256 tokenId)
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

### PresaleMintCostChanged

```solidity
event PresaleMintCostChanged(uint256 presaleMintCost)
```

### BulkBuyLimitChanged

```solidity
event BulkBuyLimitChanged(uint16 bulkBuyLimit)
```

### MaxAllowListAmountChanged

```solidity
event MaxAllowListAmountChanged(uint16 maxAllowListAmount)
```

### isPausedToggled

```solidity
event isPausedToggled(bool isPaused)
```

### PresaleToggled

```solidity
event PresaleToggled(bool isPresale)
```

### allowListMintCount

```solidity
mapping(address => uint256) allowListMintCount
```

### constructor

```solidity
constructor(string _name, string _symbol, string __baseURI, uint16 _bulkBuyLimit, uint16 _maxAllowListAmount, uint256 _mintCost, uint256 _presaleMintCost, uint256 _maxTotalSupply, address _newOwner, bytes32 _merkleRoot) public
```

### isNotPaused

```solidity
modifier isNotPaused()
```

Modifier to check if the contract is isPaused.

_Throws if the contract is isPaused._

### _isPresale

```solidity
modifier _isPresale()
```

Modifier to check the sale state of the contract.

_Throws if the contract is not in the presale period._

### isPublicSale

```solidity
modifier isPublicSale()
```

Modifier to check the sale state of the contract.

_Throws if the contract is not in the public sale period._

### isValidMerkleProof

```solidity
modifier isValidMerkleProof(bytes32[] merkleProof, bytes32 root)
```

Modifier to check the proof of the allowList.

_Throws if the proof is invalid._

### mintNFT

```solidity
function mintNFT(uint256 amount) public payable
```

This function is used to mint a token.

_this function is only callable when the contract is not paused, and the sale is public._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | the amount of tokens to mint. |

### presaleMintNFT

```solidity
function presaleMintNFT(bytes32[] proof, uint256 amount) public payable
```

This function is used to mint a token during the presale period.

_this function is only callable when the contract is not paused, and the sale is presale._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| proof | bytes32[] | the merkle proof to check against the stored root. |
| amount | uint256 | the amount of tokens to mint. |

### reserveTokens

```solidity
function reserveTokens(uint256 amount) external
```

OnlyOwner function to mint tokens.

_this function is only callable by the owner of the contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | the amount of tokens to mint. |

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

### setPresaleMintPrice

```solidity
function setPresaleMintPrice(uint256 _presaleMintPrice) external
```

Onlyowner function to set the mint price for the presale.

_this function is only callable by the owner of the contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _presaleMintPrice | uint256 | the presale mint cost to set. |

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

### setMaxAllowListAmount

```solidity
function setMaxAllowListAmount(uint16 _maxAllowListAmount) external
```

Onlyowner function to set the max amount of tokens that can be minted during the presale.

_this function is only callable by the owner of the contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _maxAllowListAmount | uint16 | the max amount of tokens that can be minted during the presale. |

### togglePaused

```solidity
function togglePaused() external
```

Onlyowner function to set the paused state of the contract.

_this function is only callable by the owner of the contract._

### togglePresale

```solidity
function togglePresale() external
```

Onlyowner function to set the presale state of the contract.

_this function is only callable by the owner of the contract._

### withdrawETH

```solidity
function withdrawETH() external
```

Onlyowner function to withdraw any ETH sent to the contract.

_this function is only callable by the owner of the contract._

### withdrawERC20

```solidity
function withdrawERC20(address _tokenAddr) public
```

Allows owner to withdraw any ERC20 tokens sent to this contract.

_Only Contract Owner can use this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenAddr | address | The address of the ERC20 token. |

### typeOf

```solidity
function typeOf() public pure returns (string)
```

### _startTokenId

```solidity
function _startTokenId() internal view virtual returns (uint256)
```

Internal function to set the starting tokenId.

