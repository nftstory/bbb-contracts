// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { console2 } from "forge-std/src/console2.sol";
import { Test } from "forge-std/src/Test.sol";
import { StdCheats, Vm } from "forge-std/src/StdCheats.sol";
import { Vm } from "forge-std/src/Vm.sol";

import { BBB } from "../src/BBB.sol";
import {
    MintIntent, MINT_INTENT_ENCODE_TYPE, MINT_INTENT_TYPE_HASH, EIP712_DOMAIN
} from "../src/structs/MintIntent.sol";

import { IERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract BBBTest is StdCheats, Test {
    event AllowedPriceModelsChanged(address priceModel, bool allowed);

    BBB bbb;

    // Constructor arguments
    string name = "name";
    string version = "1";
    string uri = "demo_uri";
    uint256 protocolFee = 50;
    uint256 creatorFee = 50;

    address initialPriceModel;

    // Accounts needed for tests
    address constant moderator = 0x1e2820Ea609681A9617d9984dC6188d3c5Ca09cF;
    address payable protocolFeeRecipient = payable(makeAddr("protocolFeeRecipient"));
    address constant creator = 0x0cA6761BC0C1a6CBC8078F33958dE73BCBe00f4e;
    address constant buyer = 0xAb52269Dcf96792700316231f41be3e657Cd710c;
    // address signer = 0xF4ef37a4EcA1DeCB0E62482590b3D4Fc7f1214ec;
    address signer;
    // bytes32 signerPk = 0xf9fc766a27e844ad50c0e567e921d5d2cb661560d2bd2421f3db0c0f0a8e4364;
    // uint256 signerPk = 113071962025583480559611482528073794879019954380499915552367164943375860122468;
    uint256 signerPk;

    event Log(string message, uint256 value);

    // function test_logging_events() public {
    //     vm.recordLogs();
    //     emit Log("hi", 123);
    //     // Vm.Log[] memory entries = vm.getRecordedLogs();
    // }

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        console2.log("bbb.t.sol:");
        console2.log(address(this));
        console2.log("buyer:");
        console2.log(buyer);
        // Assign signer an address and pk
        (signer, signerPk) = makeAddrAndKey("signer");
        // vm.recordLogs();
        // Instantiate the contract-under-test.
        bbb = new BBB(name, version, uri, moderator, protocolFeeRecipient, protocolFee, creatorFee);
        // Vm.Log[] memory entries = vm.getRecordedLogs();
        // Vm.Log[] memory entries = vm.getRecordedLogs();
        // initialPriceModel = address(uint160(uint256(entries[entries.length - 1].topics[1])));
        initialPriceModel = 0x104fBc016F4bb334D775a19E8A6510109AC63E00; // TODO instead of hardcoding, get this from the
            // logs
        // console2.log("initialPriceModel: ", initialPriceModel);

        // Deal ETH to the buyer
        deal(buyer, 2 ether);
    }

    /*//////////////////////////////////////////////////////////////
                                 TESTS
    //////////////////////////////////////////////////////////////*/

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
        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(
            signerPk, MintIntent({ creator: creator, signer: signer, priceModel: initialPriceModel, uri: uri })
        );

        // Recover signer address
        address recoveredSigner = ECDSA.recover(digest, v, r, s);
        // address recoveredSigner = ecrecover(hash, v, r, s);
        assertEq(signer, recoveredSigner); // [PASS]
    }

    function test_sign_signature() external {
        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(
            signerPk, MintIntent({ creator: creator, signer: signer, priceModel: initialPriceModel, uri: uri })
        );
        bytes memory signature = toBytesSignature(v, r, s);
        // Recover signer address
        address recoveredSigner = ECDSA.recover(digest, signature);
        // address recoveredSigner = ecrecover(hash, v, r, s);
        assertEq(signer, recoveredSigner); // [PASS]
    }

    function test_mint_with_intent() public {
        uint256 amount = 1;
        uint256 value = 1 ether;

        MintIntent memory data =
            MintIntent({ creator: creator, signer: signer, priceModel: initialPriceModel, uri: uri });

        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(signerPk, data);
        bytes memory signature = toBytesSignature(v, r, s);

        (address intentSigner, ECDSA.RecoverError err, bytes32 info) = ECDSA.tryRecover(digest, signature); // TODO
        assertEq(intentSigner, signer);
        // Become the buyer
        vm.startPrank(buyer, buyer);
        // Mint with intent
        bbb.mintWithIntent{ value: value }(data, amount, signature);
        // Assert that the buyer has the NFT
        assertEq(bbb.balanceOf(buyer, 1), amount);
        vm.stopPrank();
    }

    function test_mint_no_intent() external {
        uint256 amount = 1;
        uint256 value = 1 ether;

        (, address msgSender, address txOrigin) = vm.readCallers();
        test_mint_with_intent(); // mint with intent to issue tokenId 1

        vm.startPrank(buyer, buyer);
        bbb.mint(1, 1);
        vm.stopPrank();

        assertEq(bbb.balanceOf(buyer, 1), amount + 1);
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
        // console2.log("domainSep 1: ", uint256(_buildDomainSeparator()));
        // console2.log("digest 1: ", uint256(digest));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        return (v, r, s, digest);
    }
}
