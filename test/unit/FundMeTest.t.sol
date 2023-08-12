// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../../src/FundMe.sol";
import {DeployContract} from "../../script/DeployContract.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant BALANCE = 10 ether;
    uint256 constant gasPrice = 1;

    function setUp() external {
        //ismi setUp olmak zorunda

        DeployContract deployContract = new DeployContract();
        fundMe = deployContract.run();
        vm.deal(USER, BALANCE);
    }

    function testMinimumUSD() public {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersion() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); //altında reverlenmesini beklediğimiz sit i yazıyoruz

        fundMe.fund();
    }

    function testAmount2Funded() public fundedByUSER {
        uint256 amountFunded = fundMe.getAddress2Amount(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    //her test fonskiyonu farklı bir environment
    function testFundersArray() public fundedByUSER {
        address funder = fundMe.getFundersbyIndex(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public fundedByUSER {
        vm.expectRevert();
        vm.prank(USER); // line line yazmak gerek testi
        fundMe.withdraw();
    }

    function testWithdrawFunctionality() public {
        //Arrange
        uint256 startingBalanceContract = address(fundMe).balance;
        uint256 startingBalanceOwner = fundMe.getOwner().balance;
        //Act

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //Assert
        uint256 endingBalanceContract = address(fundMe).balance;
        uint256 endingBalanceOwner = fundMe.getOwner().balance;

        assertEq(endingBalanceContract, 0);
        assertEq(
            endingBalanceOwner,
            startingBalanceOwner + startingBalanceContract
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public fundedByUSER {
        //hoax = prank()+deal()
        uint160 numberOfFunder = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < numberOfFunder; i++) {
            hoax(address(i), SEND_VALUE); //hoax vmsiz
            fundMe.fund{value: SEND_VALUE}();
        }

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assertEq((fundMe.getFunders()).length, 0);
    }

    function testWithdrawFromMultipleFunders() public fundedByUSER {
        //hoax = prank()+deal()
        uint160 numberOfFunder = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < numberOfFunder; i++) {
            hoax(address(i), SEND_VALUE); //hoax vmsiz
            fundMe.fund{value: SEND_VALUE}();
        }

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assertEq((fundMe.getFunders()).length, 0);
    }

    modifier fundedByUSER() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
    //gas price for local anvil chain is 0
    // https://youtu.be/sas02qSFZ74?t=6501
    // private doesnt exist in storage "gas efficiency"
}
