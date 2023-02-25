// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract ReturnValues {
    uint256 counter;

    function SetNumber() {
        counter = block.number;
    }

    function getBlockNumber() returns (uint256) {
        return counter;
    }

    function getBlockNumber1() returns (uint256 result) {
        result = counter;
    }
}
