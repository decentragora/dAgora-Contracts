interface IAttestationStation {

    struct AttestationData {
        address about;
        bytes32 key;
        bytes val;
    }

  function attest ( AttestationData[] calldata _attestations ) external;
  function attest ( address _about, bytes32 _key, bytes calldata _val ) external;
  function attestations ( address, address, bytes32 ) external view returns ( bytes memory);
  function version (  ) external view returns ( string memory);
}
