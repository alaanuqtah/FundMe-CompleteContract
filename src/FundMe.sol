// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {PriceConv} from "./PriceConv.sol";
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.4/interfaces/AggregatorV3Interface.sol";

error fundme__NotOwner();
error CallFailed();
error InsufficientFunds();

contract FundMe {
    using PriceConv for uint256;

    uint256 public constant MIN_USD = 5e18;
    address private immutable i_owner;

    address[] private s_funders;
    mapping(address => uint256) private s_addressToFunds;
    AggregatorV3Interface private s_priceFeed; //making an instace from the imported interface

    constructor(address priceFeed) {
        //passing the network priceFeed address
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed); //intializing the AggregatedInterface with the passedd address argument
    }

    function fund() public payable {
        if (msg.value.getConvRate(s_priceFeed) < MIN_USD) {
            revert InsufficientFunds();
        }
        s_funders.push(msg.sender);
        s_addressToFunds[msg.sender] += msg.value;
    }

    function withdraw() public OwnerAccess {
        //transer || send || call
        uint256 len = s_funders.length;

        for (uint i = 0; i < len; i++) {
            s_addressToFunds[s_funders[i]] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!callSuccess) {
            revert CallFailed();
        }
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    modifier OwnerAccess() {
        if (msg.sender != i_owner) {
            revert fundme__NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * view / pur functions
     *
     */

    function getAddressToFunds(address funder) external view returns (uint256) {
        return s_addressToFunds[funder];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
