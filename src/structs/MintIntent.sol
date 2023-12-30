// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// Struct to hold minting data
struct MintIntent {
    address creator; // The creator fee beneficiary
    address signer; // The "large blob" signer
    address priceModel; // The price curve
    string uri; // The ipfs metadata digest
}
