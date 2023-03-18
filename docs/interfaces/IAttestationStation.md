# Solidity API

## IAttestationStation

### AttestationData

```solidity
struct AttestationData {
  address about;
  bytes32 key;
  bytes val;
}
```
### attest

```solidity
function attest(struct IAttestationStation.AttestationData[] _attestations) external
```

### attest

```solidity
function attest(address _about, bytes32 _key, bytes _val) external
```

### attestations

```solidity
function attestations(address, address, bytes32) external view returns (bytes)
```

### version

```solidity
function version() external view returns (string)
```

