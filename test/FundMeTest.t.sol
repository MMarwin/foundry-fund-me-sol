//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SENDING_VALUE = 0.1 ether;
    uint256 constant BALANCE = 10 ether;

    modifier prank() {
        vm.prank(USER);
        fundMe.fund{value: SENDING_VALUE}();
        vm.stopPrank();
        _;
    }

    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, BALANCE);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.fund{value: 0}();
    }

    function testFundUpdatesFundedDataStructure() public prank {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SENDING_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public prank {
        address funders = fundMe.getFunder(0);
        assertEq(funders, USER);
    }

    function testOnlyOwnerCanCallWithdrawFunction() public {
        /*
        // Get Owner
        address owner = fundMe.getOwner();
        console.log(owner);
        */
        address owner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        vm.prank(owner);
        fundMe.withdraw();
    }

    function testCallWithdrawFailIfNotOwnerCallIt() public prank {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public prank {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawWithMultipleFunders() public prank {
        uint160 numberOfFunders = 10;
        uint160 startingFundersIndex = 1;

        for (uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            hoax(address(i), BALANCE);
            fundMe.fund{value: SENDING_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);
    }

    function testCheaperWithdrawWithMultipleFunders() public prank {
        uint160 numberOfFunders = 10;
        uint160 startingFundersIndex = 1;

        for (uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            hoax(address(i), BALANCE);
            fundMe.fund{value: SENDING_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);
    }
}
