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

import { IAlmostLinearPriceCurve } from "../src/pricing/AlmostLinearPriceCurve.sol";

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

    address signer;
    uint256 signerPk;

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        vm.chainId(5);
        // Assign signer an address and pk
        (signer, signerPk) = makeAddrAndKey("signer");
        console2.log(signer);
        vm.recordLogs();
        // Instantiate the contract-under-test.
        bbb = new BBB(name, version, moderator, protocolFeeRecipient, protocolFee, creatorFee);
        // Get the address of the initialPriceModel, deployed in bbb's constructor
        Vm.Log[] memory entries = vm.getRecordedLogs();
        initialPriceModel = address(uint160(uint256(entries[entries.length - 1].topics[1])));
        console2.log("initialPriceModel: ", initialPriceModel); // works

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
        // Assert that MODERTOR_ROLE is it's own admin
        assertEq(bbb.getRoleAdmin(bytes32(keccak256("MODERATOR_ROLE"))), bytes32(keccak256("MODERATOR_ROLE")));
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
        uint256 amount = 2;

        MintIntent memory data =
            MintIntent({ creator: creator, signer: signer, priceModel: initialPriceModel, uri: uri });

        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(signerPk, data);

        uint256 tokenId = uint256(digest);
        console2.log("tokenId:", tokenId);
        bytes memory signature = toBytesSignature(v, r, s);

        (address intentSigner, ECDSA.RecoverError err, bytes32 info) = ECDSA.tryRecover(digest, signature); // TODO
        assertEq(intentSigner, signer);

        // Get the price from the price model
        uint256 price = IAlmostLinearPriceCurve(initialPriceModel).getBatchMintPrice(0, amount);
        uint256 protocolFeeAmount = protocolFee * price / 1000;
        uint256 creatorFeeAmount = creatorFee * price / 1000;
        uint256 total = price + protocolFeeAmount + creatorFeeAmount;
        console2.log("Price", price); // 1_000_000_000_000_000
        // uint256 price = 1 ether;

        // TODO add protocol fees, for now just bump the price
        // Become the buyer
        vm.startPrank(buyer, buyer);
        // Mint with intent

        bbb.mintWithIntent{ value: total }(data, amount, signature);
        // Assert that the buyer has the NFT
        assertEq(bbb.balanceOf(buyer, tokenId), amount);
        // Assert that the protocol fee recipient has the protocol fee
        assertEq(address(protocolFeeRecipient).balance, protocolFeeAmount);
        // Assert that the creator has the creator fee
        assertEq(address(creator).balance, creatorFeeAmount);
        vm.stopPrank();
    }

    function test_mint_no_intent() external {
        uint256 amount = 1;
        uint256 tokenId =
            25_951_155_603_938_650_249_890_663_414_884_298_295_778_319_386_545_382_981_197_812_827_133_397_353_612;
        uint256 firstPrice = IAlmostLinearPriceCurve(initialPriceModel).getBatchMintPrice(0, 2);
        test_mint_with_intent(); // mint with intent to issue tokenId 1

        // The currentSupply in this case is 1 as we just minted it with the intent above
        uint256 secondPrice = IAlmostLinearPriceCurve(initialPriceModel).getNextMintPrice(1);

        vm.startPrank(buyer, buyer);
        // (, address msgSender, address txOrigin) = vm.readCallers();
        bbb.mint{ value: 2 * secondPrice }(tokenId, 1);
        vm.stopPrank();
        // Assert that the buyer has the NFT
        assertEq(bbb.balanceOf(buyer, tokenId), amount + 2);
        // Assert that the protocol fee recipient has the protocol fee
        assertEq(address(protocolFeeRecipient).balance, protocolFee * (firstPrice + secondPrice) / 1000);
        // Assert that the creator has the creator fee
        assertEq(address(creator).balance, creatorFee * (firstPrice + secondPrice) / 1000);
    }

    function test_burn() external {
        // vm.pauseGasMetering();
        uint256 mintAmount = 2;
        uint256 burnAmount = 1;
        uint256 N = mintAmount + burnAmount;
        uint256 tokenId =
            25_951_155_603_938_650_249_890_663_414_884_298_295_778_319_386_545_382_981_197_812_827_133_397_353_612;
        uint256 initialBalance = address(buyer).balance;

        test_mint_with_intent(); // mint with intent to issue tokenId 1
        // The currentSupply in this case is 1 as we just minted it with the intent above
        uint256 priceSingle = IAlmostLinearPriceCurve(initialPriceModel).getNextMintPrice(0);
        uint256 price = IAlmostLinearPriceCurve(initialPriceModel).getBatchMintPrice(0, mintAmount);
        uint256 mintProtocolFee = priceSingle * protocolFee / 1000;
        uint256 mintCreatorFee = priceSingle * creatorFee / 1000;

        // The price of minting 2 tokens, burning one (refund) => 3 * mintProtocolFee + 3 * mintCreatorFee
        // uint256 x = (price - priceSingle) + 3*(mintProtocolFee + mintCreatorFee);

        vm.startPrank(buyer, buyer);
        // (, address msgSender, address txOrigin) = vm.readCallers();
        bbb.burn(tokenId, burnAmount);
        vm.stopPrank();

        assertEq(bbb.balanceOf(buyer, tokenId), 1);

        uint256 finalBalance = address(buyer).balance;
        // console2.log("balanceDIff", initialBalance - finalBalance);
        // console2.log("x", x);

        assertEq(finalBalance, initialBalance - N * (mintProtocolFee + mintCreatorFee) - price / 2);
        assertEq(address(protocolFeeRecipient).balance, N * mintProtocolFee);
        assertEq(address(creator).balance, N * mintCreatorFee);
    }


    // TODO Test what happens if the last one is burned and a new person tries to mint

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
