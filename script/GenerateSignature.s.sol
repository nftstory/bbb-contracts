// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import "../src/BBB.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { EIP712_DOMAIN } from "../src/structs/MintIntent.sol";
import "forge-std/src/Script.sol";

// Generate Mint Intent signatures that can be used against deployed instances of BBB
contract Deploy is Script {
    // ⬇️ Mutate me based on where you deployed the contract ⬇️
    uint256 chainId = 5; // Chain to which the contract is deployed
    BBB bbb = BBB(payable(0x0fce7123af19C45dDb1c2a938dA74c1CF665ab04)); // Address of the deployed contract
    // ⬆️

    string name = "name";
    string version = "1";

    // Test to generate sigs to use mint with the contract deployed on Goerli (5)
    function run() external {
        // Spoof the values of the actually deployed contract
        vm.chainId(chainId);

        MintIntent memory data = MintIntent({
            creator: 0x2D246F42CD32eB7e8Bd75F9295c8C457C6811d2e,
            signer: 0x2D246F42CD32eB7e8Bd75F9295c8C457C6811d2e,
            priceModel: 0x2617da7E45E19d61d6075c2cCfA77e0380eF71e2, // pulled from testnet deploy logs
            uri: "ipfs://bafybeic5yjh7ivn5og3upzw4ouz2s2no5vouayaglgxcg5jrc63s2wh2pe/48.json"
        });

        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(vm.envUint("GOERLI_PRIVATE_KEY"), data);
        bytes memory signature = toBytesSignature(v, r, s);
        console2.logBytes(signature);
    }

    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function toBytesSignature(uint8 v, bytes32 r, bytes32 s) public pure returns (bytes memory) {
        return abi.encodePacked(r, s, v);
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(
            abi.encode(EIP712_DOMAIN, keccak256(bytes(name)), keccak256(bytes(version)), block.chainid, address(bbb))
        );
    }

    function getSignatureAndDigest(
        uint256 privateKey,
        MintIntent memory data
    )
        public
        view
        returns (uint8, bytes32, bytes32, bytes32)
    {
        bytes32 digest = MessageHashUtils.toTypedDataHash(
            _buildDomainSeparator(),
            keccak256(
                abi.encode(
                    MINT_INTENT_TYPE_HASH, data.creator, data.signer, data.priceModel, keccak256(bytes(data.uri))
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        return (v, r, s, digest);
    }
}
