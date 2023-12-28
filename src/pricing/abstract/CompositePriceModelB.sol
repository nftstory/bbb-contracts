// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ICompositePriceModel} from "../interfaces/ICompositePriceModel.sol";
import {IPriceModel} from "../interfaces/IPriceModel.sol";
import {CompositePriceModelBase} from "./CompositePriceModelBase.sol";

/**
 * @title CompositePriceModelB
 * @dev Extension of the CompositePriceModelBase contract that allows for creating new models on the spot.
 */
abstract contract CompositePriceModelB is CompositePriceModelBase {
    constructor(uint256 minPriceModelIndex, uint256 maxPriceModelIndex) {
        _minPriceModelIndex = minPriceModelIndex;
        _maxPriceModelIndex = maxPriceModelIndex;
    }

    /**
     * @notice Add a model to the composite price model.
     */
    function _addModel(IPriceModel model) internal {
        _models.push(model);
    }
}
