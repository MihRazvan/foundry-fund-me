//SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {

    function run() external returns (FundMe) {
        // Before broadcast = not a real TX
        HelperConfig helperConfing = new HelperConfig();
        address ethUsdPriceFeed = helperConfing.activeNetworkConfig();

        // After broadcast = real TX
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}