// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract TestBlockminer {
    
    function getCoinbase() public view returns(address){
        return block.coinbase;
    }
}