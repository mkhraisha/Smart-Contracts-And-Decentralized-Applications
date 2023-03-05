// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

import "./IPriceFeed.sol";
 
contract ConsumerV1 {
  function callFeed(address _priceFeed) public view returns(uint) {
    return IPriceFeed(_priceFeed).getPrice();
  }
}
