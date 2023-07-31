// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error notOwner();


contract FundMe{

    //sets constant while deployment process "immutable"
    address public immutable i_owner; //me

    constructor() {
        //runs just once while deploying process constructor()
        //refers address who is deploying this smart contract
       i_owner = msg.sender;
    }

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5 * (10**18);

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addresToAmountFunded;


    function fund() public payable  {

        require( msg.value.getConversionRate() >= MINIMUM_USD ,"didnt send enoug ETH");
        funders.push(msg.sender);
        addresToAmountFunded[msg.sender] += msg.value;

        // if statement in require function doesnt get true it reverts the code
    }

    function withdraw () public onlyOwner {

        for(uint256 funderIndex=0;funderIndex < funders.length;funderIndex++){
            //clearing arrays for withdrawing
            address funder = funders[funderIndex];
            addresToAmountFunded[funder] = 0;
        }
        //clear funders array
        funders = new address[](0);
        //transfer, send, call
        (bool callSuccess,)=payable(msg.sender).call{value:address(this).balance}("");
        require(callSuccess,"Call failed");
    }

    modifier onlyOwner(){
        // require(msg.sender == i_owner,"You must be the owner.");
        if(msg.sender != i_owner){
            revert notOwner();
        }

        _; //refers codes which is gonna run inside function after checking the authorization
    }

    //to protect users from fund loss
    receive() external payable{
        fund();
    }

    //if data exists
    fallback() external payable {
        fund();
    }

}