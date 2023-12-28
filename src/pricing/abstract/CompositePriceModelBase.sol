// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ICompositePriceModel} from "../interfaces/ICompositePriceModel.sol";
import {IPriceModel} from "../interfaces/IPriceModel.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title CompositePriceModelBase
 * @dev Abstract contract for composite price models.
 * This contract allows for combining multiple price models and querying them based on index or supply.
 */
abstract contract CompositePriceModelBase is ICompositePriceModel, ERC165 {
    uint internal immutable _minPriceModelIndex;
    uint internal immutable _maxPriceModelIndex;
    IPriceModel[] internal _models;

    /**
     * See {IPriceModel-price}.
     */
    function price(uint256 supply) public view override returns (uint256) {
        IPriceModel model = modelAtSupply(supply);
        return model.price(supply);
    }

    /**
     * See {IPriceModel-price}.
     */
    function minSupply() public view returns (uint256) {
        return _models[0].minSupply();
    }

    /**
     * See {IPriceModel-price}.
     */
    function maxSupply() public view returns (uint256) {
        return _models[_models.length - 1].maxSupply();
    }

    /**
     * See {IPriceModel-price}.
     */
    function minPrice() public view returns (uint256) {
        return _models[_minPriceModelIndex].minPrice();
    }

    /**
     * See {IPriceModel-price}.
     */
    function maxPrice() public view returns (uint256) {
        return _models[_maxPriceModelIndex].maxPrice();
    }

    /**
     * See {ICompositePriceModel-models}.
     */
    function models() public view override returns (IPriceModel[] memory) {
        return _models;
    }

    /**
     * See {ICompositePriceModel-modelAtIndex}.
     */
    function modelAtIndex(
        uint256 index
    ) public view override returns (IPriceModel) {
        return _models[index];
    }

    /**
     * See {ICompositePriceModel-modelAtSupply}.
     */
    function modelAtSupply(
        uint256 supply
    ) public view override returns (IPriceModel) {
        uint256 _modelCount = modelCount();
        for (uint256 i = 0; i < _modelCount; i++) {
            if (supply <= _models[i].maxSupply()) {
                return _models[i];
            }
        }
        revert("CompositePriceModel: no model found");
    }

    /**
     * See {ICompositePriceModel-modelIndexAtSupply}.
     */
    function modelIndexAtSupply(
        uint256 supply
    ) public view override returns (uint256) {
        uint256 _modelCount = modelCount();
        for (uint256 i = 0; i < _modelCount; i++) {
            if (supply <= _models[i].maxSupply()) {
                return i;
            }
        }
        revert("CompositePriceModel: no model found");
    }

    /**
     * See {ICompositePriceModel-modelCount}.
     */
    function modelCount() public view override returns (uint256) {
        return _models.length;
    }

    /**
     * Helper function to get all models up to a given supply.
     * @param supply The supply to get models up to
     * @return An array of IPriceModel interfaces representing all the price models
     */
    function modelsToSupply(
        uint256 supply
    ) internal view returns (IPriceModel[] memory) {
        uint256 _lastModelIndex = modelIndexAtSupply(supply);
        uint256 _modelCount = _lastModelIndex + 1;
        IPriceModel[] memory _models = new IPriceModel[](_modelCount);
        for (uint256 i = 0; i < _modelCount; i++) {
            _models[i] = modelAtIndex(i);
        }
        return _models;
    }

    /**
     * See {IPriceModel-cumulativePrice}.
     */
    function cumulativePrice(
        uint256 supply
    ) public view override returns (uint256) {
        IPriceModel[] memory _modelsToSupply = modelsToSupply(supply);
        uint256 _modelCount = _models.length;
        uint256 _price = 0;
        for (uint256 i = 0; i < _modelCount; i++) {
            uint256 _fromSupply = _modelsToSupply[i].minSupply();
            uint256 _maxSupply = _modelsToSupply[i].maxSupply();
            uint256 _toSupply = _maxSupply < supply ? _maxSupply : supply;
            _price += _modelsToSupply[i].sumPrice(_fromSupply, _toSupply);
        }
        return _price;
    }

    /**
     * See {IPriceModel-sumPrice}.
     */
    function sumPrice(
        uint256 fromSupply,
        uint256 toSupply
    ) public view returns (uint256) {
        // Return the difference between the cumulative prices
        // TODO Optimize as this is VERY inefficient lol
        return cumulativePrice(toSupply) - cumulativePrice(fromSupply);

        // uint256 _modelsToStartSupply = modelIndexAtSupply(fromSupply);
        // uint256 _modelsToEndSupply = modelIndexAtSupply(toSupply);
        // uint256 _price = 0;
        // for (uint256 i = _modelsToStartSupply; i <= _modelsToEndSupply; i++) {
        //     uint256 _fromSupply = _models[i].minSupply();
        //     uint256 _toSupply = _models[i].maxSupply();
        //     if (_fromSupply < fromSupply) {
        //         _fromSupply = fromSupply;
        //     }
        //     if (_toSupply > toSupply) {
        //         _toSupply = toSupply;
        //     }
        //     _price += _models[i].sumPrice(_fromSupply, _toSupply);
        // }
    }

    /**
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(ICompositePriceModel).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
