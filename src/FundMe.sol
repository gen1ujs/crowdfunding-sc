// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__notOwner();

contract FundMe {
    //sets constant while deployment process "immutable"
    address private immutable i_owner; //me
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        //runs just once while deploying process constructor()
        //refers address who is deploying this smart contract
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5 * (10 ** 18);

    address[] public s_funders;
    mapping(address funder => uint256 amountFunded)
        private s_addresToAmountFunded;

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "didnt send enoug ETH"
        );
        s_funders.push(msg.sender);
        s_addresToAmountFunded[msg.sender] += msg.value;

        // if statement in require function doesnt get true it reverts the code
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 memoryFundersLength = s_funders.length;

        for (
            uint256 funderIndex = 0;
            funderIndex < memoryFundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addresToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            //clearing arrays for withdrawing
            address funder = s_funders[funderIndex];
            s_addresToAmountFunded[funder] = 0;
        }
        //clear funders array
        s_funders = new address[](0);
        //transfer, send, call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner,"You must be the owner.");
        if (msg.sender != i_owner) {
            revert FundMe__notOwner();
        }

        _; //refers codes which is gonna run inside function after checking the authorization
    }

    //to protect users from fund loss
    receive() external payable {
        fund();
    }

    //if data exists
    fallback() external payable {
        fund();
    }

    //viewları ayrı olacak çünkü private yapmak more gas efficient

    function getAddress2Amount(
        address _address
    ) external view returns (uint256) {
        return s_addresToAmountFunded[_address];
    }

    function getFundersbyIndex(uint256 _index) external view returns (address) {
        return s_funders[_index];
    }

    function getFunders() external view returns (address[] memory) {
        return s_funders;
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
