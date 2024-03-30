A table summarizing which functions are covered by tests. Untested functions are marked as such.

### `BBB.sol`

| Function Name | Contract | Test Coverage |
|---------------|----------|---------------|
| constructor | BBB | Covered (`setUp`) |
| receive | BBB | Untested |
| transferModeratorRole | BBB | Covered (`test_transfer_moderator_role`, `test_transfer_moderator_zero_address`, `test_transfer_same_moderator`) |
| lazybuy | BBB | Covered (`test_mint_with_one_intent`, `test_mint_with_many_intents`) |
| buy | BBB | Covered (`test_mint`) |
| sell | BBB | Covered (`test_burn_one_token_id`, `test_burn_many_token_ids`, `test_burn_one_token_id_fail`) |
| setAllowedPriceModel | BBB | Covered (`test_set_allowed_price_models`) |
| setProtocolFeePoints | BBB | Covered (`test_set_protocol_fee_points`, `test_fees_out_of_bounds`, `test_unauthorized_role_actions`, `test_changing_fee_points`) |
| setCreatorFeePoints | BBB | Covered (`test_set_creator_fee_points`, `test_fees_out_of_bounds`, `test_unauthorized_role_actions`, `test_changing_fee_points`) |
| setProtocolFeeRecipient | BBB | Covered (`test_set_protocol_fee_recipient`, `test_unauthorized_role_actions`) |
| _setAllowedPriceModel | BBB | Covered (Implicitly via `setAllowedPriceModel`) |
| _setProtocolFeePoints | BBB | Covered (Implicitly via `setProtocolFeePoints`) |
| _setCreatorFeePoints | BBB | Covered (Implicitly via `setCreatorFeePoints`) |
| _setProtocolFeeRecipient | BBB | Covered (Implicitly via `setProtocolFeeRecipient`) |
| _handleBuy | BBB | Covered (Implicitly via `lazybuy` and `buy`) |
| _handleSell | BBB | Covered (Implicitly via `sell`) |
| _handleRoyalties | BBB | Covered (Implicitly via `_handleBuy` and `_handleSell`) |
| isValidMintIntent | BBB | Covered (`test_is_valid_mint_intent`, `test_is_valid_mint_intent_invalid`) |
| uri (override) | BBB | Untested |
| _update (override) | BBB | Untested |
| supportsInterface (override) | BBB | Untested |
| Public Variable Getters | BBB | Partial Coverage (Implicit in various tests, e.g., `test_vars_assigned_correctly`, `test_total_issued`) |

### `IAlmostLinearPriceCurve.sol` & `AlmostLinearPriceCurve.sol`

These contracts are primarily utilized within tests indirectly through interactions with the `BBB` contract, particularly in price calculations for minting and burning. Direct test coverage for methods within these contracts was not explicitly mentioned.

### `Shitpost.sol`

| Function Name | Contract | Test Coverage |
|---------------|----------|---------------|
| constructor | Shitpost | Covered (`setUp`) |
| changeFeeRecipient | Shitpost | Untested |
| shitpost | Shitpost | Covered (`test_shitpost`, `test_shitpost_tokenId_nonexistent`) |
| feeRecipient (getter) | Shitpost | Untested |

### `MintIntent.sol`

This contract is a struct and constant definition file and does not contain functions in the traditional sense. The constants and types are used throughout the tests (e.g., in minting tests).

The coverage includes essential functionalities like role management, minting, burning, and fee management, with a strong emphasis on testing various scenarios including edge cases and failure modes. Some areas, particularly overrides and utility functions not directly called or events, remain untested according to the provided information.