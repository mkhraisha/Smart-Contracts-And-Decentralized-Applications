// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract GeneralMapping {
    mapping(uint256 => address) names;

    uint256 counter;

    function addtoMapping(address addressDetails) returns (uint256) {
        counter = counter + 1;
        names[counter] = addressDetails;

        return counter;
    }

    function getMappingMember(uint256 id) returns (address) {
        return names[id];
    }
}
