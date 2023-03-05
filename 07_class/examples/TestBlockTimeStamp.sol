// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract TestBlockTimestamp {
    
    function getTime() public view returns(uint){
        return block.timestamp;
    }
}