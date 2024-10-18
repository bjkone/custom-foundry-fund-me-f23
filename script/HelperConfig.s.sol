// SPDX-License-Indentifier: MIT

pragma solidity ^0.8.24;

import {CustomMockV3Aggregator} from "./mock/CustomMockV3Aggregator.sol";
import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    NetworkConfig public networkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2420e8;

    struct NetworkConfig {
        address priceFeedAddress;
    }

    constructor() {
        if (block.chainid == 11155111) {
            networkConfig = getSepoliaEthConfig();
        } else {
            if (networkConfig.priceFeedAddress == address(0)) {
                networkConfig = createAnvilEthConfig();
            }
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function createAnvilEthConfig() public returns (NetworkConfig memory) {
        vm.startBroadcast();
        CustomMockV3Aggregator priceFeedMock = new CustomMockV3Aggregator(
            DECIMALS,
            INITIAL_ANSWER
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilEthConfig = NetworkConfig({
            priceFeedAddress: address(priceFeedMock)
        });
        return anvilEthConfig;
    }
}
