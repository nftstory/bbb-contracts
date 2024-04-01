// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
 *
 *                                       @@@@@@@@@@@@@@                   @@@@@@@@@@@
 *                                    @@@@@@@@    @@@@@@@@               @@@  @@@  @@@       @@@@@@@
 *                                  @@@@@    @@@@@@    @@@@@             @@  @@ @@  @@     @@@@@@@@@@@
 *                                 @@@   @@@@@@@@@@@@@@   @@@@          @@   @@@@@  @@     @@@  @@  @@@
 *                       @@@@@@@@@@@   @@@@@@@    @@@@@@@   @@@       @@@@         @@@    @@   @  @  @@@
 *                  @@@@@@@@@@@@@@@   @@@@            @@@@   @@@     @@@   @@@@@@@@@@  @@@@@   @@@@   @@
 *               @@@@@@@              @@       @@@@     @@@   @@    @@@  @@@@@@@@@@  @@@@@          @@@
 *              @@@@    @@@@@@@@@@@   @@@@@   @   @@     @@@  @@@  @@@  @@@         @@@@   @@@@@@@@@@@
 *            @@@@   @@@@@@@@@@@@@@@@@  @@@@@       @     @@   @@  @@  @@@         @@@   @@@@@@@@@@@@
 *           @@@   @@@@@@        @@@@@@@  @@@@       @    @@@  @@ @@   @@         @@@  @@@@
 *          @@@  @@@@@               @@@@  @@@@      @    @@@  @@ @@  @@@        @@@  @@@
 *          @@   @@@        @@@@       @@@   @@@      @   @@   @@ @   @@         @@   @@
 *         @@   @@@       @@@  @@@      @@@@  @@@     @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 *         @@  @@@                @      @@@@  @@@@   @@                                                       @@
 *        @@@  @@@        @         @     @@@@  @@@@  @@                   @@@@@@@@@@@@@@@@@@@                 @@
 *        @@@  @@          @@        @@     @@@   @@@ @@               @@@@                  @@@@              @@
 *         @@  @@@  @        @@@       @@    @@@@  @@@@@            @@@@                        @@@            @@
 *         @@   @@   @          @@@      @    @@@@  @@@@           @@@                            @@@          @@
 *         @@@  @@@    @           @@@    @@   @@@@  @@@         @@@                                @@         @@
 *          @@   @@@      @@          @@@   @@   @@@ @@@        @@                                   @@@       @@
 *           @@   @@@@      @@@@@@        @   @   @@@@@@       @@                                      @@      @@
 *           @@@@  @@@@@         @@@@              @@ @@      @@                                        @@     @@
 *             @@@   @@@@@@                         @ @@     @@       @@@@@@@@@@@@@      @@@@@@@@@@@@@   @     @@
 *              @@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@     @       @             @    @             @  @@    @@
 *                @@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@ @@@    @@      @     @@@@@     @  @     @@@@@     @  @    @@
 *                  @@@@@@@              @@@@        @@@    @@      @    @@@@@@@    @  @    @@@@@@@    @  @@   @@
 *                     @@@@@@@@@   @@@@@       @@@@@ @@@    @        @    @@@@@    @    @    @@@@     @   @@   @@
 *                               @@@@@@@@    @@@@@@@ @@@    @         @@@@@@@@@@@@@      @@@@@@@@@@@@@    @@   @@
 *                          @@@  @@   @@     @@@   @@ @@    @@             @ @                @ @         @    @@
 *                         @@@  @@    @@     @@    @@ @@    @@             @ @                @ @        @@    @@
 *                        @@@  @@@   @@@     @@     @ @@     @@            @ @                @ @        @@    @@
 *                       @@@   @@    @@@     @@     @@@@     @@            @ @ @@         @@@ @ @        @@    @@
 *                     @@@@    @@    @@@     @@@      @@      @@           @ @   @@@@@@@@@@   @ @       @@     @@
 *                  @@@@@@    @@@    @@@      @@      @@       @@          @ @                @ @      @@      @@
 *               @@@@@@        @@     @@      @@@     @@        @@@        @ @                @ @    @@        @@
 *           @@@@@@@@          @@     @@@      @@@    @@         @@@@      @ @                @ @  @@@         @@
 *           @@@@              @@@     @@@      @@@   @@           @@@@    @ @                @ @@@@           @@
 *           @@@               @@@     @@@       @@@@ @@             @@@@@ @ @               @@@@@@            @@
 *            @@@@              @@@     @@@       @@@@@@                @@@@@ @@         @@@@@@@@              @@
 *              @@@@@            @@@     @@@@       @@@@                   @@@@@@@@@@@@@@@@                    @@
 *                @@@@@          @@@@     @@@@       @@@                                                       @@
 *                  @@@@@@        @@@@     @@@@      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 *                     @@@@@@@     @@@@      @@@@     @@@@@@@@@@@@           @@@@@@@@@@@@
 *                        @@@@@@     @@@@      @@@@@        @@@@@@@@@@@@@@@@@@@@       @@@
 *                           @@@@     @@@@@     @@@@@@           @@@@@@@@@@@@  @@@@@    @@@
 *                             @@@@     @@@@@      @@@@@@@                   @@@@ @@     @@
 *                               @@@@@    @@@@@@      @@@@@@@@@@@@@@@      @@@@  @@@     @@
 *                                 @@@@@    @@@@@@@@      @@@@@@@          @@   @@@      @@
 *                                   @@@@@@    @@@@@@@@@@@@@@@@@@@  @@@@    @@@ @@     @@@@
 *                                      @@@@@           @@@@@@@@  @@@@@@@    @@  @@@@@@@@@
 *                                         @@@     @@@@@        @@@   @@     @@   @@@@@@
 *                                          @@     @    @@      @@  @@@@@    @@
 *                                        @@@@     @@  @@      @@@  @@      @@@
 *                                       @@       @@@  @@    @@@@   @@@    @@@
 *                                       @@     @@@@   @@@@@@@@@     @@@@@@@@
 *                                        @@@@@@@@@     @@@@@@        @@@@@
 *                                         @@@@@@
 *
 */
