// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { PriceModel } from "../abstract/PriceModel.sol";

/**
 * @title LinearPriceModel
 * @dev Linear price model.
 */
contract LinearPriceModel is PriceModel {
    constructor(
        uint256 _minSupply,
        uint256 _maxSupply,
        uint256 _minPrice,
        uint256 _maxPrice
    )
        PriceModel(_minSupply, _maxSupply, _minPrice, _maxPrice)
    { }

    /**
     * See {IPriceModel-price}.
     */
    function price(uint256 _supply) public view virtual override returns (uint256) {
        if (_supply < _minSupply) {
            // return _minPrice;
            return 0;
        }

        else if (_supply > _maxSupply) {
            // return _maxPrice;
            return 0;
        }

        uint256 _priceRange = _maxPrice - _minPrice;
        uint256 _supplyRange = _maxSupply - _minSupply;
        uint256 _price = _minPrice + ((_supply - _minSupply) * _priceRange) / _supplyRange;

        return _price;
    }

    /**
     * See {IPriceModel-cumulativePrice}.
     */
    function cumulativePrice(uint256 _supply) public view virtual override returns (uint256) {
        // Unoptimized version using for loop
        // TODO use formula to calculate cumulative price directly

        uint256 _cumulativePrice = 0;
        for (uint256 _i = _minSupply; _i < _supply; _i++) {
            _cumulativePrice += price(_i);
        }

        return _cumulativePrice;
    }
}
