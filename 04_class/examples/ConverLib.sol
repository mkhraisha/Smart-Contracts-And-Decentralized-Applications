// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

library ConvertLib {
    function convert(uint _amount, uint _conversionRate) internal pure returns(uint) {
        return _amount * _conversionRate;
    }
}