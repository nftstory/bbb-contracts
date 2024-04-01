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

import { Address } from "@openzeppelin/contracts/utils/Address.sol";

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract BBBTest is StdCheats, Test {
    struct SampleMintIntentAndSignature {
        MintIntent mintIntent;
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes32 digest;
    }

    event AllowedPriceModelsChanged(address priceModel, bool allowed);

    BBB bbb;
    Shitpost shitpost;

    // Constructor arguments
    string contractJson =
        '{"name": "bbb","description": "bbb is nice","image": "https://bbb.boats/_next/static/media/logo.a7048512.svg"}';
    string name = "bbb";
    string version = "1";
    string uri = "ipfs://QmfANtwJzFMGBeJGwXEPdqViMcKdzkLQ8WxtTsQp3cXGuV";
    uint256 protocolFee = 50;
    uint256 creatorFee = 50;

    address initialPriceModel;

    // Accounts needed for tests
    address constant owner = 0x1e2820Ea609681A9617d9984dC6188d3c5Ca09cF;
    address payable protocolFeeRecipient = payable(makeAddr("protocolFeeRecipient"));
    address constant creator = 0x0cA6761BC0C1a6CBC8078F33958dE73BCBe00f4e;
    address constant buyer = 0xAb52269Dcf96792700316231f41be3e657Cd710c;

    address signer;
    uint256 signerPk;

    SampleMintIntentAndSignature[] sampleMintIntents;
    uint256 public constant MINT_INTENT_SAMPLE_SIZE = 10;

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    // Initialize test environment
    function setUp() public virtual {
        // Base Mainnet chainId
        vm.chainId(8453);
        // Assign signer an address and pk
        (signer, signerPk) = makeAddrAndKey("signer");
        console2.log(signer);
        deal(owner, 1 ether);
        vm.recordLogs();
        // Instantiate the contract-under-test.
        // TODO set contract JSON
        bbb = new BBB(contractJson, name, version, owner, protocolFeeRecipient, protocolFee, creatorFee);
        // Get the address of the initialPriceModel, deployed in bbb's constructor
        Vm.Log[] memory entries = vm.getRecordedLogs();
        initialPriceModel = address(uint160(uint256(entries[entries.length - 2].topics[1])));
        console2.log("initialPriceModel: ", initialPriceModel); // works
        // Accept Ownership change
        assertEq(bbb.owner(), address(this));
        vm.prank(owner, owner);
        bbb.acceptOwnership();
        assertEq(bbb.owner(), owner);

        // Deploy Shitpost contract
        shitpost = new Shitpost(bbb, protocolFeeRecipient, address(this));
        // Deal ETH to the buyer
        // TODO make sure it's enough ETH for the tests
        deal(buyer, 2000 ether);

        create_sample_mintintents(MINT_INTENT_SAMPLE_SIZE);
    }

    // Generates a set of sample mint intents and corresponding signatures for testing
    function create_sample_mintintents(uint256 sample_amount) internal {
        for (uint256 i = 0; i < sample_amount; i++) {
            address sample_signer;
            uint256 sample_pk;
            (sample_signer, sample_pk) = makeAddrAndKey(string(abi.encode(i)));
            require(buyer != sample_signer, "invalid buyer");
            require(protocolFeeRecipient != sample_signer, "invalid protocolFeeRecipient");
            MintIntent memory data =
                MintIntent({ creator: creator, signer: sample_signer, priceModel: initialPriceModel, uri: uri });
            (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(sample_pk, data);

            sampleMintIntents.push(SampleMintIntentAndSignature({ mintIntent: data, v: v, r: r, s: s, digest: digest }));
        }
    }

    /*//////////////////////////////////////////////////////////////
                                 TESTS
    //////////////////////////////////////////////////////////////*/

    function test_update_contractJson_success(string memory newContractJson) external {
        vm.prank(owner, owner);
        vm.recordLogs();
        bbb.setContractJson(newContractJson);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertEq(entries.length, 1); // TODO - verify the event is as expected
    }

    function test_update_contractJson_fail(string memory newContractJson) external {
        vm.recordLogs();
        // Only moderator can update contractJson
        vm.expectRevert();
        bbb.setContractJson(newContractJson);
    }

    function test_roles_assigned_correctly(address otherAddress) external {
        // Assert that owner has the role
        assertEq(bbb.owner(), owner);
        // Assert that this the deployer is not the owner
        assertTrue(bbb.owner() != address(this));
        // Assert that BBB is not its own owner
        assertTrue(bbb.owner() != address(bbb));
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

    // Tests minting multiple NFTs with a single mint intent
    function test_lazybuy_one(uint256 amount) public {
        // Amount should really be under 100
        vm.assume(amount < 100);
        MintIntent memory data =
            MintIntent({ creator: creator, signer: signer, priceModel: initialPriceModel, uri: uri });

        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(signerPk, data);

        uint256 tokenId = uint256(digest);
        console2.log("tokenId:", tokenId);
        bytes memory signature = toBytesSignature(v, r, s);

        (address intentSigner, ECDSA.RecoverError err, bytes32 info) = ECDSA.tryRecover(digest, signature); // TODO
        assertEq(intentSigner, data.signer);

        // Get the price from the price model
        uint256 price = IAlmostLinearPriceCurve(initialPriceModel).getBatchMintPrice(0, amount);
        uint256 protocolFeeAmount = bbb.protocolFeePoints() * price / 1000;
        uint256 creatorFeeAmount = bbb.creatorFeePoints() * price / 1000;
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

    // Tests minting multiple unique tokens with individual mint intents
    function test_lazybuy_many(uint256 amountOfEachToken) public {
        // Amount should really be under 100
        vm.assume(amountOfEachToken < 100);
        uint256 uniqueTokens = MINT_INTENT_SAMPLE_SIZE;

        for (uint256 i = 0; i < uniqueTokens; i++) {
            // Get the price from the price model
            SampleMintIntentAndSignature memory sample = sampleMintIntents[i];
            MintIntent memory data = sample.mintIntent;
            bytes32 digest = sample.digest;
            uint8 v = sample.v;
            bytes32 r = sample.r;
            bytes32 s = sample.s;
            bytes memory signature = toBytesSignature(v, r, s);
            // Double check the signature
            (address intentSigner, ECDSA.RecoverError err, bytes32 info) = ECDSA.tryRecover(digest, signature);
            assertEq(intentSigner, data.signer);

            uint256 tokenId = uint256(digest);
            uint256 tokenSupplyBefore = bbb.totalSupply(tokenId);
            // Calculate expected price and fees
            // getBatchMintPrice starts at 0 every loop because we are minting a new token
            uint256 price =
                IAlmostLinearPriceCurve(data.priceModel).getBatchMintPrice(tokenSupplyBefore, amountOfEachToken);
            uint256 protocolFeeAmount = bbb.protocolFeePoints() * price / 1000;
            uint256 creatorFeeAmount = bbb.creatorFeePoints() * price / 1000;
            uint256 total = price + protocolFeeAmount + creatorFeeAmount;

            // Take a snapshot of the protocol and creator address balances before
            uint256 protocolBalanceBefore = address(protocolFeeRecipient).balance;
            uint256 creatorBalanceBefore = address(creator).balance;

            // Mint with intent
            // Become the buyer
            vm.startPrank(buyer, buyer);
            bbb.lazybuy{ value: total }(buyer, amountOfEachToken, signature, data);
            // bbb.buy{ value: total }(buyer, tokenId, amountOfEachToken);
            vm.stopPrank();

            // Take a snapshot of the protocol and creator address balances after
            uint256 protocolBalanceAfter = address(protocolFeeRecipient).balance;
            uint256 creatorBalanceAfter = address(creator).balance;

            // Assert that the buyer has the NFT

            assertEq(bbb.balanceOf(buyer, tokenId), amountOfEachToken + tokenSupplyBefore);

            uint256 protocolBalanceChange = protocolBalanceAfter - protocolBalanceBefore;
            uint256 creatorBalanceChange = creatorBalanceAfter - creatorBalanceBefore;
            // Assert that the protocol fee recipient received the protocol fee
            assertEq(protocolBalanceChange, protocolFeeAmount);
            // Assert that the creator received the creator fee
            assertEq(creatorBalanceChange, creatorFeeAmount);
        }
    }

    // Tests that a creator is correctly assigned to a minted token
    function test_creator_assignment() external {
        test_lazybuy_one(1);
        assertEq(bbb.tokenIdToCreator((bbb.sequentialIdToTokenId(1))), creator);
    }

    function test_lazybuy_with_wrong_signature(uint256 amount) public {
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

    // Tests a combination of minting with and without mint intent
    function test_buy(uint256 amount_intent, uint256 amount_no_intent) public {
        vm.assume(amount_intent > 0 || amount_no_intent > 0);
        vm.assume(amount_intent < 100);
        vm.assume(amount_no_intent < 100);
        vm.assume(amount_intent + amount_no_intent < 100);

        // If amount_intent is 0 and amount_no_intent is >0, it should fail

        // First mint with intent
        test_lazybuy_one(amount_intent);

        // Compute the tokenId based on the MintIntent data used in test_lazybuy_one()
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

    // Tests burning a specific token ID and amounts
    function test_sell_one_token_id(uint256 mint_amount, uint256 burn_amount) external {
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
        test_lazybuy_one(mint_amount);
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

    // Tests burning multiple token IDs and verifies balances and fees
    function test_sell_many_token_ids(uint256 mintAmountOfEachToken, uint256 burnAmountOfEachToken) external {
        vm.assume(mintAmountOfEachToken > 0);
        // burn_amount can be 0
        vm.assume(mintAmountOfEachToken >= burnAmountOfEachToken);

        test_lazybuy_many(mintAmountOfEachToken);

        for (uint256 i = 0; i < MINT_INTENT_SAMPLE_SIZE; i++) {
            SampleMintIntentAndSignature memory sample = sampleMintIntents[i];
            MintIntent memory data = sample.mintIntent;
            bytes32 digest = sample.digest;

            uint256 tokenId = uint256(digest);

            // Get the price from the price model
            uint256 price = IAlmostLinearPriceCurve(data.priceModel).getBatchMintPrice(
                mintAmountOfEachToken - burnAmountOfEachToken, burnAmountOfEachToken
            );
            uint256 protocolFeeAmount = protocolFee * price / 1000;
            uint256 creatorFeeAmount = creatorFee * price / 1000;
            // The refunded ETH
            uint256 total = price - protocolFeeAmount - creatorFeeAmount;

            // Get the protocol and creator balance before
            uint256 protocolBalanceBefore = address(protocolFeeRecipient).balance;
            uint256 creatorBalanceBefore = address(creator).balance;

            // Become the buyer
            vm.startPrank(buyer, buyer);
            // Mint without intent
            bbb.sell(tokenId, burnAmountOfEachToken, total);
            vm.stopPrank();

            // Get the protocol and creator balance after
            uint256 protocolBalanceAfter = address(protocolFeeRecipient).balance;
            uint256 creatorBalanceAfter = address(creator).balance;

            // Assert that the buyer burned the correct amount of NFTs
            assertEq(bbb.balanceOf(buyer, tokenId), mintAmountOfEachToken - burnAmountOfEachToken);

            uint256 protocolBalanceChange = protocolBalanceAfter - protocolBalanceBefore;
            uint256 creatorBalanceChange = creatorBalanceAfter - creatorBalanceBefore;
            // Assert that the protocol fee recipient received the protocol fee
            assertEq(protocolBalanceChange, protocolFeeAmount);
            // Assert that the creator received the creator fee
            assertEq(creatorBalanceChange, creatorFeeAmount);
        }
    }

    // Tests that burning more tokens than owned fails as expected
    function test_sell_one_token_id_fail(uint256 mint_amount, uint256 burn_amount) external {
        // vm.pauseGasMetering();
        vm.assume(mint_amount > 0);
        // vm.assume(burn_amount > 0);
        // Fails because burn_amount > mint_amount
        vm.assume(mint_amount < burn_amount);

        MintIntent memory data =
            MintIntent({ creator: creator, signer: signer, priceModel: initialPriceModel, uri: uri });

        (uint8 v, bytes32 r, bytes32 s, bytes32 digest) = getSignatureAndDigest(signerPk, data);

        uint256 tokenId = uint256(digest);

        uint256 protocolBalanceBefore = address(protocolFeeRecipient).balance;
        uint256 creatorBalanceBefore = address(creator).balance;
        // Mint with intent
        test_lazybuy_one(mint_amount);
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

    // Tests changing the protocol fee recipient address
    function test_set_protocol_fee_recipient(address new_protocol_fee_recipient) external {
        vm.assume(new_protocol_fee_recipient != protocolFeeRecipient);
        vm.assume(new_protocol_fee_recipient != address(0));
        vm.assume(new_protocol_fee_recipient != address(bbb));

        // Set the new protocol fee recipient
        vm.startPrank(owner, owner);
        bbb.setProtocolFeeRecipient(payable(new_protocol_fee_recipient));
        vm.stopPrank();
        // Assert that the new protocol fee recipient is set
        assertEq(bbb.protocolFeeRecipient(), payable(new_protocol_fee_recipient));
    }

    // Tests the correct mapping of sequential IDs to token IDs and vice-versa
    function test_sequential_id_mappings() external {
        test_buy(3, 3);
        for (uint256 i = 1; i < 7; i++) {
            assertEq(
                bbb.sequentialIdToTokenId(i),
                bbb.sequentialIdToTokenId(bbb.tokenIdToSequentialId(bbb.sequentialIdToTokenId(i)))
            );
        }
    }

    // Tests if a token ID is correctly mapped to its price model
    function test_token_id_to_price_model() external {
        test_lazybuy_one(10);
        assertEq(bbb.tokenIdToPriceModel(bbb.sequentialIdToTokenId(1)), initialPriceModel);
    }

    // Tests the total issued tokens count for accuracy
    function test_total_issued() external {
        test_buy(1, 1);
        assertEq(bbb.totalIssued(), 1);
    }

    // Tests allowing/disallowing price models
    function test_set_allowed_price_models() external {
        assertEq(bbb.allowedPriceModels(owner), false);
        vm.startPrank(owner, owner);
        bbb.setAllowedPriceModel(owner, true);
        vm.stopPrank();
        assertEq(bbb.allowedPriceModels(owner), true);
    }

    function test_disallowed_price_models_does_not_prevent_buy_sell_extant_tokens() external {
        // Mint once
        vm.prank(buyer);
        test_lazybuy_one(1);
        // Disallow the initial price model
        vm.startPrank(owner, owner);
        bbb.setAllowedPriceModel(initialPriceModel, false);
        vm.stopPrank();
        // Mint with intent
        vm.startPrank(buyer, buyer);
        bbb.buy{ value: 1 ether }(buyer, bbb.sequentialIdToTokenId(1), 1);
        // Assert that the buyer has 2 NFT
        assertEq(bbb.balanceOf(buyer, bbb.sequentialIdToTokenId(1)), 2);
        bbb.sell(bbb.sequentialIdToTokenId(1), 1, 0);
        vm.stopPrank();
        // Assert that the buyer has 1 NFT
        assertEq(bbb.balanceOf(buyer, bbb.sequentialIdToTokenId(1)), 1);
        // TODO test that no new mint intents can use this price model
    }

    function test_set_protocol_fee_points(uint256 new_protocol_fee) public {
        vm.assume(new_protocol_fee <= 100);
        // Set the new protocol fee
        vm.startPrank(owner, owner);
        bbb.setProtocolFeePoints(new_protocol_fee);
        vm.stopPrank();
        // Assert that the new protocol fee is set
        assertEq(bbb.protocolFeePoints(), new_protocol_fee);
    }

    function test_set_creator_fee_points(uint256 new_creator_fee) public {
        vm.assume(new_creator_fee <= 100);
        // Set the new creator fee
        vm.startPrank(owner, owner);
        bbb.setCreatorFeePoints(new_creator_fee);
        vm.stopPrank();
        // Assert that the new creator fee is set
        assertEq(bbb.creatorFeePoints(), new_creator_fee);
    }

    // Tests that minting still works on extant tokens if fees changed
    function test_changing_fee_points() external {
        test_lazybuy_many(1);
        test_set_protocol_fee_points(10);
        test_set_creator_fee_points(10);
        test_lazybuy_many(1);
    }

    // Tests the behavior of the contract when receiving direct ETH transfers
    function test_receive() external {
        vm.prank(buyer);
        vm.expectRevert();
        Address.sendValue(payable(bbb), 1 wei);
    }

    // Test uri() returns expected value
    function test_uri() external {
        test_lazybuy_one(1);
        assertEq(bbb.uri(bbb.sequentialIdToTokenId(1)), uri);
    }

    /*//////////////////////////////////////////////////////////////
                           SHITPOST CONTRACT
    //////////////////////////////////////////////////////////////*/

    // Tests posting a message to a valid token ID
    function test_shitpost(string memory message, uint256 msgValue) external payable {
        vm.assume(msgValue < 2 ether);
        vm.assume(msg.value == msgValue);
        // vm.assume(msg.value < 2 ether);
        test_lazybuy_one(1);
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

    // Tests posting a message to a nonexistent token ID
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

    // Test changing feeRecipient
    function test_change_shitpost_feeRecipient() external {
        address payable newFeeRecipient = payable(makeAddr("newFeeRecipient"));
        shitpost.changeFeeRecipient(newFeeRecipient);
        assertEq(shitpost.feeRecipient(), newFeeRecipient);
    }

    // Test changing feeRecipient as unauthorized address
    function test_unauthorized_change_shitpost_feeRecipient() external {
        address payable newFeeRecipient = payable(makeAddr("newFeeRecipient"));
        vm.startPrank(buyer, buyer);
        vm.expectRevert();
        shitpost.changeFeeRecipient(newFeeRecipient);
        vm.stopPrank();
    }

    // Test feeRecipient getter
    function test_get_shitpost_feeRecipient() external {
        assertEq(shitpost.feeRecipient(), protocolFeeRecipient); // see Set up function
    }

    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // Helper function to convert a v,r,s signature to bytes
    function toBytesSignature(uint8 v, bytes32 r, bytes32 s) public pure returns (bytes memory) {
        return abi.encodePacked(r, s, v);
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(
            abi.encode(EIP712_DOMAIN, keccak256(bytes(name)), keccak256(bytes(version)), block.chainid, address(bbb))
        );
    }

    // Helper function to get the signature and digest of a MintIntent
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
