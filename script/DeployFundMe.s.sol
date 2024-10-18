// SPDX-License-Indentier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address currentAddress = helperConfig.networkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(currentAddress);
        vm.stopBroadcast();
        return fundMe;
    }
}
