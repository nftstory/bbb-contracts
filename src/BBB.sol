// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155URIStorage} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";

import {ICompositePriceModel} from "./pricing/interfaces/ICompositePriceModel.sol";
import {MyCompositePriceModel} from "./pricing/MyCompositePriceModel.sol";

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title bbb1155
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
    // Define one role in charge of the curve moderation, protocol fee points, creator fee points & protocol fee recipient
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

    // Configurable
    address public protocolFeeRecipient;
    uint256 public protocolFeePoints; // 50 = 5%
    uint25 public creatorFee; // 50 = 5%

    // TODO change awful name
    uint256 public totalNumberOfTokenIds;

    mapping(address => bool) public allowedpriceModels;
    mapping(uint256 => address) public tokenIdTopriceModel;

    mapping(string => uint256) public uriToTokenId;

    // Maps token IDs to their creators' addresses
    mapping(uint256 => address) public creators;

    // Typehash used for EIP-712 compliance
    bytes32 private constant PERMIT_TYPEHASH =
        keccak256(
            "Mint1155(address creator,address priceModel,uint256 tokenId,bytes data)"
        );

    // Struct to hold minting data
    struct Mint1155Data {
        address creator; // The creator of the 1155
        address signer; // The "large blob"
        address priceModel;
        string uri;
    }

    // error InvalidRole; TODO
    // error InvalidAddress;

    modifier onlyModerator() {
        require(
            hasRole(MODERATOR_ROLE, msg.sender),
            "Lazy1155: Caller is not a moderator"
        );
        _;
    }
    event ProtocolFeeChanged(uint256 newProtocolFeePoints);
    event CreatorFeeChanged(uint256 newCreatorFeePoints);
    event ProtocolFeeRecipientChanged(address newProtocolFeeRecipient);

    constructor(
        string memory _uri,
        address moderator,
        address _protocolFeeRecipient,
        uint256 _protocolFee,
        uint256 _creatorFee
    ) ERC1155(_uri) EIP712("Lazy1155", "1") {
        require(_protocolFeeRecipient != address(0), InvalidAddress());

        _setupRole(MODERATOR_ROLE, moderator);

        protocolFeeRecipient = _protocolFeeRecipient;
        protocolFeePoints = _protocolFee;
        creatorFee = _creatorFee;

        emit ProtocolFeeChanged(_protocolFee);
        emit CreatorFeeChanged(_creatorFee);
        emit ProtocolFeeRecipientChanged(_protocolFeeRecipient);
    }

    /**
     * @notice Mint ERC1155 token(s) using an EIP-712 signature
     * @param data Struct containing minting data
     * @param sig EIP-712 signature
     */
    // function mintPromise(
    //     Mint1155Data memory data,
    //     bytes memory sig
    // ) external payable nonReentrant returns (uint256 amountMinted) {
    //     require(
    //         msg.value >= totalPrice,
    //         "Lazy1155: Insufficient funds to mint"
    //     );

    //     require(amount > 0, "Lazy1155: Amount must be > 0");
    //     require(amount <= data.supply, "Lazy1155: Amount must be <= supply");
    //     require(allowedpriceModels[data.priceModel], "Lazy1155: Price curve not allowed");
    //     tokenIdTopriceModel[data.tokenId] = data.priceModel;

    //     uint256 currentSupply = totalSupply(data.tokenId);
    //     uint256 totalPrice = ICompositePriceModel(data.priceModel).sumPrice(
    //         currentSupply,
    //         currentSupply + amount
    //     );

    //     // TODO refund excess funds

    //     if (creators[data.tokenId] == address(0)) {
    //         creators[data.tokenId] = data.creator;
    //         // maxSupplies[data.tokenId] = data.supply;
    //     } else {
    //         require(
    //             creators[data.tokenId] == data.creator,
    //             "Lazy1155: Creator mismatch"
    //         );
    //     }

    //     // Use EIP-712 nonce
    //     bytes32 structHash = keccak256(
    //         abi.encode(
    //             PERMIT_TYPEHASH,
    //             data.creator,
    //             data.priceModel, // NEW
    //             _useNonce(data.creator), // TODO this won't be needed
    //             data.tokenId,
    //             data.supply,
    //             keccak256(bytes(data.uri))
    //         )
    //     );
    //     // Use _hashTypedDataV4
    //     bytes32 digest = _hashTypedDataV4(structHash);

    //     // Recover signer
    //     address signer = ECDSA.recover(digest, sig);
    //     require(signer == data.creator, "Lazy1155: Invalid signature");

    //     // Mint tokens
    //     _mint(msg.sender, data.tokenId, amount, "");
    //     _setURI(data.tokenId, data.uri);
    // }

    /**
     * @notice Mint new ERC1155 token(s) using an EIP-712 signature
     * @param data Struct containing minting data
     * @param v v component of EIP-712 signature
     * @param r r component of EIP-712 signature
     * @param s s component of EIP-712 signature
     */
    function mintPromise(
        Mint1155Data memory data,
        uint256 amount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable nonReentrant {
        require(amount > 0, "Lazy1155: Amount must be > 0");

        require(uriToTokenId[data.uri] != 0, "Lazy1155: uri already in use");
        require(
            allowedpriceModels[data.priceModel],
            "Lazy1155: priceModel not allowed"
        );
        require(ECDSA.ecrecover(hash, v, r, s)); // Signer maxi

        // We have to verify that the intent signer == data.signer TODO
        // We need to store the data.creator in the creators mapping ✅
        // We need to store the price model ✅
        // We need to compute the price from the curve ✅
        // We need to store the uri ✅
        // _mint the nft ✅
        // Pay fees x2 TODO

        ICompositePriceModel priceModel = ICompositePriceModel(data.priceModel);

        uint256 price = priceModel.sumPrice(0, amount);
        require(msg.value >= price, "Lazy1155: Insufficient funds to mint");

        // option b) full 6492 reliance - deploy the smart account when purchased
        uint256 tokenId = ++totalNumberOfTokenIds; // TODO check

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
    function mint(uint256 tokenId, uint256 amount) external payable {
        // require(amount > 0, "Lazy1155: Amount must be > 0");

        require(exists(tokenId), "Lazy1155: Token does not exist");
        require(amount > 0, "Lazy1155: Amount must be > 0");

        ICompositePriceModel priceModel = ICompositePriceModel(
            tokenIdTopriceModel[tokenId]
        );
        uint256 currentSupply = totalSupply(tokenId);
        uint256 price = priceModel.sumPrice(
            currentSupply,
            currentSupply + amount
        );
        require(msg.value >= price, "Lazy1155: Insufficient funds to mint");
        // We have to verify that the intent signer == data.signer TODO
        // We need to store the data.creator in the creators mapping ✅
        // We need to store the price model ✅
        // We need to compute the price from the curve ✅
        // We need to store the uri ✅
        // _mint the nft ✅
        // Pay fees x2 TODO

        ICompositePriceModel priceModel = ICompositePriceModel(data.priceModel);

        uint256 price = priceModel.sumPrice(0, amount);

        // Mint tokens
        _mint(msg.sender, tokenId, amount, "");

        uint256 excess = msg.value - price;

        if (excess > 0) {
            payable(msg.sender).sendValue(excess);
        }
    }

    function burn(uint256 tokenId, uint256 amount) external {
        require(exists(tokenId), "Lazy1155: Token does not exist");
        require(amount > 0, "Lazy1155: Amount must be > 0");
        ICompositePriceModel priceModel = ICompositePriceModel(
            tokenIdTopriceModel[tokenId]
        );
        uint256 currentSupply = totalSupply(tokenId);
        uint256 refund = priceModel.sumPrice(
            currentSupply - amount,
            currentSupply
        );
        _burn(msg.sender, tokenid, amount);

        payable(msg.sender).sendValue(refund);
    }

    /**
     * @notice Mint new ERC1155 token(s) directly
     * @param data Struct containing minting data
     * @param amount Amount of tokens to mint
     */
    // function mintDirectly(Mint1155Data memory data, uint256 amount) external {
    //     require(amount > 0, "Lazy1155: Amount must be > 0");
    //     require(amount <= data.supply, "Lazy1155: Amount must be <= supply");

    //     require(
    //         creators[data.tokenId] == address(0),
    //         "Lazy1155: Token already minted"
    //     );
    //     creators[data.tokenId] = data.creator;
    //     maxSupplies[data.tokenId] = data.supply;

    //     // Mint tokens
    //     _mint(msg.sender, data.tokenId, amount, "");
    //     _setURI(data.tokenId, data.uri);
    // }

    // ========== Overrides ==========

    function uri(
        uint256 tokenId
    ) public view override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return ERC1155URIStorage.uri(tokenId);
    }

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }

    // STILL IN CONSIDERATION
    function pause() external onlyRole(MODERATOR_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(MODERATOR_ROLE) {
        _unpause();
    }
}
