// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {

    FundMe fundMe;
    address USER = makeAddr("user"); //create an address to use instead of address(this)
    
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); 
        vm.deal(USER, 10 ether); // fund the address to be able to send eth to FundMe
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18); 
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert(); // the next line should revert
        fundMe.fund{value: 1e5}(); //send low value 
    }




    function testFundUpdatesFundedDataStructure() public funded {

        assertEq(fundMe.getAddressToAmountFunded(USER), 10e18);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        assertEq(fundMe.getFunder(0), USER);
    }

    modifier funded() {
        vm.prank(USER); // the next TX will be sent by USER
        fundMe.fund{value: 10e18}(); //send 10 eth
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {

        vm.prank(USER); //expectRevert ignores this
        vm.expectRevert(); // the next line should revert
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
        assertEq(endingFundMeBalance, 0);
    }

    // we'll use uint160, cause since solidity 0.8 we cannot cast a uint256 to an address, but uint160 has the same nr of 
    // bytes as an address so its castable
    function testWithdrawWithMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // we start with 1 to avoid using the 0 address - address(0)

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // we use address(i), because we can use contracts like address(4) just like we use address(0)
            hoax(address(i), 10e18); // hoax creates an address like prank and funds it with a sum
            fundMe.fund{value: 10e18}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner()); // different syntax than before, you make sure address is used in the boundries only
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
        assertEq(endingFundMeBalance, 0);
    }
}