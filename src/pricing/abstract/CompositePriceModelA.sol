// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IPriceModel} from "../interfaces/IPriceModel.sol";
import {PriceModel} from "./PriceModel.sol";
import {CompositePriceModelBase} from "./CompositePriceModelBase.sol";

/**
 * @title CompositePriceModelA
 * @dev Extension of the CompositePriceModelBase contract that allows for combining deployed models.
 */
abstract contract CompositePriceModelA is CompositePriceModelBase {
    constructor(
        uint256 minPriceModelIndex,
        uint256 maxPriceModelIndex,
        IPriceModel[] memory models
    ) {
        _minPriceModelIndex = minPriceModelIndex;
        _maxPriceModelIndex = maxPriceModelIndex;
        _models = models;
    }
}
