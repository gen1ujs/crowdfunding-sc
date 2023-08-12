// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployContract} from "../../script/DeployContract.s.sol";
import {FundFundMe} from "../../script/Interactions.s.sol";

contract InteractionTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant BALANCE = 10 ether;
    uint256 constant gasPrice = 1;

    function setUp() external {
        DeployContract deployContract = new DeployContract();
        fundMe = deployContract.run();
        vm.deal(USER, BALANCE);
    }

    function testUserCanFundInteraction() public {
        FundFundMe fundFundMe = new FundFundMe();
        console.log(address(this).balance);
        address[] memory arrayadres = fundMe.getFunders();
        console.log(arrayadres.length);
        fundFundMe.fundFundMeFunction(address(fundMe));

        address funder = fundMe.getFundersbyIndex(0);
        assertEq(funder, USER);
    }
}
