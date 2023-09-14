// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe f_contract;

    uint256 constant SENT_AMOUNT = 6e18;
    uint256 constant STARTING_BALANCE = 10 ether;
    // uint256 constant GAS_PRICE = 1;

    address user = makeAddr("user"); //cheatcode

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        f_contract = deployFundMe.run();
        vm.deal(user, STARTING_BALANCE); //cheatcode
    }

    function testMinUSD() public {
        assertEq(f_contract.MIN_USD(), 5e18);
    }

    function testOwner() public {
        console.log(f_contract.getOwner());
        console.log(address(this));

        console.log(msg.sender);
        // assertEq(f_contract.i_owner(), address(this)); simply this.address which is the test contract address doesnt directly deploy the fund me contract anymore, the Deployment of the contrat was done in the scripts, the run function was called by the msg.sender which is me,
        assertEq(f_contract.getOwner(), msg.sender);
    }

    function testPriceV() public {
        uint version = f_contract.getVersion();
        assertEq(version, 4);
    }

    function testFundNotEnoughEth() public {
        vm.expectRevert(); //cheatcode - hi! the next line should fail
        f_contract.fund();
    }

    function testFundUpdatesData() public fundedByOneUser {
        uint256 amountFunded = f_contract.getAddressToFunds(user);
        assertEq(amountFunded, SENT_AMOUNT);
    }

    function testAddsFunderToArrayOfFunders() public fundedByOneUser {
        address funder = f_contract.getFunder(0);
        assertEq(user, funder);
    }

    function testOnlyOwnerCanWithdraw()
        public
        fundedByOneUser //just to make sure there is an amount to withdraw
    {
        console.log(f_contract.getOwner().balance);
        console.log(address(f_contract).balance);
        vm.expectRevert();
        vm.prank(user); //expecting this to revert because the person trying to withdraw isnt the owner but the prank user
        f_contract.withdraw();
        console.log(f_contract.getOwner().balance);
        console.log(address(f_contract).balance);
    }

    function testWithdrawASingleFunder() public fundedByOneUser {
        //Arrange
        uint256 startingOwnerBalance = f_contract.getOwner().balance;
        uint256 startingFundMeBalance = address(f_contract).balance;
        //console.log(startingOwnerBalance);
        //console.log(startingFundMeBalance);
        //Act
        vm.prank(f_contract.getOwner());
        f_contract.withdraw();

        //Assert
        uint256 endingOwnerBalance = f_contract.getOwner().balance;
        uint256 endingFundMeBalance = address(f_contract).balance;
        // console.log(startingFundMeBalance + startingOwnerBalance);
        // console.log(6000000000000000000 + 79228162514264337593543950335);

        // console.log(endingFundMeBalance);
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromfFunders() public fundedByTenUsers {
        uint256 startingOwnerBalance = f_contract.getOwner().balance;
        uint256 startingFundMeBalance = address(f_contract).balance;

        //act
        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE); //cheat code to set gas price
        vm.startPrank(f_contract.getOwner());
        f_contract.withdraw();
        vm.stopPrank();
        //uint256 gasEnd = gasleft();
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //console.log(gasUsed);
        //assert
        assertEq(address(f_contract).balance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            f_contract.getOwner().balance
        );
    }

    modifier fundedByOneUser() {
        vm.prank(user); //cheatcode
        f_contract.fund{value: SENT_AMOUNT}();
        _;
    }

    modifier fundedByTenUsers() {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SENT_AMOUNT); //cheat code for prank and deal
            f_contract.fund{value: SENT_AMOUNT}(); //stuffing the contract with funds
        }

        _;
    }
}

//types of test: 1- uint, 2- integrated, 3- forked, 4- staging
