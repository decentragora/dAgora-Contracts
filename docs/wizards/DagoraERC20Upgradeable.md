# Solidity API

## DagoraERC20UpgradeableImplementation

### isPaused

```solidity
bool isPaused
```

### maxSupply

```solidity
uint256 maxSupply
```

### initialize

```solidity
function initialize(string name, string symbol, address _newOwner, uint256 initialSupply, uint256 _maxSupply) public
```

### mint

```solidity
function mint(address to, uint256 amount) external
```

### burn

```solidity
function burn(address from, uint256 amount) external
```

### togglePaused

```solidity
function togglePaused() external
```

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual
```

_See {ERC20-_beforeTokenTransfer}.

Requirements:

- the contract must not be paused._

