// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 public constant SEND_VALUE = 1 ether;

    function fundFundMeFunction(address mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe fundMe = FundMe(payable(mostRecentDeployment));
        fundMe.fund{value: SEND_VALUE}();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        fundFundMeFunction(mostRecentlyDeployed);
    }
}
