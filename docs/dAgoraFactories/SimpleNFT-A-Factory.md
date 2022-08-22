# dAgoraSimpleNFTAFactory

dAgora Simple NFT A Factory

Used to create new Simple NFT A contracts for dAgora members.

## Variables

### nfta

```solidity
contract SimpleNFTA nfta
```

### dAgoraMembership

```solidity
address dAgoraMembership
```

The address of the dAgora Memberships contract.

### totalNftACount

```solidity
uint256 totalNftACount
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

### createNFT

```solidity
function createNFT(
    string _name,
    string _symbol,
    string _baseURI,
    uint256 _mintCost,
    uint256 _bulkBuyLimit,
    uint256 _maxTotalSupply,
    address _newOwner
) public
```

Function to create contracts for members.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_name` | string | The name of the NFT. |
| `_symbol` | string | The symbol of the NFT. |
| `_baseURI` | string | The base URI of the NFT. |
| `_mintCost` | uint256 | The cost of minting an NFT. |
| `_bulkBuyLimit` | uint256 | the max amount of NFTs that can be minted at once. |
| `_maxTotalSupply` | uint256 | The max supply of the NFT. |
| `_newOwner` | address | The address of the new owner of deployed contract. |

### deployedContracts

```solidity
function deployedContracts(
    address _owner
) public returns (struct dAgoraSimpleNFTAFactory.Deploys)
```

Function to check users deployed contract addresses.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_owner` | address | The address of the user we want to check. |

### togglePause

```solidity
function togglePause() public
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

### SimpleNFTACreated

```solidity
event SimpleNFTACreated(
    address _nftContract,
    address _owner,
    uint256 _UserDeployCount,
    uint256 _totalNftACount
)
```

Emitted when a new NFT A contract is deployed.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_nftContract` | address | The address of the deployed contract. |
| `_owner` | address | The address of the owner. |
| `_UserDeployCount` | uint256 | Users total amount of deployed contracts. |
| `_totalNftACount` | uint256 | The total amount of NFTs created for members. |

## Custom types

### Deploys

```solidity
struct Deploys {
  address[] ContractAddress;
  address Owner;
  uint256 nftAIndex;
}
```

