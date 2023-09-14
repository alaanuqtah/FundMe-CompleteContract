//1. deploy mocks when we r on a local anvil chain
//2. keep trach of contract address across diff chains

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 2000e8;

    NetworkConfig public currentNetwork;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            currentNetwork = getSepEthConfig();
        } else if (block.chainid == 1) {
            currentNetwork = getEthMainConfig();
        } else {
            currentNetwork = get_create_AnvilEthConfig();
        }
    }

    function getSepEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sep4Eth = NetworkConfig(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return sep4Eth;
    }

    function getEthMainConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethMain = NetworkConfig(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        return ethMain;
    }

    //this is the only function in this script that has start and stop braodcast function because this deploys a fake contract
    function get_create_AnvilEthConfig() public returns (NetworkConfig memory) {
        if (currentNetwork.priceFeed != address(0)) {
            return currentNetwork;
        }

        vm.startBroadcast(); //real transactions happen between the start and stop, anywhere else it is a simulated tx
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig(
            address(mockPriceFeed)
        );
        return anvilConfig;
    }
}
