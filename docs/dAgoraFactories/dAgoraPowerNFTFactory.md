# dAgoraPowerNFTFactory

PowerNFT Factory

Allows dAgora members to create new PowerNFT contracts.

## Variables

### nft

```solidity
contract PowerNFT nft
```

### dAgoraMembership

```solidity
address dAgoraMembership
```

The address of the dAgora Memberships contract.

### powerNFTCount

```solidity
uint256 powerNFTCount
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

### createPowerNFT

```solidity
function createPowerNFT(
    string _name,
    string _symbol,
    string _baseURI,
    uint256 _mintCost,
    uint16 _bulkBuyLimit,
    uint256 _maxTotalSupply,
    uint96 _royaltyCut,
    address _newOwner,
    address _royaltyReceiver
) public
```

Function to create contracts for members.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_name` | string | The name of the NFT. |
| `_symbol` | string | The symbol of the NFT. |
| `_baseURI` | string | The base URI of the NFT. |
| `_mintCost` | uint256 | The cost to mint a NFT. |
| `_bulkBuyLimit` | uint16 | the max amount of NFTs that can be minted at once. |
| `_maxTotalSupply` | uint256 | The max amount of NFTs that can be minted. |
| `_royaltyCut` | uint96 | The % of royalties to be paid to the creator. |
| `_newOwner` | address | The address to receive royalties. |
| `_royaltyReceiver` | address | The address to receive royalties. |

### deployedContracts

```solidity
function deployedContracts(
    address _owner
) public returns (struct dAgoraPowerNFTFactory.Deploys)
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
function _canCreate() internal returns (bool)
```

Function to check if a user is a valid member & can create NFT contracts.

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

### PowerNFTCreated

```solidity
event PowerNFTCreated(
    address _powerNFTContract,
    address _owner,
    uint256 _contractId,
    uint256 _powerNFTCount
)
```

Emitted when a new NFT contract is deployed.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_powerNFTContract` | address | The address of the deployed contract. |
| `_owner` | address | The address of the owner. |
| `_contractId` | uint256 | Users total amount of deployed contracts. |
| `_powerNFTCount` | uint256 | The total amount of NFTs created for members. |

## Custom types

### Deploys

```solidity
struct Deploys {
  address[] ContractAddress;
  address Owner;
  uint256 contractId;
}
```

