// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
//import {AggregatorV2V3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV2V3Interface.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library Converter {
    //ethAmout must be in wei example : 0,022eth => 22000000000000000 wei
    function converterEthToUsd(
        AggregatorV3Interface aggregator,
        uint256 ethAmount
    ) public view returns (uint256) {
        // the type of valeur in return is wei
        uint256 ethUsd = (getPrice(aggregator) * ethAmount) / 1e18;
        return ethUsd;
    }

    //priceDollar in wei => 50$ => 50000000000000000000 wei, you must set value in wei
    function converterUsdToEth(
        AggregatorV3Interface aggregator,
        uint _priceInDollar
    ) public view returns (uint256) {
        uint ethAmount = (_priceInDollar * 1e18) / getPrice(aggregator);
        return ethAmount;
    }

    function getPrice(
        AggregatorV3Interface aggregator
    ) public view returns (uint256) {
        (
            ,
            /* uint80 roundID */ int price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = aggregator.latestRoundData();
        return uint256(price);
    }

    /*function buildMockV3Aggregator() internal returns (MockV3Aggregator) {
        //AggregatorV3Interface internal dataFeed;
        return new MockV3Aggregator(8, 242000000000);
    }*/
}
