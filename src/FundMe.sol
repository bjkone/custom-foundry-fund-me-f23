// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Converter} from "./Converter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
//import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";
//import {AggregatorV2V3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV2V3Interface.sol";

contract FundMe {
    uint256 public constant MINIMUM_FUND = 51e8; //51$ is 51000000000000000000 wei
    address[] private s_ownerList;
    mapping(address => uint256) private s_addressToAmountFunded;

    address private immutable i_owner;
    AggregatorV3Interface public s_priceFeed;

    constructor(address _priceFeed) {
        i_owner = msg.sender;
        //priceFeed = new MockV3Aggregator(8, 242000000000);
        s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    error FundMe_NotOwner();

    //gas :568527
    //566113
    //566113
    function fund() public payable {
        require(
            Converter.converterEthToUsd(s_priceFeed, msg.value) > MINIMUM_FUND,
            "Please send more than minimum of ETH"
        );
        s_ownerList.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint index; index < s_ownerList.length; index++) {
            s_addressToAmountFunded[s_ownerList[index]] = 0;
        }
        s_ownerList = new address[](0);
        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
        require(sent, "Failed to send ether");
    }

    modifier onlyOwner() {
        //require(msg.sender == owner, "Your are not the owner of his contract");
        if (msg.sender != i_owner) {
            revert FundMe_NotOwner();
        }
        _;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getAmountFunded(address _address) external view returns (uint256) {
        return s_addressToAmountFunded[_address];
    }

    function getOwnerList() external view returns (address[] memory) {
        return s_ownerList;
    }
}
