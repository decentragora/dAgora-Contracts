# dAgoraPowerPlusNFTFactory

PowerPlusNFT Factory

Allows dAgora members to create new PowerPlusNFT contracts.

## Variables

### nft

```solidity
contract PowerPlusNFT nft
```

### dAgoraMembership

```solidity
address dAgoraMembership
```

The address of the dAgora Memberships contract.

### powerPlusNFTCount

```solidity
uint256 powerPlusNFTCount
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

### createPowerPlusNFT

```solidity
function createPowerPlusNFT(
    string _name,
    string _symbol,
    string _baseURI,
    uint256 _mintCost,
    uint16 _bulkBuyLimit,
    uint16 _maxWhiteListAmount,
    uint256 _maxTotalSupply,
    uint96 _royaltyCut,
    address _newOwner,
    address _royaltyReceiver,
    bytes32 _merkleRoot
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
| `_maxWhiteListAmount` | uint16 | The max amount of NFTs that can be minted by allow listed addresses. |
| `_maxTotalSupply` | uint256 |  |
| `_royaltyCut` | uint96 | The % of royalties to be paid to the creator. |
| `_newOwner` | address | The address of the new owner. |
| `_royaltyReceiver` | address | The address to receive royalties. |
| `_merkleRoot` | bytes32 | The merkle root of the allowed list addresses. |

### deployedContracts

```solidity
function deployedContracts(
    address _owner
) public returns (struct dAgoraPowerPlusNFTFactory.Deploys)
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

## Events

### PowerPlusNFTCreated

```solidity
event PowerPlusNFTCreated(
    address powerPlusContract,
    address owner,
    uint256 _contractId,
    uint256 _powerPlusNFTCount
)
```

Emitted when a new NFT contract is deployed.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `powerPlusContract` | address | The address of the deployed contract. |
| `owner` | address | The address of the owner. |
| `_contractId` | uint256 | Users total amount of deployed contracts. |
| `_powerPlusNFTCount` | uint256 | The total amount of NFTs created for members. |

## Custom types

### Deploys

```solidity
struct Deploys {
  address[] ContractAddress;
  address Owner;
  uint256 contractId;
}
```

