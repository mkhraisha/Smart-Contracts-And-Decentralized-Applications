// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

// contract definition starts
contract Charity{

     struct donor{
        uint amount;
        string data;
     }
     mapping(address => donor) public donors;

     address public trustee;

     constructor() public {
        trustee = msg.sender;
     }
	
     function donate(string memory _message) external payable{
         require(msg.value > 0);
         donors[msg.sender] = donor(msg.value, _message);
     }

     modifier onlyTrustee(){
         require(msg.sender == trustee);
         _;
     }

     function withdraw() onlyTrustee payable public {
         payable(trustee).transfer(address(this).balance);
     }
} // Ends here