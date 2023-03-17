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
event MintCostChanged(uint256 mintCost)
```

### BulkBuyLimitChanged

```solidity
event BulkBuyLimitChanged(uint256 bulkBuyLimit)
```

### MaxTotalSupplyChanged

```solidity
event MaxTotalSupplyChanged(uint256 maxTotalSupply)
```

### PausedToggled

```solidity
event PausedToggled(bool paused)
```

### constructor

```solidity
constructor(string name_, string symbol_, string __baseURI, uint16 _bulkBuyLimit, uint256 _mintPrice, uint256 _maxSupply, address _newOwner) public
```

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

### reserveTokens

```solidity
function reserveTokens(uint256 amount) public
```

### tokenURI

```solidity
function tokenURI(uint256 tokenId) public view returns (string)
```

_Returns the Uniform Resource Identifier (URI) for `tokenId` token._

### setBaseURI

```solidity
function setBaseURI(string _baseURI) public
```

### setBaseExtension

```solidity
function setBaseExtension(string _baseExtension) public
```

### setMintPrice

```solidity
function setMintPrice(uint256 _mintPrice) public
```

### setBulkBuyLimit

```solidity
function setBulkBuyLimit(uint16 _bulkBuyLimit) public
```

### togglePaused

```solidity
function togglePaused() public
```

### withdrawETH

```solidity
function withdrawETH() public
```

### withdrawERC20

```solidity
function withdrawERC20(address token) public
```

### typeOf

```solidity
function typeOf() public pure returns (string)
```

### _startTokenId

```solidity
function _startTokenId() internal pure returns (uint256)
```

_Returns the starting token ID.
To change the starting token ID, please override this function._

