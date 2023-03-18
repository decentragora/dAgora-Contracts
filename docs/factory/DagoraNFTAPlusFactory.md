# Solidity API

## DagoraFactory__TokenCreationPaused

```solidity
error DagoraFactory__TokenCreationPaused()
```

## DagoraFactory__InvalidTier

```solidity
error DagoraFactory__InvalidTier(uint8 tier, uint8 neededTier)
```

## DagoraFactory__NotDAgoraMembershipsOwnerOrDelegate

```solidity
error DagoraFactory__NotDAgoraMembershipsOwnerOrDelegate()
```

## DagoraFactory__ExpiredMembership

```solidity
error DagoraFactory__ExpiredMembership()
```

## DagoraNFTAPlusFactory

### isPaused

```solidity
bool isPaused
```

Boolean to determine if the contract is paused.

_default value is false, contract is not paused on deployment._

### dAgoraMembershipsAddress

```solidity
address dAgoraMembershipsAddress
```

The address of the dAgoraMemberships contract.

### minNFTAPlusTier

```solidity
uint8 minNFTAPlusTier
```

The minimum tier required to create a NFTAPlus contract.

### contractsDeployed

```solidity
uint256 contractsDeployed
```

the count of all the contracts deployed by the factory

### NFTAPlusCreated

```solidity
event NFTAPlusCreated(address newContractAddress, address ownerOF)
```

The event emitted when a NFTAPlus contract is created.

### userContracts

```solidity
mapping(address => address[]) userContracts
```

### initialize

```solidity
function initialize(address _dAgoraMembershipsAddress) public
```

### isNotPaused

```solidity
modifier isNotPaused()
```

Modifier to check if the contract is paused.

_Reverts if the contract is paused._

### canCreate

```solidity
modifier canCreate(uint256 tokenId, uint8 neededTier)
```

Modifier to check if the user can create a contract.

_Reverts if the user membership tier is not high enough, if the membership is expired, and if the user is not owner of tokenId._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The id of the users membership tokenId. |
| neededTier | uint8 | The tier required to create the Contract. |

### createNFTAPlus

```solidity
function createNFTAPlus(string name_, string symbol_, string baseURI_, uint16 _bulkBuyLimit, uint16 _maxAllowListAmount, uint256 _mintCost, uint256 _presaleMintCost, uint256 _maxTotalSupply, address _newOwner, bytes32 _merkleRoot, uint256 _id) public
```

Function to create a NFTAPlus contract.

_Creates a NFTAPlus contract using the Create2Upgradeable library._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name_ | string | The name of the NFTAPlus contract. |
| symbol_ | string | The symbol of the NFTAPlus contract. |
| baseURI_ | string | The baseURI of the NFTAPlus contract. |
| _bulkBuyLimit | uint16 | The bulk buy limit of the NFTAPlus contract. |
| _maxAllowListAmount | uint16 | The max allow list amount of the NFTAPlus contract. |
| _mintCost | uint256 | The mint cost of the NFTAPlus contract. |
| _presaleMintCost | uint256 | The presale mint cost of the NFTAPlus contract. |
| _maxTotalSupply | uint256 | The max total supply of the NFTAPlus contract. |
| _newOwner | address | The new owner of the NFTAPlus contract. |
| _merkleRoot | bytes32 | The merkle root of the NFTAPlus contract. |
| _id | uint256 | The id of the users membership tokenId. |

### getUserContracts

```solidity
function getUserContracts(address _user) external view returns (address[])
```

### togglePaused

```solidity
function togglePaused() external
```

### setMinNFTAPlusTier

```solidity
function setMinNFTAPlusTier(uint8 _minNFTAPlusTier) external
```

### _canCreate

```solidity
function _canCreate(uint256 _id, uint8 _neededTier) internal view returns (bool)
```

Internal function that checks if a address owns or is a delegate of a membership, and if the membership is valid, and if the membership tier is high enough.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _id | uint256 | The id of the users membership tokenId. |
| _neededTier | uint8 | The minimum membership tier required to create a contract. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | bool True or False. |

