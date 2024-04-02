// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { BBB } from "../src/BBB.sol";
import { Shitpost } from "../src/Shitpost.sol";

import "forge-std/src/Script.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is Script {
    // Testnet Constructor args
    string name = "bbb";
    string version = "1";
    address payable protocolFeeRecipient = payable(address(0xfb7C4BAA7ACfb6eBc82cdf7c814850683d549a89)); // TODO CHANGE
        // THIS!!
    address owner = address(0xfb7C4BAA7ACfb6eBc82cdf7c814850683d549a89); // TODO CHANGE THIS!!
    uint256 protocolFeePoints = 50;
    uint256 creatorFeePoints = 50;
    string contractJson = '{"name": "bbb","description": "bbb beautiful. bbb bold. bbb brilliant. Post for free. Earn trading fees. Have fun. Get your bbb at https://bbb.deals","image": "ipfs://QmQ8L9VD5xuFBS1rFV195Mf71E7aRsjXEU9WbchhPA9PFK","banner_image": "ipfs://QmZ443HRoAm56XvLipP2yNMe9rUATAxrXe7XRdEVU5sKeG","featured_image": "ipfs://QmdN9oxCVTTQ2mZgAYm4vTYbuQKDRJE9SUPYgKKcMZVfRt","external_link": "https://bbb.deals"}'; // TODO CHANGE THIS

    function run() public returns (BBB bbb, Shitpost shitpost) {
        uint256 deployerPrivateKey = vm.envUint("BBB_DEPLOYER_PRIVATE_KEY"); // You must have this env var set on your
            // local
            // machine for a PK that has ETH at its first derivation path
            // public address 0xBBB38c30E57a9FEf6068778caB91f1a0D4948BBb
        vm.startBroadcast(deployerPrivateKey);
        // TODO set contract JSON
        bbb = new BBB(owner, protocolFeeRecipient,protocolFeePoints, creatorFeePoints, name, version, contractJson);

        // shitpost = new Shitpost(bbb, protocolFeeRecipient, moderator);
        vm.stopBroadcast();
    }
}
