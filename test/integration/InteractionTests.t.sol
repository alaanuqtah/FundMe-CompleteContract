// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundInteractions, WithdrawInteractions} from "../../script/Interactions.s.sol";

contract InteractionTest is Test {
    FundMe f_contract;

    address user = makeAddr("user"); //cheatcode
    uint256 constant SENT_AMOUNT = 6e18;
    uint256 constant STARTING_BALANCE = 10 ether;

    // uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        f_contract = deployFundMe.run();
        vm.deal(user, STARTING_BALANCE); //cheatcode
    }

    function testUserCanFundInteractions() public {
        FundInteractions fundMeIneraction = new FundInteractions();
        fundMeIneraction.fundFundMe(address(f_contract));

        WithdrawInteractions widthdrawIneraction = new WithdrawInteractions();
        widthdrawIneraction.withdrawFundMe(address(f_contract));

        assert(address(f_contract).balance == 0);
    }
}
