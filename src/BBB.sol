// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { ERC1155URIStorage } from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import { IERC1155MetadataURI } from "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

import { ERC1155Supply } from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import { ERC1155Burnable } from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { Nonces } from "@openzeppelin/contracts/utils/Nonces.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import { MintIntent, MINT_INTENT_ENCODE_TYPE, MINT_INTENT_TYPE_HASH, EIP712_DOMAIN } from "./structs/MintIntent.sol";

import { ICompositePriceModel } from "./pricing/interfaces/ICompositePriceModel.sol";
import { MyCompositePriceModel } from "./pricing/MyCompositePriceModel.sol";

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { console2 } from "forge-std/src/console2.sol"; // TODO Remove

/**
 * @title bbb
 * @author nftstory
 */
contract BBB is
    AccessControl,
    Pausable,
    ReentrancyGuard,
    ERC1155,
    ERC1155URIStorage,
    ERC1155Supply,
    ERC1155Burnable,
    EIP712,
    Nonces
{
    using Address for address;
    // using ECDSA for bytes32;

    // Define one role in charge of the curve moderation, protocol fee points, creator fee points & protocol fee
    // recipient
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

    // Configurable
    address payable public protocolFeeRecipient;
    uint256 public protocolFeePoints; // 50 = 5% 
    uint256 public creatorFee; // 50 = 5%

    // TODO change awful name
    uint256 public totalNumberOfTokenIds;

    mapping(address => bool) public allowedpriceModels;
    mapping(uint256 => address) public tokenIdTopriceModel;

    mapping(string => uint256) public uriToTokenId;

    // Maps token IDs to their creators' addresses
    mapping(uint256 => address) public creators;

    // Errors
    error InvalidRole();
    error InvalidAddress();
    error TokenDoesNotExist();
    error InvalidAmount();
    error InsufficientFunds();
    error UriAlreadyMinted();
    error InvalidPriceModel();
    error NoChangeToPriceModelAllowState();
    error InvalidIntent();
    error SignatureError(ECDSA.RecoverError, bytes32);

    // Modifiers
    modifier onlyModerator() {
        if (!hasRole(MODERATOR_ROLE, msg.sender)) revert InvalidRole();
        _;
    }

    // Events
    event ProtocolFeeChanged(uint256 newProtocolFeePoints);
    event CreatorFeeChanged(uint256 newCreatorFeePoints);
    event ProtocolFeeRecipientChanged(address newProtocolFeeRecipient);
    event AllowedPriceModelsChanged(address indexed priceModel, bool allowed);

    constructor(
        string memory _name,
        string memory _signingDomainVersion,
        string memory _uri, // Wraps tokenID in a baseURI https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in
            // the EIP]
        address _moderator,
        address payable _protocolFeeRecipient,
        uint256 _protocolFee,
        uint256 _creatorFee
    )
        ERC1155(_uri)
        EIP712(_name, _signingDomainVersion)
    {
        if (_protocolFeeRecipient == address(0)) revert InvalidAddress();
        if (_moderator == address(0)) revert InvalidAddress();

        _grantRole(MODERATOR_ROLE, _moderator);

        protocolFeeRecipient = _protocolFeeRecipient;
        protocolFeePoints = _protocolFee;
        creatorFee = _creatorFee;
        address _initialPriceModel = address(new MyCompositePriceModel(0, 1));
        allowedpriceModels[_initialPriceModel] = true;

        emit ProtocolFeeChanged(_protocolFee);
        emit CreatorFeeChanged(_creatorFee);
        emit ProtocolFeeRecipientChanged(_protocolFeeRecipient);
        emit AllowedPriceModelsChanged(_initialPriceModel, true);
    }

    /**
     * @notice Mint new ERC1155 token(s) using an EIP-712 signature
     * @param data Struct containing minting data
     * @param amount Amount of tokens to mint
     * @param signature EIP-712 signature
     */
    function mintWithIntent(
        MintIntent memory data,
        uint256 amount,
        bytes memory signature
    )
        external
        payable
        nonReentrant
    {
        if (amount <= 0) revert InvalidAmount();

        if (uriToTokenId[data.uri] != 0) revert UriAlreadyMinted();
        if (!allowedpriceModels[data.priceModel]) revert InvalidPriceModel();

        // Get the digest of the MintIntent
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    MINT_INTENT_TYPE_HASH, data.creator, data.signer, data.priceModel, keccak256(bytes(data.uri))
                )
            )
        );

        // Recover the signer of the MintIntent
        if (!SignatureChecker.isValidSignatureNow(data.signer, digest, signature)) revert InvalidIntent();

        // Pricing logic
        ICompositePriceModel priceModel = ICompositePriceModel(data.priceModel);

        // // uint256 price = priceModel.sumPrice(0, amount);
        // uint256 price = priceModel.cumulativePrice(amount);
        // if (msg.value < price) revert InsufficientFunds();

        // // Pay protocol fees
        // Address.sendValue(protocolFeeRecipient, price * protocolFeePoints / 1000);

        // // Pay creator fees
        // Address.sendValue(payable(data.creator), price * creatorFee / 1000);

        uint256 tokenId = ++totalNumberOfTokenIds;

        creators[tokenId] = data.creator;
        tokenIdTopriceModel[tokenId] = data.priceModel;
        uriToTokenId[data.uri] = tokenId;

        // Mint tokens
        _mint(msg.sender, tokenId, amount, "");
        _setURI(tokenId, data.uri);
    }

    /**
     * @notice Mint existing ERC1155 token(s)
     * @param tokenId ID of token to mint
     * @param amount Amount of tokens to mint
     */
    function mint(uint256 tokenId, uint256 amount) external payable nonReentrant {
        if (amount <= 0) revert InvalidAmount();
        if (!exists(tokenId)) revert TokenDoesNotExist();

        // ICompositePriceModel priceModel = ICompositePriceModel(tokenIdTopriceModel[tokenId]);
        uint256 currentSupply = totalSupply(tokenId);
        // uint256 price = priceModel.sumPrice(currentSupply, currentSupply + amount);
        // if (msg.value < price) revert InsufficientFunds();

        // Mint tokens
        _mint(msg.sender, tokenId, amount, "");

        // // Pay protocol fees
        // Address.sendValue(protocolFeeRecipient, price * protocolFeePoints / 1000);

        // // Pay creator fees
        // Address.sendValue(payable(creators[tokenId]), price * creatorFee / 1000);

        // uint256 excess = msg.value - price;

        // if (excess > 0) {
        //     Address.sendValue(payable(msg.sender), excess); // TODO catch revert
        // }
    }

    function burn(uint256 tokenId, uint256 amount) external nonReentrant {
        if (!exists(tokenId)) revert TokenDoesNotExist();
        if (amount <= 0) revert InvalidAmount();
        ICompositePriceModel priceModel = ICompositePriceModel(tokenIdTopriceModel[tokenId]);
        uint256 currentSupply = totalSupply(tokenId);
        uint256 refund = priceModel.sumPrice(currentSupply - amount, currentSupply);
        _burn(msg.sender, tokenId, amount);

        Address.sendValue(payable(msg.sender), refund);
    }

    /// @notice Allows the Moderator to add or remove price models
    function setAllowedPriceModel(address priceModel, bool allowed) external onlyModerator {
        if (allowedpriceModels[priceModel] == allowed) revert NoChangeToPriceModelAllowState();
        allowedpriceModels[priceModel] = allowed;
        emit AllowedPriceModelsChanged(priceModel, allowed);
    }

    // // STILL IN CONSIDERATION
    // function pause() external onlyRole(MODERATOR_ROLE) {
    //     _pause();
    // }

    // function unpause() external onlyRole(MODERATOR_ROLE) {
    //     _unpause();
    // }
    // ========== Overrides ==========

    function uri(uint256 tokenId) public view override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return ERC1155URIStorage.uri(tokenId);
    }

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    )
        internal
        override(ERC1155, ERC1155Supply)
    {
        // TODO just revert and don't call super -- no one needs to this power
        super._update(from, to, ids, values);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC1155)
        returns (bool)
    {
        return AccessControl.supportsInterface(interfaceId) || ERC1155.supportsInterface(interfaceId)
            || interfaceId == type(IERC1155MetadataURI).interfaceId || super.supportsInterface(interfaceId);
    }
}
