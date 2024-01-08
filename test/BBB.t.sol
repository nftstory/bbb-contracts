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

    event LogAddress(address);

    // function test_prank() external {
    //     vm.prank(address(1), address(2));
    //     (, address msgSender, address txOrigin) = vm.readCallers();
    //     console2.log("msg sender:", msgSender);
    //     console2.log("txOrigin:", txOrigin);
    // }

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

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == bytes4(0xf23a6e61) || interfaceId == bytes4(0xbc197c81); // ERC1155Receiver
    }

    // function onERC1155Received(
    //     address operator,
    //     address from,
    //     uint256 id,
    //     uint256 value,
    //     bytes calldata data
    // ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is
     * allowed
     */
    // function onERC1155BatchReceived(
    //     address operator,
    //     address from,
    //     uint256[] calldata ids,
    //     uint256[] calldata values,
    //     bytes calldata data
    // ) external returns (bytes4){
    //     return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    // }
}
