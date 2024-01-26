// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title IPriceModel
 * @dev Interface for a price model, compliant with the ERC165 standard.
 * This interface defines methods for querying supply domain and price range,
 * as well as calculating prices based on supply.
 */
interface IPriceModel is IERC165 {
    /**
     * @notice Gets the minimum defined supply for the pricing model
     * @return The minimum supply as a uint256
     */
    function minSupply() external view returns (uint256);

    /**
     * @notice Gets the maximum defined supply for the pricing model
     * @return The maximum supply as a uint256
     */
    function maxSupply() external view returns (uint256);

    /**
     * @notice Gets the minimum defined price for the pricing model
     * @return The minimum price as a uint256
     */
    function minPrice() external view returns (uint256);

    /**
     * @notice Gets the maximum defined price for the pricing model
     * @return The maximum price as a uint256
     */
    function maxPrice() external view returns (uint256);

    /**
     * @notice Calculates the price for the token at a given supply
     * @param supply The supply amount to calculate the price for
     * @return The calculated price as a uint256
     */
    function price(uint256 supply) external view returns (uint256);

    /**
     * @notice Calculates the cumulative price for a given supply
     * @param supply The supply amount to calculate the cumulative price for
     * @return The calculated cumulative price as a uint256
     */
    function cumulativePrice(uint256 supply) external view returns (uint256);

    /**
     * @notice Calculates the cumulative price between two supply amounts
     * @param fromSupply The starting supply for the calculation
     * @param toSupply The ending supply for the calculation
     * @return The cumulative price as a uint256
     */
    function sumPrice(
        uint256 fromSupply,
        uint256 toSupply
    ) external view returns (uint256);
}
