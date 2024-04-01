// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { IAlmostLinearPriceCurve } from "../interfaces/IAlmostLinearPriceCurve.sol";

/**
 * @title AlmostLinearPriceCurve
 * @notice This contract implements an almost linear price curve represented by the equation y = ax + b,
 *         where 'a' is determined by m/n, and 'b' is the intercept. The curve has a constant value for x
 *         less than a specified cutoff point, beyond which it becomes linear.
 */
contract AlmostLinearPriceCurve is IAlmostLinearPriceCurve {
    // The number of decimal places to support fractional values.
    uint256 public constant decimals = 18;

    // Numerator for the slope parameter 'a' in the equation y = ax + b.
    uint256 public immutable weiSlopeNumerator;

    // Denominator for the slope parameter 'a' in the equation y = ax + b.
    uint256 public immutable weiSlopeDenominator;

    // Y intercept parameter 'b' in the equation y = ax + b.
    uint256 public immutable weiIntercept;

    // Value of X where the constant curve becomes linear.
    uint256 public immutable linearBeginsAt;

    /**
     * @dev Contract constructor initializes parameters for the almost linear price curve.
     * @param _weiSlopeNumerator Numerator for the slope parameter 'a'.
     * @param _weiSlopeDenominator Denominator for the slope parameter 'a'.
     * @param _weiIntercept Y intercept parameter 'b'.
     * @param _linearBeginsAt Value of X where the constant curve becomes linear.
     */
    constructor(
        uint256 _weiSlopeNumerator,
        uint256 _weiSlopeDenominator,
        uint256 _weiIntercept,
        uint256 _linearBeginsAt
    ) {
        weiSlopeNumerator = _weiSlopeNumerator;
        weiSlopeDenominator = _weiSlopeDenominator;
        weiIntercept = _weiIntercept;
        linearBeginsAt = _linearBeginsAt;
    }

    /**
     * @dev Get the price at the next point on the almost linear price curve.
     * @param currentSupply The current X coordinate.
     * @return The price at the next X coordinate.
     */
    function getNextMintPrice(uint256 currentSupply) public view returns (uint256) {
        if (currentSupply < linearBeginsAt) {
            currentSupply = linearBeginsAt;
        }
        return (weiSlopeNumerator * (currentSupply + 1) * (10 ** decimals)) / weiSlopeDenominator + weiIntercept;
    }

    /**
     * @dev Get the total price for a batch of consecutive X coordinates on the almost linear price curve.
     * @param currentSupply The starting X coordinate.
     * @param amount The number of consecutive X coordinates in the batch.
     * @return The total price for the batch.
     */
    function getBatchMintPrice(uint256 currentSupply, uint256 amount) external view returns (uint256) {
        uint256 totalPrice;
        for (uint256 i = currentSupply; i < currentSupply + amount;) {
            totalPrice += getNextMintPrice(i);
            unchecked {
                ++i;
            }
        }
        return totalPrice;
    }
}
