// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface IAlmostLinearPriceCurve {
    function getNextMintPrice(uint256 currentSupply) external view returns (uint256);
    function getBatchMintPrice(uint256 currentSupply, uint256 amount) external view returns (uint256);
}
