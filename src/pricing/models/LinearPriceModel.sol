// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {PriceModel} from "../abstract/PriceModel.sol";

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
    ) PriceModel(_minSupply, _maxSupply, _minPrice, _maxPrice) {}

    /**
     * See {IPriceModel-price}.
     */
    function price(
        uint256 _supply
    ) public view virtual override returns (uint256) {
        if (_supply <= _minSupply) {
            return _minPrice;
        }

        if (_supply >= _maxSupply) {
            return _maxPrice;
        }

        uint256 _priceRange = _maxPrice - _minPrice;
        uint256 _supplyRange = _maxSupply - _minSupply;
        uint256 _price = _minPrice +
            ((_supply - _minSupply) * _priceRange) /
            _supplyRange;

        return _price;
    }

    /**
     * See {IPriceModel-cumulativePrice}.
     */
    function cumulativePrice(
        uint256 _supply
    ) public view virtual override returns (uint256) {
        // Using the formula for the sum of an arithmetic series

        if (_supply <= _minSupply) {
            return _minPrice * _supply;
        }

        if (_supply >= _maxSupply) {
            return _maxPrice * _supply;
        }

        uint256 _priceRange = _maxPrice - _minPrice;
        uint256 _supplyRange = _maxSupply - _minSupply;
        uint256 _price = _minPrice +
            ((_supply - _minSupply) * _priceRange) /
            _supplyRange;

        uint256 _n = _supply - _minSupply;
        uint256 _sum = (_n * (_n + 1)) / 2;

        return _price * _sum;
    }
}
