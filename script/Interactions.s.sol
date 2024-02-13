//SPDX-License-Identifier: SPDX

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {

    function run() external {
        vm.startBroadcast();
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {

}