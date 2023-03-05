// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

// realizing ABI of PriceFeed contract
interface IPriceFeed {
  function getPrice() external view returns (uint);
}