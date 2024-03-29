// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./BBB.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Shitpost is Ownable {
    address payable feeRecipient;
    BBB bbb;

    event Shitpost(address indexed sender, uint256 indexed tokenId, string indexed message);
    
    error TokenDoesNotExist();

    constructor(BBB _bbb, address payable _feeRecipient, address _owner) Ownable(_owner) {
        bbb = BBB(_bbb);
        feeRecipient = _feeRecipient;
    }

    /**
     * @notice Make a shitpost
     * @dev Message value is also emitted in the event
     * @param tokenId The token ID
     * @param message The message to shitpost
     */
    function shitpost(uint256 tokenId, string memory message) external payable {
        if (tokenId != 0 && !bbb.exists(tokenId)) revert TokenDoesNotExist();
        if (msg.value > 0) {
            Address.sendValue(feeRecipient, msg.value);
        }
        emit Shitpost(msg.sender, tokenId, message);
    }
}
