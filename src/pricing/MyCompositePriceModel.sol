// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IPriceModel} from "./interfaces/IPriceModel.sol";
import {CompositePriceModelB} from "./abstract/CompositePriceModelB.sol";

import {ConstantPriceModel} from "./models/ConstantPriceModel.sol";
import {LinearPriceModel} from "./models/LinearPriceModel.sol";

/**
 * @title MyCompositePriceModel
 * @dev Composite price model for testing purposes.
 */
contract MyCompositePriceModel is CompositePriceModelB {
    constructor(
        uint256 minPriceModelIndex,
        uint256 maxPriceModelIndex
    ) CompositePriceModelB(minPriceModelIndex, maxPriceModelIndex) {
        _addModel(new ConstantPriceModel(0, 1000, 100));
        _addModel(new LinearPriceModel(101, 1000, 1001, 2000));
        // _addModel(new ConstantPriceModel(1001, 2000, 200));
    }
}