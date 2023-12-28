// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IPriceModel} from "../interfaces/IPriceModel.sol";

/**
 * @title ICompositePriceModel
 * @dev Interface extending IPriceModel for composite price models.
 * This interface allows for combining multiple price models and querying them based on index or supply.
 */
interface ICompositePriceModel is IPriceModel {
    /**
     * @notice Retrieves the price model at a given index
     * @param index The index of the price model
     * @return model The price model interface at the specified index
     */
    function modelAtIndex(
        uint256 index
    ) external view returns (IPriceModel model);

    /**
     * @notice Finds the index of the price model applicable for a given supply
     * @param supply The supply amount to find the relevant price model index for
     * @return model The index of the applicable price model
     */
    function modelAtSupply(
        uint256 supply
    ) external view returns (IPriceModel model);

    /**
     * @notice Finds the index of the price model applicable for a given supply
     * @param supply The supply amount to find the relevant price model index for
     * @return index The index of the applicable price model
     */
    function modelIndexAtSupply(
        uint256 supply
    ) external view returns (uint256 index);

    /**
     * @notice Gets the total number of price models available in the composite
     * @return The total count of price models as a uint256
     */
    function modelCount() external view returns (uint256);

    /**
     * @notice Retrieves all price models in the composite
     * @return An array of IPriceModel interfaces representing all the price models
     */
    function models() external view returns (IPriceModel[] memory);
}
