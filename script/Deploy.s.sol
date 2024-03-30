// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { BBB } from "../src/BBB.sol";
import { Shitpost } from "../src/Shitpost.sol";

import "forge-std/src/Script.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is Script {
    // Testnet Constructor args
    string name = "name";
    string version = "1";
    // string uri = "demo_uri";
    address payable protocolFeeRecipient = payable(address(0x2D246F42CD32eB7e8Bd75F9295c8C457C6811d2e)); // TODO CHANGE
        // THIS!!
    address moderator = address(0x2D246F42CD32eB7e8Bd75F9295c8C457C6811d2e); // TODO CHANGE THIS!!
    uint256 protocolFee = 50;
    uint256 creatorFee = 50;

    function run() public returns (BBB bbb, Shitpost shitpost) {
        uint256 deployerPrivateKey = vm.envUint("GOERLI_PRIVATE_KEY"); // You must have this env var set on your local
            // machine for a PK that has ETH at its first derivation path
        vm.startBroadcast(deployerPrivateKey);
        bbb = new BBB(name, version, moderator, protocolFeeRecipient, protocolFee, creatorFee);
        shitpost = new Shitpost(bbb, protocolFeeRecipient, moderator);
        vm.stopBroadcast();
    }
}
