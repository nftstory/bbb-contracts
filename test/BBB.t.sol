// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { console2 } from "forge-std/src/console2.sol";
import { Test } from "forge-std/src/Test.sol";
import { StdCheats, Vm } from "forge-std/src/StdCheats.sol";
import { Vm } from "forge-std/src/Vm.sol";

import { BBB } from "../src/BBB.sol";
import { Shitpost } from "../src/Shitpost.sol";
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
    Shitpost shitpost;

    // Constructor arguments
    string name = "bbb";
    string version = "1";
    string uri = "ipfs://QmfANtwJzFMGBeJGwXEPdqViMcKdzkLQ8WxtTsQp3cXGuV";
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
        // Base Mainnet chainId
        vm.chainId(8453);
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

        // Deploy Shitpost contract
        shitpost = new Shitpost(bbb, protocolFeeRecipient, address(this));
        // Deal ETH to the buyer
        deal(buyer, 2 ether);
    }

    /*//////////////////////////////////////////////////////////////
                                 TESTS
    //////////////////////////////////////////////////////////////*/

    function test_roles_assigned_correctly() external {
        // Assert that DEFAULT_ADMIN_ROLE is assigned to address(0)
        assertEq(abi.encode(bbb.getRoleAdmin(bytes32(keccak256("DEFAULT_ADMIN_ROLE")))), abi.encode(address(0)));
        // Assert that MODERTOR_ROLE is it's own admin
        assertEq(bbb.getRoleAdmin(bytes32(keccak256("MODERATOR_ROLE"))), bytes32(keccak256("MODERATOR_ROLE")));
        // Assert that moderator has MODERATOR_ROLE
        assertEq(bbb.hasRole(bytes32(keccak256("MODERATOR_ROLE")), moderator), true);
        // Assert that this test contract does not have DEFAULT_ADMIN_ROLE
        assertEq(bbb.hasRole(bytes32(keccak256("DEFAULT_ADMIN_ROLE")), address(this)), false);
        // Assert that BBB does not have DEFAULT_ADMIN_ROLE
        assertEq(bbb.hasRole(bytes32(keccak256("DEFAULT_ADMIN_ROLE")), address(bbb)), false);
    }

    function test_vars_assigned_correctly() external {
        // Assert that the protocol fee is set correctly
        assertEq(bbb.protocolFeePoints(), protocolFee);
        // Assert that the creator fee is set correctly
        assertEq(bbb.creatorFeePoints(), creatorFee);
        // Assert that the protocol fee recipient is set correctly
        assertEq(bbb.protocolFeeRecipient(), protocolFeeRecipient);
        // Assert that the allowed price model is set correctly
        assertEq(bbb.allowedPriceModels(initialPriceModel), true);
    }

    function test_unauthorized_role_actions() external {
        vm.expectRevert();
        vm.prank(address(0x000000000000000000000000000000000000dEaD));
        bbb.setProtocolFeePoints(100);

        vm.expectRevert();
        vm.prank(address(0x000000000000000000000000000000000000dEaD));
        bbb.setCreatorFeePoints(100);

        vm.expectRevert();
        vm.prank(address(0x000000000000000000000000000000000000dEaD));
        bbb.setProtocolFeeRecipient(payable(0x000000000000000000000000000000000000baBe));
    }

    function test_fees_out_of_bounds() external {
        vm.expectRevert();
        bbb.setProtocolFeePoints(101);

        vm.expectRevert();
        bbb.setCreatorFeePoints(101);
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

    function test_is_valid_mint_intent() external {
        MintIntent memory data =
            MintIntent({ creator: creator, signer: signer, priceModel: initialPriceModel, uri: uri });

        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(signerPk, data);
        bool result = bbb.isValidMintIntent(data, toBytesSignature(v, r, s));
        assertEq(result, true); // [PASS]
    }

    function test_is_valid_mint_intent_invalid() external {
        MintIntent memory data =
            MintIntent({ creator: creator, signer: signer, priceModel: initialPriceModel, uri: uri });
        bytes memory signature =
            hex"ac7f2f5d4bf713823ad28ffc7fc51bbf31134e6ba0c2c65bee568212a2544d152848e39e5bff75e895482928e3ffed9e2ada2f754c1aa19f9b361c952b698e511b";

        bool result = bbb.isValidMintIntent(data, signature);
        assertEq(result, false); // [PASS]
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

    function test_mint_with_intent(uint256 amount) public {
        // Amount should really be under 100
        vm.assume(amount < 100);
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

        // Become the buyer
        vm.startPrank(buyer, buyer);
        // Mint with intent
        bbb.lazybuy{ value: total }(buyer, amount, signature, data);
        // Assert that the buyer has the NFT
        assertEq(bbb.balanceOf(buyer, tokenId), amount);
        // Assert that the protocol fee recipient has the protocol fee
        assertEq(address(protocolFeeRecipient).balance, protocolFeeAmount);
        // Assert that the creator has the creator fee
        assertEq(address(creator).balance, creatorFeeAmount);
        vm.stopPrank();
    }

    function test_creator_assignment() external {
        test_mint_with_intent(1);
        assertEq(bbb.tokenIdToCreator((bbb.sequentialIdToTokenId(1))), creator);
    }

    function test_mint_with_wrong_signature(uint256 amount) public {
        // Amount should really be under 100
        vm.assume(amount > 0);
        vm.assume(amount < 100);
        MintIntent memory data =
            MintIntent({ creator: creator, signer: signer, priceModel: initialPriceModel, uri: uri });

        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(signerPk, data);

        uint256 tokenId = uint256(digest);
        console2.log("tokenId:", tokenId);
        // bytes memory signature = toBytesSignature(v, r, s);

        // Wrong signature
        bytes memory signature =
            hex"ac7f2f5d4bf713823ad28ffc7fc51bbf31134e6ba0c2c65bee568212a2544d152848e39e5bff75e895482928e3ffed9e2ada2f754c1aa19f9b361c952b698e511b";

        // (address intentSigner, ECDSA.RecoverError err, bytes32 info) = ECDSA.tryRecover(digest, signature); // TODO
        // assertEq(intentSigner, signer);

        // Get the price from the price model
        uint256 price = IAlmostLinearPriceCurve(initialPriceModel).getBatchMintPrice(0, amount);
        uint256 protocolFeeAmount = protocolFee * price / 1000;
        uint256 creatorFeeAmount = creatorFee * price / 1000;
        uint256 total = price + protocolFeeAmount + creatorFeeAmount;
        console2.log("Price", price); // 1_000_000_000_000_000
        // uint256 price = 1 ether;

        // Become the buyer
        vm.startPrank(buyer, buyer);
        // Mint with intent

        vm.expectRevert();
        bbb.lazybuy{ value: total }(buyer, amount, signature, data);
        vm.stopPrank();
    }

    function test_mint(uint256 amount_intent, uint256 amount_no_intent) public {
        vm.assume(amount_intent > 0 || amount_no_intent > 0);
        vm.assume(amount_intent < 100);
        vm.assume(amount_no_intent < 100);
        vm.assume(amount_intent + amount_no_intent < 100);

        // If amount_intent is 0 and amount_no_intent is >0, it should fail

        // First mint with intent
        test_mint_with_intent(amount_intent);
   
        // Compute the tokenId based on the MintIntent data used in test_mint_with_intent()
        MintIntent memory data =
            MintIntent({ creator: creator, signer: signer, priceModel: initialPriceModel, uri: uri });

        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(signerPk, data);

        uint256 tokenId = uint256(digest);

        // Get the price from the price model
        uint256 price = IAlmostLinearPriceCurve(initialPriceModel).getBatchMintPrice(amount_intent, amount_no_intent);
        uint256 protocolFeeAmount = protocolFee * price / 1000;
        uint256 creatorFeeAmount = creatorFee * price / 1000;
        uint256 total = price + protocolFeeAmount + creatorFeeAmount;

        // Get the protocol and creator balance before
        uint256 protocolBalanceBefore = address(protocolFeeRecipient).balance;
        uint256 creatorBalanceBefore = address(creator).balance;

        // Become the buyer
        vm.startPrank(buyer, buyer);
        // Mint without intent
        bbb.buy{ value: total }(buyer, tokenId, amount_no_intent);
        // Assert that the buyer has the NFT
        assertEq(bbb.balanceOf(buyer, tokenId), amount_intent + amount_no_intent);
        // Assert that the protocol fee recipient has the protocol fee (only the new protocol fee)
        assertEq(address(protocolFeeRecipient).balance, protocolBalanceBefore + protocolFeeAmount);
        // Assert that the creator has the creator fee (only the new creator fee)
        assertEq(address(creator).balance, creatorBalanceBefore + creatorFeeAmount);
    }

    function test_burn(uint256 mint_amount, uint256 burn_amount) external {
        vm.assume(mint_amount > 0);
        // burn_amount can be 0
        vm.assume(mint_amount >= burn_amount);

        MintIntent memory data =
            MintIntent({ creator: creator, signer: signer, priceModel: initialPriceModel, uri: uri });

        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(signerPk, data);

        uint256 tokenId = uint256(digest);

        uint256 protocolBalanceBefore = address(protocolFeeRecipient).balance;
        uint256 creatorBalanceBefore = address(creator).balance;
        // Mint with intent
        test_mint_with_intent(mint_amount);
        assertEq(bbb.balanceOf(buyer, tokenId), mint_amount);
        // Get the price from the price model
        uint256 price = IAlmostLinearPriceCurve(initialPriceModel).getBatchMintPrice(0, mint_amount);
        uint256 protocolFeeAmount = protocolFee * price / 1000;
        uint256 creatorFeeAmount = creatorFee * price / 1000;

        assertEq(address(protocolFeeRecipient).balance, protocolBalanceBefore + protocolFeeAmount);
        assertEq(address(creator).balance, creatorBalanceBefore + creatorFeeAmount);

        // Become the buyer
        vm.startPrank(buyer, buyer);
        // Mint with intent
        uint256 refundPrice =
            IAlmostLinearPriceCurve(initialPriceModel).getBatchMintPrice(mint_amount - burn_amount, burn_amount);
        uint256 refundProtocolFeeAmount = protocolFee * refundPrice / 1000;
        uint256 refundCreatorFeeAmount = creatorFee * refundPrice / 1000;

        uint256 totalBurnRefund = refundPrice - refundProtocolFeeAmount - refundCreatorFeeAmount;
        bbb.sell(tokenId, burn_amount, totalBurnRefund); // TODO change to actual minRefund expected
        vm.stopPrank();

        // Assert that the protocol fee recipient has the correct protocol fee
        assertEq(
            address(protocolFeeRecipient).balance, protocolBalanceBefore + protocolFeeAmount + refundProtocolFeeAmount
        );
        // Assert that the creator has the correct creator fee
        assertEq(address(creator).balance, creatorBalanceBefore + creatorFeeAmount + refundCreatorFeeAmount);
        // Assert that the buyer has the correct NFT balance
        assertEq(bbb.balanceOf(buyer, tokenId), mint_amount - burn_amount);
    }

    function test_burn_fail(uint256 mint_amount, uint256 burn_amount) external {
        // vm.pauseGasMetering();
        vm.assume(mint_amount > 0);
        // vm.assume(burn_amount > 0);
        vm.assume(mint_amount < burn_amount);

        MintIntent memory data =
            MintIntent({ creator: creator, signer: signer, priceModel: initialPriceModel, uri: uri });

        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(signerPk, data);

        uint256 tokenId = uint256(digest);

        uint256 protocolBalanceBefore = address(protocolFeeRecipient).balance;
        uint256 creatorBalanceBefore = address(creator).balance;
        // Mint with intent
        test_mint_with_intent(mint_amount);
        assertEq(bbb.balanceOf(buyer, tokenId), mint_amount);
        // Get the price from the price model
        uint256 price = IAlmostLinearPriceCurve(initialPriceModel).getBatchMintPrice(0, mint_amount);
        uint256 protocolFeeAmount = protocolFee * price / 1000;
        uint256 creatorFeeAmount = creatorFee * price / 1000;

        assertEq(address(protocolFeeRecipient).balance, protocolBalanceBefore + protocolFeeAmount);
        assertEq(address(creator).balance, creatorBalanceBefore + creatorFeeAmount);

        // Become the buyer
        vm.startPrank(buyer, buyer);
        // Mint with intent
        vm.expectRevert();
        bbb.sell(tokenId, burn_amount, 0);
        vm.stopPrank();
    }

    function test_set_protocol_fee_recipient(address new_protocol_fee_recipient) external {
        vm.assume(new_protocol_fee_recipient != protocolFeeRecipient);
        vm.assume(new_protocol_fee_recipient != address(0));

        // Set the new protocol fee recipient
        vm.startPrank(moderator, moderator);
        bbb.setProtocolFeeRecipient(payable(new_protocol_fee_recipient));
        vm.stopPrank();
        // Assert that the new protocol fee recipient is set
        assertEq(bbb.protocolFeeRecipient(), payable(new_protocol_fee_recipient));
    }

    function test_sequential_id_mappings() external {
        test_mint(3, 3);
        for (uint256 i = 1; i < 7; i++) {
            assertEq(
                bbb.sequentialIdToTokenId(i),
                bbb.sequentialIdToTokenId(bbb.tokenIdToSequentialId(bbb.sequentialIdToTokenId(i)))
            );
        }
    }

    function test_token_id_to_price_model() external {
        test_mint_with_intent(10);
        assertEq(bbb.tokenIdToPriceModel(bbb.sequentialIdToTokenId(1)), initialPriceModel);
    }

    function test_total_issued() external {
        test_mint(1, 1);
        assertEq(bbb.totalIssued(), 1);
    }

    function test_set_allowed_price_models() external {
        assertEq(bbb.allowedPriceModels(moderator), false);
        vm.startPrank(moderator, moderator);
        bbb.setAllowedPriceModel(moderator, true);
        vm.stopPrank();
        assertEq(bbb.allowedPriceModels(moderator), true);
    }

    function test_transfer_moderator_role(address new_moderator) external {
        vm.assume(new_moderator != moderator);
        vm.assume(new_moderator != address(0));

        // Assert that the current moderator has the MODERATOR_ROLE
        assertEq(bbb.hasRole(bytes32(keccak256("MODERATOR_ROLE")), moderator), true);
        // Transfer the moderator role
        vm.startPrank(moderator, moderator);
        bbb.transferModeratorRole(new_moderator);
        vm.stopPrank();
        // Assert that the new moderator has the MODERATOR_ROLE
        assertEq(bbb.hasRole(bytes32(keccak256("MODERATOR_ROLE")), new_moderator), true);
        // Assert that the old moderator does not have the MODERATOR_ROLE
        assertEq(bbb.hasRole(bytes32(keccak256("MODERATOR_ROLE")), moderator), false);
    }

    function test_transfer_moderator_zero_address() external {
        // Expect a revert!
        vm.startPrank(moderator, moderator);
        vm.expectRevert();
        bbb.transferModeratorRole(address(0));
        vm.stopPrank();
    }

    function test_transfer_same_moderator() external {
        // Expect a revert!
        vm.startPrank(moderator, moderator);
        vm.expectRevert();
        bbb.transferModeratorRole(moderator);
        vm.stopPrank();
    }

    function test_set_protocol_fee_points(uint256 new_protocol_fee) external {
        vm.assume(new_protocol_fee <= 100);
        // Set the new protocol fee
        vm.startPrank(moderator, moderator);
        bbb.setProtocolFeePoints(new_protocol_fee);
        vm.stopPrank();
        // Assert that the new protocol fee is set
        assertEq(bbb.protocolFeePoints(), new_protocol_fee);
    }

    function test_set_creator_fee_points(uint256 new_creator_fee) external {
        vm.assume(new_creator_fee <= 100);
        // Set the new creator fee
        vm.startPrank(moderator, moderator);
        bbb.setCreatorFeePoints(new_creator_fee);
        vm.stopPrank();
        // Assert that the new creator fee is set
        assertEq(bbb.creatorFeePoints(), new_creator_fee);
    }

    /*//////////////////////////////////////////////////////////////
                           SHITPOST CONTRACT
    //////////////////////////////////////////////////////////////*/

    function test_shitpost(string memory message, uint256 msgValue) external payable {
        vm.assume(msgValue < 2 ether);
        vm.assume(msg.value == msgValue);
        // vm.assume(msg.value < 2 ether);
        test_mint_with_intent(1);
        MintIntent memory data =
            MintIntent({ creator: creator, signer: signer, priceModel: initialPriceModel, uri: uri });

        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(signerPk, data);

        uint256 tokenId = uint256(digest);
        vm.recordLogs();
        shitpost.shitpost{ value: msg.value }(tokenId, message);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        // Make sure the event was emitted
        assertEq(entries.length, 1); // TODO - verify the event is as expected
    }

    function test_shitpost_tokenId_nonexistent(string memory message, uint256 msgValue) external payable {
        vm.assume(msgValue < 2 ether);
        vm.assume(msg.value == msgValue);
        // vm.assume(msg.value < 2 ether);
        MintIntent memory data =
            MintIntent({ creator: creator, signer: signer, priceModel: initialPriceModel, uri: uri });

        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(signerPk, data);

        uint256 tokenId = uint256(digest);
        vm.expectRevert();
        shitpost.shitpost{ value: msg.value }(tokenId, message);
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