// Token contracts
import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { ERC1155URIStorage } from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import { ERC1155Supply } from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

// Security & utils
import { Ownable, Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

// Custom
import { MintIntent, MINT_INTENT_TYPE_HASH } from "./structs/MintIntent.sol";
import { AlmostLinearPriceCurve } from "./pricing/AlmostLinearPriceCurve.sol";

// Interfaces
import { IAlmostLinearPriceCurve } from "./interfaces/IAlmostLinearPriceCurve.sol";
import { IERC7572 } from "./interfaces/IERC7572.sol";

/**
 * @title bbb
 * @author nftstory
 *
 *        •  •          •  •           •  •
 *    @ @ | /       @ @ | /        @ @ | /
 *   ( b [oo]      ( b [oo]       ( b [oo]
 *  < b b II,     < b b II,      < b b II,
 *    ,, ,          ,, ,           ,, ,
 *
 * @dev Lazily mint ERC-1155 tokens using EIP-712 signatures. Each token's buy/sell price is determined by a price
 * model.
 */
contract BBB is Ownable2Step, ReentrancyGuard, ERC1155, ERC1155URIStorage, ERC1155Supply, EIP712, IERC7572 {
    // Contract metadata
    string contractJson;

    // Configurable
    address payable public protocolFeeRecipient;
    uint256 public protocolFeePoints; // 50 = 5%
    uint256 public creatorFeePoints; // 50 = 5%

    // Total number of extant token IDs
    uint256 public totalIssued;

    // Maps price models to their allowed state
    mapping(address priceModel => bool isAllowed) public allowedPriceModels;

    // Maps token IDs to their price models
    mapping(uint256 tokenId => address priceModel) public tokenIdToPriceModel;

    // Maps mint intent hashes to their token sequential issuance index
    mapping(uint256 tokenId => uint256 sequentialId) public tokenIdToSequentialId;

    // Maps token sequential issuance index to their token IDs
    mapping(uint256 sequentialId => uint256 tokenId) public sequentialIdToTokenId;

    // Maps token IDs to their creators' addresses
    mapping(uint256 tokenId => address creatorAddress) public tokenIdToCreator;

    // Errors
    error InvalidAddress();
    error TokenDoesNotExist();
    error InsufficientFunds();
    error InvalidPriceModel();
    error InvalidIntent();
    error InvalidRecipient();
    error MinRefundNotMet();
    error InvalidFee();

    // Events
    event ProtocolFeeChanged(uint256 newProtocolFeePoints);
    event CreatorFeeChanged(uint256 newCreatorFeePoints);
    event ProtocolFeeRecipientChanged(address indexed newProtocolFeeRecipient);
    event AllowedPriceModelsChanged(address indexed priceModel, bool allowed);

    constructor(
        string memory _contractJson,
        string memory _name,
        string memory _signingDomainVersion,
        address _newOwner,
        address payable _protocolFeeRecipient,
        uint256 _protocolFeePoints,
        uint256 _creatorFeePoints
    )
        ERC1155("")
        EIP712(_name, _signingDomainVersion)
        Ownable(msg.sender)
    {
        if (_protocolFeeRecipient == address(0)) revert InvalidAddress();
        if (_newOwner == address(0)) revert InvalidAddress();

        _setContractJson(_contractJson);
        _setProtocolFeeRecipient(_protocolFeeRecipient);
        _setProtocolFeePoints(_protocolFeePoints);
        _setCreatorFeePoints(_creatorFeePoints);
        // Creates a default price model
        _setAllowedPriceModel(address(new AlmostLinearPriceCurve(3, 10_000, 700_000_000_000_000, 0)), true);
        Ownable2Step.transferOwnership(_newOwner); // New owner must call acceptOwnership();
    }

    /**
     * @notice Fallback function to revert any ETH sent to the contract
     * @dev Prevents accidental ETH transfers to the contract
     */
    receive() external payable {
        revert InvalidRecipient();
    }

    /**
     * @notice Mint ERC1155 token(s) using an EIP-712 signature
     * @param to The address to mint the token to
     * @param amount The amount of tokens to mint
     * @param signature The signature of the mint intent
     * @param data The mint intent
     */
    function lazybuy(
        address to,
        uint256 amount,
        bytes memory signature,
        MintIntent memory data
    )
        external
        payable
        nonReentrant
    {
        // Get the digest of the MintIntent
        bytes32 mintIntentHash = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    MINT_INTENT_TYPE_HASH, data.creator, data.signer, data.priceModel, keccak256(bytes(data.uri))
                )
            )
        );
        // Generate the token ID from the mint intent hash
        uint256 tokenId = uint256(mintIntentHash);

        // If the token has already been minted, mint without the intent
        if (tokenIdToSequentialId[tokenId] != 0) {
            uint256 supplyBeforeMint = totalSupply(tokenId);

            // Mint token
            _mint(to, tokenId, amount, "");

            // Compute and distribute fees, return change (if any) to buyer
            return _handleBuy(
                to,
                msg.value,
                IAlmostLinearPriceCurve(tokenIdToPriceModel[tokenId]),
                tokenIdToCreator[tokenId],
                supplyBeforeMint,
                amount
            );
        }
        // Check if the price model is allowed
        if (!allowedPriceModels[data.priceModel]) revert InvalidPriceModel();

        // Recover the signer of the MintIntent
        if (!SignatureChecker.isValidSignatureNow(data.signer, mintIntentHash, signature)) revert InvalidIntent();

        // Get the token's sequential index
        uint256 sequentialId = ++totalIssued;

        // Store the mint intent data
        tokenIdToCreator[tokenId] = data.creator;
        tokenIdToPriceModel[tokenId] = data.priceModel;

        // Enumerate the token
        tokenIdToSequentialId[tokenId] = sequentialId;
        sequentialIdToTokenId[sequentialId] = tokenId;

        // Mint token
        _mint(to, tokenId, amount, "");

        // ERC1155URIStorage: Set the token's URI
        _setURI(tokenId, data.uri);

        // Compute and distribute fees, return change (if any) to buyer
        _handleBuy(to, msg.value, IAlmostLinearPriceCurve(data.priceModel), data.creator, 0, amount);
    }

    /**
     * @notice Mint existing ERC1155 token(s)
     * @param to Address to mint token to
     * @param tokenId ID of token to mint
     * @param amount Amount of tokens to mint
     */
    function buy(address to, uint256 tokenId, uint256 amount) external payable nonReentrant {
        // Checks-effects-interactions pattern
        // If a num is set for this tokenID then it exists regardless of supply
        if (tokenIdToSequentialId[tokenId] == 0) revert TokenDoesNotExist();

        uint256 supplyBeforeMint = totalSupply(tokenId);

        _mint(to, tokenId, amount, "");

        // Compute and distribute fees, return change (if any) to buyer
        _handleBuy(
            to,
            msg.value,
            IAlmostLinearPriceCurve(tokenIdToPriceModel[tokenId]),
            tokenIdToCreator[tokenId],
            supplyBeforeMint,
            amount
        );
    }

    /**
     * @notice Burn ERC1155 token(s)
     * @param tokenId ID of token to burn
     * @param amount Amount of tokens to burn
     * @param minRefund Minimum amount of ETH to refund or revert
     */
    function sell(uint256 tokenId, uint256 amount, uint256 minRefund) external nonReentrant {
        // if (!exists(tokenId)) revert TokenDoesNotExist();

        uint256 supplyAfterBurn = totalSupply(tokenId) - amount; // This will be the supply after the burn. This will

        _burn(msg.sender, tokenId, amount);

        // Reverts if the minRefund is not met
        _handleSell(msg.sender, tokenId, supplyAfterBurn, amount, minRefund);
    }

    // ========== Admin Functions ==========

    /// @notice Allows the owner to update the contract JSON
    function setContractJson(string memory newContractJson) external onlyOwner {
        _setContractJson(newContractJson);
    }

    /// @notice Allows the owner to add or remove price models
    function setAllowedPriceModel(address priceModel, bool allowed) external onlyOwner {
        _setAllowedPriceModel(priceModel, allowed);
    }

    /// @notice Changing the protocol fee mid-way won't break royalty calculations
    function setProtocolFeePoints(uint256 newProtocolFeePoints) external onlyOwner {
        _setProtocolFeePoints(newProtocolFeePoints);
    }

    /// @notice Changing the creator fee mid-way won't break royalty calculations
    function setCreatorFeePoints(uint256 newCreatorFeePoints) external onlyOwner {
        _setCreatorFeePoints(newCreatorFeePoints);
    }

    /// @notice Changing the protocol fee recipient mid-way won't break royalty calculations
    function setProtocolFeeRecipient(address payable newProtocolFeeRecipient) external onlyOwner {
        _setProtocolFeeRecipient(newProtocolFeeRecipient);
    }

    // ========== Internal Functions ==========

    function _setContractJson(string memory newContractJson) internal {
        contractJson = newContractJson;
        emit ContractURIUpdated();
    }

    function _setAllowedPriceModel(address priceModel, bool allowed) internal {
        allowedPriceModels[priceModel] = allowed;
        emit AllowedPriceModelsChanged(priceModel, allowed);
    }

    function _setProtocolFeePoints(uint256 newProtocolFeePoints) internal {
        if (newProtocolFeePoints > 100) revert InvalidFee();
        protocolFeePoints = newProtocolFeePoints;
        emit ProtocolFeeChanged(newProtocolFeePoints);
    }

    function _setCreatorFeePoints(uint256 newCreatorFeePoints) internal {
        if (newCreatorFeePoints > 100) revert InvalidFee();
        creatorFeePoints = newCreatorFeePoints;
        emit CreatorFeeChanged(newCreatorFeePoints);
    }

    function _setProtocolFeeRecipient(address payable newProtocolFeeRecipient) internal {
        if (newProtocolFeeRecipient == address(this)) revert InvalidAddress();
        protocolFeeRecipient = newProtocolFeeRecipient;
        emit ProtocolFeeRecipientChanged(newProtocolFeeRecipient);
    }

    /**
     * @param buyer The address of the buyer
     * @param msgValue The amount of ETH sent by the buyer
     * @param priceModel The price model used to calculate the price
     * @param creator The address of the creator
     * @param supplyBeforeMint The supply of the token before minting
     * @param mintAmount The amount of tokens minted
     */
    function _handleBuy(
        address buyer,
        uint256 msgValue,
        IAlmostLinearPriceCurve priceModel,
        address creator,
        uint256 supplyBeforeMint,
        uint256 mintAmount
    )
        internal
    {
        (uint256 basePrice, uint256 protocolFee, uint256 creatorFee) =
            _handleRoyalties(priceModel, creator, supplyBeforeMint, mintAmount);
        uint256 totalPrice = basePrice + protocolFee + creatorFee;

        if (msgValue < totalPrice) {
            revert InsufficientFunds();
        } else if (msgValue > totalPrice) {
            uint256 excess = msgValue - totalPrice;
            Address.sendValue(payable(buyer), excess);
        }
        // else {
        //     // Do nothing - the buyer sent exactly the right amount!
        // }
    }

    /**
     * @param seller The address of the seller
     * @param tokenId The ID of the token being sold
     * @param supplyAfterBurn The supply of the token after burning
     * @param burnAmount The amount of tokens burned
     * @param minRefund The minimum amount of ETH to refund
     */
    function _handleSell(
        address seller,
        uint256 tokenId,
        uint256 supplyAfterBurn,
        uint256 burnAmount,
        uint256 minRefund
    )
        internal
    {
        address creator = tokenIdToCreator[tokenId];

        (uint256 basePrice, uint256 protocolFee, uint256 creatorFee) = _handleRoyalties(
            IAlmostLinearPriceCurve(tokenIdToPriceModel[tokenId]), creator, supplyAfterBurn, burnAmount
        );
        uint256 refund = basePrice - protocolFee - creatorFee;
        if (refund < minRefund) revert MinRefundNotMet();
        // Seller gets the base price minus protocol fee minus creator fee
        Address.sendValue(payable(seller), refund);
    }

    /**
     * @param priceModel The price model used to calculate the price
     * @param creator The address of the creator
     * @param currentSupply The current supply of the token
     * @param amount The amount of tokens being minted
     * @return basePrice The base price of the mint
     * @return protocolFee The protocol fee
     * @return creatorFee The creator fee
     */
    function _handleRoyalties(
        IAlmostLinearPriceCurve priceModel,
        address creator,
        uint256 currentSupply,
        uint256 amount
    )
        internal
        returns (uint256, uint256, uint256)
    {
        // Calculate the base price, protocol fee, and creator fee
        uint256 basePrice = priceModel.getBatchMintPrice(currentSupply, amount);
        uint256 protocolFee = basePrice * protocolFeePoints / 1000;
        uint256 creatorFee = basePrice * creatorFeePoints / 1000;

        // Pay protocol fees
        Address.sendValue(protocolFeeRecipient, protocolFee);

        // Pay creator fees
        Address.sendValue(payable(creator), creatorFee);

        // Used in both buy and sell price logic
        return (basePrice, protocolFee, creatorFee);
    }

    // ========== Supporting Functions ==========
    /**
     * @notice Check if a mint intent is valid
     * @dev This convenience function can be used to validate mint intents before minting
     * @param data The mint intent
     * @param signature The signature of the mint intent
     * @return bool Whether the mint intent is valid
     */
    function isValidMintIntent(MintIntent memory data, bytes memory signature) external view returns (bool) {
        // Check if the price model is allowed. This can change over time as price models are added or removed.
        if (!allowedPriceModels[data.priceModel]) revert InvalidPriceModel();

        // Compute the digest of the MintIntent
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    MINT_INTENT_TYPE_HASH, data.creator, data.signer, data.priceModel, keccak256(bytes(data.uri))
                )
            )
        );

        // Recover the signer of the MintIntent
        return SignatureChecker.isValidSignatureNow(data.signer, digest, signature);
    }

    // ========== Overrides ==========

    // Implementation of abstract function in IERC7572
    function contractURI() external view override returns (string memory) {
        return string.concat("data:application/json;utf8,", contractJson);
    }

    function uri(uint256 tokenId) public view override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return ERC1155URIStorage.uri(tokenId);
    }

    // Implementation of abstract function in ERC1155Supply
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    )
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155) returns (bool) {
        return ERC1155.supportsInterface(interfaceId) || super.supportsInterface(interfaceId);
    }
}

/**
 *
 *        •  •          •  •           •  •
 *    @ @ | /       @ @ | /        @ @ | /
 *   ( b [oo]      ( b [oo]       ( b [oo]
 *  < b b II,     < b b II,      < b b II,
 *    ,, ,          ,, ,           ,, ,
 *
 */
