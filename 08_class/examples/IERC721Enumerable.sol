// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

interface IERC721Enumerable {
 function totalSupply() external view returns(uint256);
 function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns(uint256 tokenId);
 function tokenByIndex(uint256 _index) external view returns(uint256);
}