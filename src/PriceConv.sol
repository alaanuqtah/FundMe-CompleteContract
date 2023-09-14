// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.4/interfaces/AggregatorV3Interface.sol";

library PriceConv {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) public view returns (uint) {
        //addres: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        //abi

        (, int price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 1e10); //eth in terms of usd
    }

    function getConvRate(
        uint256 _ethAmount,
        AggregatorV3Interface priceFeed
    ) public view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * _ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion() public view returns (uint256) {
        return
            AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
                .version();
    }
}
