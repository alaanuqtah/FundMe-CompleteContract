//simulate interactions with the contract functions
//1- fund
//2- withdraw

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundInteractions is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecDeployed) public {
        vm.startBroadcast();

        FundMe(payable(mostRecDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecDeployed);
    }
}

contract WithdrawInteractions is Script {
    function withdrawFundMe(address mostRecDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        withdrawFundMe(mostRecDeployed);
    }
}
