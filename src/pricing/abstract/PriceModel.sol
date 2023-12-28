// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IPriceModel} from "../interfaces/IPriceModel.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title PriceModel
 * @dev Abstract contract for price models.
 */
abstract contract PriceModel is IPriceModel, ERC165 {
    uint256 internal immutable _minSupply;
    uint256 internal immutable _maxSupply;
    uint256 internal immutable _minPrice;
    uint256 internal immutable _maxPrice;

    constructor(
        uint256 minSupply,
        uint256 maxSupply,
        uint256 minPrice,
        uint256 maxPrice
    ) {
        require(minSupply <= maxSupply, "Invalid domain");
        require(minPrice <= maxPrice, "Invalid range");

        _minSupply = minSupply;
        _maxSupply = maxSupply;
        _minPrice = minPrice;
        _maxPrice = maxPrice;
    }

    /**
     * See {IPriceModel-minSupply}.
     */
    function minSupply() public view virtual override returns (uint256) {
        return _minSupply;
    }

    /**
     * See {IPriceModel-maxSupply}.
     */
    function maxSupply() public view virtual override returns (uint256) {
        return _maxSupply;
    }

    /**
     * See {IPriceModel-minPrice}.
     */
    function minPrice() public view virtual override returns (uint256) {
        return _minPrice;
    }

    /**
     * See {IPriceModel-maxPrice}.
     */
    function maxPrice() public view virtual override returns (uint256) {
        return _maxPrice;
    }

    /**
     * See {IPriceModel-price}.
     */
    function price(
        uint256 _supply
    ) public view virtual override returns (uint256);

    /**
     * See {IPriceModel-cumulativePrice}.
     */
    function cumulativePrice(
        uint256 _supply
    ) public view virtual override returns (uint256);

    /**
     * See {IPriceModel-sumPrice}.
     */
    function sumPrice(
        uint256 _fromSupply,
        uint256 _toSupply
    ) public view virtual override returns (uint256) {
        return cumulativePrice(_toSupply) - cumulativePrice(_fromSupply);
    }

    /**
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IPriceModel).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
