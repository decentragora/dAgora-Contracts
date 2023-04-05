# Solidity API

## DagoraERC20

a template for creating new ERC20 contracts.

### isPaused

```solidity
bool isPaused
```

Boolean to determine if the contract is paused.

_default value is false, contract is not paused on deployment._

### maxSupply

```solidity
uint256 maxSupply
```

The maximum number of tokens that can be minted.

### constructor

```solidity
constructor(string _name, string _symbol, address _newOwner, uint256 initialSupply, uint256 _maxSupply) public
```

The Contract that will be used to check if the user is a member.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _name | string | The name of the token. |
| _symbol | string | The symbol of the token. |
| _newOwner | address | The address that will be the owner of the contract. |
| initialSupply | uint256 | The initial supply of the token to be minted to the _newOwner. |
| _maxSupply | uint256 | The maximum supply of the token. |

### mint

```solidity
function mint(address to, uint256 amount) external
```

OnlyOwner function to mint tokens.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address that will receive the tokens. |
| amount | uint256 | The amount of tokens to be minted. |

### burn

```solidity
function burn(address from, uint256 amount) external
```

OnlyOwner function to burn tokens.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | The address that will have the tokens burned. |
| amount | uint256 | The amount of tokens to be burned. |

### togglePaused

```solidity
function togglePaused() external
```

OnlyOwner function to toggle the paused state of the contract.

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual
```

check before every token transfer if the contract is paused.

_This function overrides the _beforeTokenTransfer function from the ERC20 contract, and will fail if the contract is paused._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | The address that will send the tokens. |
| to | address | The address that will receive the tokens. |
| amount | uint256 | The amount of tokens to be transferred. |

### typeOf

```solidity
function typeOf() public pure returns (string)
```

Function to get the type of the contract.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string | string The type of the contract. |

### version

```solidity
function version() public pure returns (string)
```

Function to get the version of the contract.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string | string The version of the contract. |

