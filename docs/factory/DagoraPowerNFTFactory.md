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

## DagoraPowerNFTFactory

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

### minPowerNFTATier

```solidity
uint8 minPowerNFTATier
```

The minimum tier required to create a Power NFT contract.

### contractsDeployed

```solidity
uint256 contractsDeployed
```

the count of all the contracts deployed by the factory

### PowerNFTACreated

```solidity
event PowerNFTACreated(address newContractAddress, address ownerOF)
```

The event emitted when a PowerNFTA contract is created.

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

### createPowerNFT

```solidity
function createPowerNFT(string name_, string symbol_, string baseURI_, uint16 _bulkBuyLimit, uint96 _royaltyBps, uint256 _mintCost, uint256 _maxSupply, address _royaltyRecipient, address _newOwner, uint256 _id) public
```

Function to create a PowerNFTA contract.

_Creates a PowerNFTA contract, and emits an event._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name_ | string | The name of the contract. |
| symbol_ | string | The symbol of the contract. |
| baseURI_ | string | The baseURI of the contract. |
| _bulkBuyLimit | uint16 | The bulk buy limit of the contract. |
| _royaltyBps | uint96 | The royalty bps of the contract. |
| _mintCost | uint256 | The mint cost of the contract. |
| _maxSupply | uint256 | The max total supply of the contract. |
| _royaltyRecipient | address | The royalty recipient of the contract. |
| _newOwner | address | The new owner of the contract. |
| _id | uint256 | The id of the users membership tokenId. |

### getUserContracts

```solidity
function getUserContracts(address _user) external view returns (address[])
```

### togglePaused

```solidity
function togglePaused() external
```

### setMinPowerNFTATier

```solidity
function setMinPowerNFTATier(uint8 _minPowerNFTATier) external
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

