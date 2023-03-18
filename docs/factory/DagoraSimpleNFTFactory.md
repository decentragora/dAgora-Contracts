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

## DagoraSimpleNFTFactory

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

### minSimpleNFTATier

```solidity
uint8 minSimpleNFTATier
```

The minimum tier required to create a SimpleNFTA contract.

### contractsDeployed

```solidity
uint256 contractsDeployed
```

the count of all the contracts deployed by the factory

### SimpleNFTACreated

```solidity
event SimpleNFTACreated(address newContractAddress, address ownerOF)
```

The event emitted when a SimpleNFTA contract is created.

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

### createSimpleNFTA

```solidity
function createSimpleNFTA(string _name, string _symbol, string _baseURI, uint16 _bulkBuyLimit, uint256 _mintCost, uint256 _maxSupply, address _newOwner, uint256 _id) public
```

Function to create a SimpleNFTA contract.

_Creates a SimpleNFTA contract, and adds the address to the users contracts array._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _name | string | The name of the SimpleNFTA contract. |
| _symbol | string | The symbol of the SimpleNFTA contract. |
| _baseURI | string | The baseURI of the SimpleNFTA contract. |
| _bulkBuyLimit | uint16 | The bulk buy limit of the SimpleNFTA contract. |
| _mintCost | uint256 | The mint cost of the SimpleNFTA contract. |
| _maxSupply | uint256 | The max supply of the SimpleNFTA contract. |
| _newOwner | address | The address of the new owner of the SimpleNFTA contract. |
| _id | uint256 | The id of the users membership tokenId. |

### getUserContracts

```solidity
function getUserContracts(address _user) external view returns (address[])
```

### togglePaused

```solidity
function togglePaused() external
```

### setMinSimpleNFTATier

```solidity
function setMinSimpleNFTATier(uint8 _minSimpleNFTATier) external
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

