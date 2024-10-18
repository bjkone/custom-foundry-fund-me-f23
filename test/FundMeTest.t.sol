// SPDX-License-Indentier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    uint256 internal expected = 1;
    FundMe internal fundMe;
    address USER = makeAddr("user");
    address USER2 = makeAddr("user2");
    uint256 private constant SEND_VALUE = 0.1 ether;
    uint256 private constant STARTING_BALANCE = 10 ether;

    function setUp() public {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
        vm.deal(fundMe.getOwner(), STARTING_BALANCE);
    }

    function test_minimum_value() public view {
        console.log("hello!");
        assertEq(expected, 1);
        assertEq(fundMe.MINIMUM_FUND(), 51e8);
    }

    function test_owner() public view {
        console.log(address(this));
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function test_version() public view {
        console.log(fundMe.getVersion());
        assertEq(fundMe.getVersion(), 0x4);
    }

    function testFunFailWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFunSuccessWithEnoughEth() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getAmountFunded(USER), SEND_VALUE);
    }

    function testAddFounderToArrayOfFounders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address[] memory funder = fundMe.getOwnerList();
        assertEq(funder[0], USER);
    }

    function testGetAmountFunded() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getAmountFunded(USER), SEND_VALUE);
    }

    modifier founder() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public founder {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }
    function testWithDrawWithASingleFunder() public founder {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = fundMe.getBalance();

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = fundMe.getBalance();
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithDrawWithMultipleFounders() public founder {
        //Arrange
        for (uint256 i = 0; i < 10; i++) {
            hoax(address(uint160(i)), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = fundMe.getBalance();

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = fundMe.getBalance();
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }
}
