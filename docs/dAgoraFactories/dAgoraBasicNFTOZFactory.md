# dAgoraBasicNFTOZFactory

dAgora Basic NFT OZ Factory

Used to create new Basic NFT OZ contracts for dAgora members.

## Variables

### nft

```solidity
contract BasicNFTOZ nft
```

### dAgoraMembership

```solidity
address dAgoraMembership
```

The address of the dAgora Memberships contract.

### basicNFTCount

```solidity
uint256 basicNFTCount
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

### createBasicNFT

```solidity
function createBasicNFT(
    string _name,
    string _symbol,
    string _baseURI,
    uint256 _mintCost,
    uint16 _bulkBuyLimit,
    uint256 _maxTotalSupply,
    uint256 _id,
    address _newOwner
) public
```

Deploys a new Basic NFT contract for the user.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_name` | string | The name of the NFT. |
| `_symbol` | string | The symbol of the NFT. |
| `_baseURI` | string | The base URI of the NFT. |
| `_mintCost` | uint256 | The Mint cost of a NFT. |
| `_bulkBuyLimit` | uint16 | the max amount of NFTs that can be minted at once. |
| `_maxTotalSupply` | uint256 | The max supply of the NFT. |
| `_id` | uint256 | The tokenId of dAgora Membership. |
| `_newOwner` | address | The address of the new owner. |

### deployedContracts

```solidity
function deployedContracts(
    address _owner
) public returns (struct dAgoraBasicNFTOZFactory.Deploys)
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_owner` | address |  |

### pause

```solidity
function pause() public
```

### unpause

```solidity
function unpause() public
```

### _canCreate

```solidity
function _canCreate(
    uint256 _id
) internal returns (bool)
```

Function to check if a user is a valid member & can create NFT contracts.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_id` | uint256 | The tokenId of the NFT. |

#### Return Values

| Name | Type | Description |
| :--- | :--- | :---------- |
| `[0]` | bool | boolean |

## Modifiers

### isPaused

```solidity
modifier isPaused()
```

Checks if the contract is paused.

_This modifier is used to prevent users from deploying contracts while the contract is paused._

## Events

### BasicNFTCreated

```solidity
event BasicNFTCreated(
    address basicNFTContract,
    address owner,
    uint256 _contractId,
    uint256 _basicNFTCount
)
```

Emitted when a new NFT contract is deployed.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `basicNFTContract` | address | The address of the deployed contract. |
| `owner` | address | The address of the owner. |
| `_contractId` | uint256 | Users total amount of deployed contracts. |
| `_basicNFTCount` | uint256 | The total amount of NFTs created for members. |

## Custom types

### Deploys

```solidity
struct Deploys {
  address[] ContractAddress;
  address Owner;
  uint256 contractId;
}
```

