# dAgoraBasicNFTPlusFactory

dAgora Basic NFT Plus Factory

Used to create new Basic NFT Plus contracts for dAgora members.

## Variables

### nft

```solidity
contract BasicNFTPlus nft
```

### dAgoraMembership

```solidity
address dAgoraMembership
```

The address of the dAgora Memberships contract.

### basicNFTPlusCount

```solidity
uint256 basicNFTPlusCount
```

The total count of NFTs created for members..

### paused

```solidity
bool paused
```

Used to pause and unpause the contract.

### _addressDeployCount

```solidity
mapping(address => uint256) _addressDeployCount
```

Tracks users deployed contracts amount.

## Functions

### constructor

```solidity
constructor(
    address _dAgoraMembership
) 
```

Sets the contracts variables.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_dAgoraMembership` | address | The address of the dAgora Memberships contract. |

### createBasicNFTPlus

```solidity
function createBasicNFTPlus(
    string _name,
    string _symbol,
    string _baseURI,
    uint256 _mintCost,
    uint16 _bulkBuyLimit,
    uint16 _maxAllowListAmount,
    uint256 _maxTotalSupply,
    uint256 _id,
    address _newOwner,
    bytes32 _merkleRoot
) public
```

Deploys a new NFT contract for the user.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_name` | string | The name of the NFT. |
| `_symbol` | string | The symbol of the NFT. |
| `_baseURI` | string | The base URI of the NFT. |
| `_mintCost` | uint256 | The Mint cost of a NFT. |
| `_bulkBuyLimit` | uint16 | the max amount of NFTs that can be minted at once. |
| `_maxAllowListAmount` | uint16 | The max amount of NFTs that can be minted by the allow list. |
| `_maxTotalSupply` | uint256 | The max supply of the NFT. |
| `_id` | uint256 | The tokenId of dAgora Membership. |
| `_newOwner` | address | The address of the new owner. |
| `_merkleRoot` | bytes32 | The merkle root of the allowed list addresses. |

### deployedContracts

```solidity
function deployedContracts(
    address _owner
) public returns (struct dAgoraBasicNFTPlusFactory.Deploys)
```

Function to check users deployed contract addresses.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_owner` | address | The address of the user we want to check. |

### togglePaused

```solidity
function togglePaused() public
```

Function allows owner to pause/unPause the contract.

### _canCreate

```solidity
function _canCreate(
    uint256 _id
) internal returns (bool)
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_id` | uint256 |  |

## Modifiers

### isPaused

```solidity
modifier isPaused()
```

Checks if the contract is paused.

_This modifier is used to prevent users from deploying contracts while the contract is paused._

## Events

### BasicNFTPlusCreated

```solidity
event BasicNFTPlusCreated(
    address _basicNFTPlusContract,
    address _owner,
    uint256 _contractId,
    uint256 _basicNFTPlusCount
)
```

Emitted when a new NFT contract is deployed.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_basicNFTPlusContract` | address | The address of the deployed contract. |
| `_owner` | address | The address of the owner. |
| `_contractId` | uint256 | Users total amount of deployed contracts. |
| `_basicNFTPlusCount` | uint256 | The total amount of NFTs created for members. |

## Custom types

### Deploys

```solidity
struct Deploys {
  address[] ContractAddress;
  address Owner;
  uint256 contractId;
}
```

