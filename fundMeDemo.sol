//SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

error fundMe_notEnoughMoney();

contract fundMeDemo {

    uint256 public total_funds;
    address[] public s_funders;
    address public i_owner;
    mapping(address => uint256) public records;

    // 1 eth = 10e18 Wei
    // 1* 10e16 = 0.01 ethers
    // 20000000000000000 Wei= 0.02 ethers
    uint256 constant fee = 10**16;

    modifier onlyOwner {
      require(msg.sender == i_owner);
      _;
    }

    constructor(){
        total_funds = 0;
        i_owner = msg.sender;
    }

    //amount to use as value while running fundMe is: 20000000000000000 
    function fundMe() public payable{ 
        if (msg.value < fee) revert fundMe_notEnoughMoney();
        s_funders.push(msg.sender);
        total_funds = total_funds + uint256(msg.value);
        records[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner payable{
        payable(msg.sender).transfer(address(this).balance);
        address[] memory buffer_s_funders = s_funders;
        for ( uint256 i=0; i < buffer_s_funders.length; i++){
            records[buffer_s_funders[i]] = 0;
        }
        s_funders = new address[](0);
    }
    
}
