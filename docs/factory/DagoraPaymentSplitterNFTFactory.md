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

## DagoraFactory__FailedToCreateContract

```solidity
error DagoraFactory__FailedToCreateContract()
```

## DagoraPaymentSplitterFactory

### NFTParams

```solidity
struct NFTParams {
  string name;
  string symbol;
  address[] payees;
  uint256[] shares;
  uint256 mintPrice;
  uint256 maxSupply;
  uint16 bulkBuyLimit;
  string baseURI;
  string baseExtension;
  address newOwner;
}
```
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

### minTier

```solidity
uint8 minTier
```

The minimum tier required to create a NFTAPlus contract.

### contractsDeployed

```solidity
uint256 contractsDeployed
```

the count of all the contracts deployed by the factory

### PaymentSplitterCreated

```solidity
event PaymentSplitterCreated(address newContractAddress, address ownerOf)
```

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

### createNFT

```solidity
function createNFT(struct DagoraPaymentSplitterFactory.NFTParams params, uint256 id) public returns (address newImplementation)
```

### getUserContracts

```solidity
function getUserContracts(address _user) external view returns (address[])
```

Function that returns the deployed contracts by a user.

### togglePaused

```solidity
function togglePaused() external
```

onlyOwner function to set the paused state of the contract.

### setMinTier

```solidity
function setMinTier(uint8 _minTier) external
```

onlyOwner function to set the minimum tier required to create a contract.

### paymentSharesTotal

```solidity
function paymentSharesTotal(uint256[] shares_) internal pure returns (uint256)
```

### createNFTImpl

```solidity
function createNFTImpl(struct DagoraPaymentSplitterFactory.NFTParams params, bytes32 salt) internal returns (address)
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

