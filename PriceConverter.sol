// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter{

        function getPrice() internal view returns(uint256)  {
        //adress 0x694AA1769357215DE4FAC081bf1f309aDC325306
        AggregatorV3Interface price = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int answer,,,) = price.latestRoundData();
        //returns 8 decimals value of ETH price so we multiply by 10^10 to make it decimal-equal 
        return uint256(answer*1e10);
    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint256){
        uint256 ethPrice = getPrice();
        //multiplying ETH amount with amount of funder sent
        uint256 ethAmountinUsd = (ethAmount*ethPrice)/ 1e18;
        return ethAmountinUsd;

    }

    function getVersion()internal view returns(uint256){
        //testing Oracle Data Feed
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }   

}