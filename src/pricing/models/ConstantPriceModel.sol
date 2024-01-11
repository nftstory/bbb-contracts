// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {PriceModel} from "../abstract/PriceModel.sol";

/**
 * @title ConstantPriceModel
 * @dev Constant price model.
 */
contract ConstantPriceModel is PriceModel {
    constructor(
        uint256 _minSupply,
        uint256 _maxSupply,
        uint256 _price
    ) PriceModel(_minSupply, _maxSupply, _price, _price) {}

    /**
     * See {IPriceModel-price}.
     */
    function price(uint256 supply) public view virtual override returns (uint256) {
        if (supply < _minSupply) {
            return 0;
        }
        else if (supply > _maxSupply) {
            return 0;
        }
        return _minPrice; // constant price
    }

    /**
     * See {IPriceModel-cumulativePrice}.
     */
    function cumulativePrice(
        uint256 supply
    ) public view virtual override returns (uint256) {
        return _minPrice * supply;
    }
}
