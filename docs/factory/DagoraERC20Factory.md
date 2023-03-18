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

## DagoraERC20Factory

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

### minERC20Tier

```solidity
uint8 minERC20Tier
```

The minimum tier required to create a NFTAPlus contract.

### contractsDeployed

```solidity
uint256 contractsDeployed
```

the count of all the contracts deployed by the factory

### DagoraERC20Created

```solidity
event DagoraERC20Created(address newContractAddress, address ownerOF)
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

### createDagoraERC20

```solidity
function createDagoraERC20(string name_, string symbol_, address _newOwner, uint256 initialSupply, uint256 _maxSupply, uint256 _id) public
```

Function to create a new DagoraERC20 contract.

_Creates a new DagoraERC20 contract, and emits a DagoraERC20Created event._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name_ | string | The name of the new DagoraERC20 contract. |
| symbol_ | string | The symbol of the new DagoraERC20 contract. |
| _newOwner | address | The address of the new owner of the new DagoraERC20 contract. |
| initialSupply | uint256 | The initial supply of the new DagoraERC20 contract. |
| _maxSupply | uint256 | The max supply of the new DagoraERC20 contract. |
| _id | uint256 | The id of the users membership tokenId. |

### getUserContracts

```solidity
function getUserContracts(address _user) external view returns (address[])
```

### togglePaused

```solidity
function togglePaused() external
```

### setMinERC20Tier

```solidity
function setMinERC20Tier(uint8 _minTier) external
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

