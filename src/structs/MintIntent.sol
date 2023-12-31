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
