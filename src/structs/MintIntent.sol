// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// Struct
struct MintIntent {
    address creator; // The creator fee beneficiary
    address signer; // The "large blob" signer
    address priceModel; // The price curve
    string uri; // The ipfs metadata digest
}

// Encode Type
bytes constant MINT_INTENT_ENCODE_TYPE = "MintIntent(address creator,address signer,address priceModel,string uri)";

// Typehash
bytes32 constant MINT_INTENT_TYPE_HASH = keccak256(MINT_INTENT_ENCODE_TYPE);

// EIP712 Domain
bytes32 constant EIP712_DOMAIN = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
