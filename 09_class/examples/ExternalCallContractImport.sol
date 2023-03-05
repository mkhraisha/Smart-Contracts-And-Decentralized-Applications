// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

import "./ExternalCall.sol";
 
contract ConsumerV2 {

    PriceFeed public priceFeedContract;

    constructor (address _priceFeed) {
        priceFeedContract = PriceFeed(_priceFeed); 
    }    
    
  function callFeed() public view returns(uint) {
    return priceFeedContract.getPrice();
  }
}