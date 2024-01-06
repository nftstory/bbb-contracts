// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import { BBB } from "../src/BBB.sol";
import { MintIntent, MINT_INTENT_ENCODE_TYPE, MINT_INTENT_TYPE_HASH } from "../src/structs/MintIntent.sol";

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
/// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
/// https://book.getfoundry.sh/forge/writing-tests

contract BBBTest is PRBTest, StdCheats {
    BBB bbb;

    // Constructor arguments
    string name = "name";
    string version = "1";
    string uri = "demo_uri";
    uint256 protocolFee = 50;
    uint256 creatorFee = 50;

    // Accounts needed for tests
    address moderator = makeAddr("moderator");
    address payable protocolFeeRecipient = payable(makeAddr("protocolFeeRecipient"));
    address creator = makeAddr("creator");
    address buyer = makeAddr("buyer");
    // address signer = 0xF4ef37a4EcA1DeCB0E62482590b3D4Fc7f1214ec;
    address signer;
    // bytes32 signerPk = 0xf9fc766a27e844ad50c0e567e921d5d2cb661560d2bd2421f3db0c0f0a8e4364;
    // uint256 signerPk = 113071962025583480559611482528073794879019954380499915552367164943375860122468;
    uint256 signerPk;
    address priceModel = makeAddr("priceModel"); // TODO replace with an actual priceCurve

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        // Assign signer an address and pk
        (signer, signerPk) = makeAddrAndKey("signer");
        console2.log(signer);
        console2.log(signerPk);
        // Instantiate the contract-under-test.
        bbb = new BBB(name, version, uri, moderator, protocolFeeRecipient, protocolFee, creatorFee, priceModel);

        // Deal ETH to the buyer
        deal(buyer, 2 ether);
    }

    function test_roles_assigned_correctly() external {
        // Assert that DEFAULT_ADMIN_ROLE is assigned to address(0)
        assertEq(abi.encode(bbb.getRoleAdmin(bytes32(keccak256("DEFAULT_ADMIN_ROLE")))), abi.encode(address(0)));
        // Another way to test the same thing
        assertEq(
            bbb.getRoleAdmin(bytes32(keccak256("DEFAULT_ADMIN_ROLE"))), bytes32(uint256(uint160(address(0))) << 96)
        );
        // Assert that MODERTOR_ROLE has no admin
        assertEq(abi.encode(bbb.getRoleAdmin(bytes32(keccak256("MODERATOR_ROLE")))), abi.encode(address(0)));
        // Assert that moderator has MODERATOR_ROLE
        assertEq(bbb.hasRole(bytes32(keccak256("MODERATOR_ROLE")), moderator), true);
        // Assert that this test contract does not have DEFAULT_ADMIN_ROLE
        assertEq(bbb.hasRole(bytes32(keccak256("DEFAULT_ADMIN_ROLE")), address(this)), false);
        // Assert that BBB does not have DEFAULT_ADMIN_ROLE
        assertEq(bbb.hasRole(bytes32(keccak256("DEFAULT_ADMIN_ROLE")), address(bbb)), false);
    }

    // Example signature recovery test from Forge vm.sign
    // https://book.getfoundry.sh/cheatcodes/sign
    function test_sign_vrs() external {
        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(signerPk, MintIntent({ creator: creator, signer: signer, priceModel: priceModel, uri: uri }));

        // Recover signer address
        address recoveredSigner = ECDSA.recover(digest, v, r, s);
        // address recoveredSigner = ecrecover(hash, v, r, s);
        assertEq(signer, recoveredSigner); // [PASS]
    }

    function test_sign_signature() external {
        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(signerPk, MintIntent({ creator: creator, signer: signer, priceModel: priceModel, uri: uri }));
        bytes memory signature = toBytesSignature(v, r, s);
        // Recover signer address
        address recoveredSigner = ECDSA.recover(digest, signature);
        // address recoveredSigner = ecrecover(hash, v, r, s);
        assertEq(signer, recoveredSigner); // [PASS]
    }

    function test_mint_with_intent() external {
        console2.log("Signer address: ", signer);
        // console2.log("signer pk: ", signerPk);
        console2.log("Buyer address: ", buyer);
        console2.log("priceModel:", priceModel);
        console2.log("creator:", creator);
        console2.log("chainid: ", block.chainid);
        uint256 amount = 1;
        uint256 value = 1 ether;

        MintIntent memory data = MintIntent({ creator: creator, signer: signer, priceModel: priceModel, uri: uri });

        // Create the digest of the MintIntent. We recreate this here manually because the contract-under-test uses it's
        // inherited EIP712 to do this logic, and it's functions and vars are internal and private.
        // bytes32 bbbDomainSeparator = keccak256(
        //     abi.encode(
        //         hex"0f", // 01111
        //         keccak256(bytes(name)),
        //         keccak256(bytes(version)),
        //         block.chainid,
        //         address(bbb)
        //     )
        // );

        // bytes32 digest = MessageHashUtils.toTypedDataHash(
        //     bbb.domainSeparatorV4(),
        //     keccak256(
        //         abi.encode(
        //             MINT_INTENT_TYPE_HASH, data.creator, data.signer, data.priceModel, keccak256(bytes(data.uri))
        //         )
        //     )
        // );

        // Sign the digest with the signer's PK
        // (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        // uint8 v = 0x1c;
        // bytes32 r = 0xa8677e87669efd4d04e2ae37d9b902de3f126d10a231752a7990f5b3e0a37baa;
        // bytes32 s = 0x4d11d4854c68eee87beb81056692b0ff85f51c00d8aa62f0246aa419d5ee6862;

        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(signerPk, data);
        bytes memory signature = toBytesSignature(v, r, s);

        (address intentSigner, ECDSA.RecoverError err, bytes32 info) = ECDSA.tryRecover(digest, signature); // TODO
        assertEq(intentSigner, signer);
        // Become the buyer
        vm.startPrank(buyer);
        // Mint with intent
        bbb.mintWithIntent{ value: value }(data, 1, signature);
        vm.stopPrank();
    }

    /**
     * function test_mintWithIntent() external {
     *     // MintIntent memory intent = MintIntent({
     *     //     creator: creator, // The creator fee beneficiary
     *     //     signer: signer, // The "large blob" signer
     *     //     priceModel: priceModel, // The price curve
     *     //     uri: uri // The ipfs metadata digest
     *     //  });
     *
     *     // (, string memory name, string memory version, uint256 chainId, address verifyingContract,,) =
     *     // bbb.eip712Domain(); // Fetch domain from the contract
     *
     *     string[] memory inputs = new string[](7);
     *     inputs[0] = "node test/js-helpers/signData.js";
     *     inputs[1] = name;
     *     inputs[2] = version;
     *     inputs[3] = vm.toString(block.chainid);
     *     inputs[4] = vm.toString(address(bbb));
     *     inputs[5] = vm.toString(creator);
     *     inputs[6] = vm.toString(priceModel);
     *
     *     // Call signData.js (via FFI) and pass BBB constructor args to generate the signature we'll verify in the
     * next
     *     // step
     *     bytes memory signature = vm.ffi(inputs);
     *
     *     // Extract v, r, s components from the signature
     *     bytes32 r;
     *     bytes32 s;
     *     uint8 v;
     *     assembly {
     *         r := mload(add(signature, 32))
     *         s := mload(add(signature, 64))
     *         v := byte(0, mload(add(signature, 96)))
     *     }
     *
     *     // MintIntent struct data
     *     MintIntent memory intent = MintIntent({
     *         creator: creator,
     *         signer: signer, // TODO confirm this is right value to pass
     *         priceModel: priceModel,
     *         uri: uri
     *     });
     *
     *     // Call the mintWithIntent function
     *     bbb.mintWithIntent(intent, 1, v, r, s);
     *
     *     // Assertions to verify the test results
     * }
     */

    // /// @dev Basic test. Run it with `forge test -vvv` to see the console log.
    // function test_Example() external {
    //     console2.log("Hello World");
    //     uint256 x = 42;
    //     assertEq(foo.id(x), x, "value mismatch");
    // }

    // /// @dev Fuzz test that provides random values for an unsigned integer, but which rejects zero as an input.
    // /// If you need more sophisticated input validation, you should use the `bound` utility instead.
    // /// See https://twitter.com/PaulRBerg/status/1622558791685242880
    // function testFuzz_Example(uint256 x) external {
    //     vm.assume(x != 0); // or x = bound(x, 1, 100)
    //     assertEq(foo.id(x), x, "value mismatch");
    // }

    // /// @dev Fork test that runs against an Ethereum Mainnet fork. For this to work, you need to set
    // `API_KEY_ALCHEMY`
    // /// in your environment You can get an API key for free at https://alchemy.com.
    // function testFork_Example() external {
    //     // Silently pass this test if there is no API key.
    //     string memory alchemyApiKey = vm.envOr("API_KEY_ALCHEMY", string(""));
    //     if (bytes(alchemyApiKey).length == 0) {
    //         return;
    //     }

    //     // Otherwise, run the test against the mainnet fork.
    //     vm.createSelectFork({ urlOrAlias: "mainnet", blockNumber: 16_428_000 });
    //     address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    //     address holder = 0x7713974908Be4BEd47172370115e8b1219F4A5f0;
    //     uint256 actualBalance = IERC20(usdc).balanceOf(holder);
    //     uint256 expectedBalance = 196_307_713.810457e6;
    //     assertEq(actualBalance, expectedBalance);
    // }


    // ChatGPT4
    function toBytesSignature(uint8 v, bytes32 r, bytes32 s) public pure returns (bytes memory) {
        return abi.encodePacked(r, s, v);
    }


    function getSignatureAndDigest(
            uint256 privateKey,
            MintIntent memory data
        )
            public
            view
            // returns (bytes memory)
            returns (uint8, bytes32, bytes32, bytes32)
        {
            // uint256 nonce = 0;
            // bytes32 hashStruct = keccak256(abi.encode(MINT_INTENT_TYPE_HASH, data.creator, data.signer, data.priceModel, keccak256(bytes(data.uri))));
            // bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashStruct));
            bytes32 digest = MessageHashUtils.toTypedDataHash(
                bbb.domainSeparatorV4(),
                keccak256(
                    abi.encode(
                        MINT_INTENT_TYPE_HASH, data.creator, data.signer, data.priceModel, keccak256(bytes(data.uri))
                    )
                )
            );
            

            (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
            return (v, r, s, digest);
            // bytes memory signature = toBytesSignature(v, r, s);
            // return signature;
        }

        
}
