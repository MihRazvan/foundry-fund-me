//SPDX-License-Identifier: SPDX

//1. DEPLOY MOCKS WHEN WE ARE ON A LOCAL ANVIL CHAIN (I would use Ganache instead)
//2. KEEP TRACK OF CONTRACT ADDRESSES ON DIFFERENT CHAINS (ex: Sepolia ETH/USD, Mainnet ETH/USD)
// basically we want to skip hard coding addresses in our deploy contract and work with local chains as well as live network

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

// "is Script" because when we need it for vm.broadcast to deploy mock contracts
contract HelperConfig is Script {
    // If we are on a local chain we deploy mocks (remember how we were unable to test on anvil because we couldn't make calls)
    // Else, grab the existing addresses from the live network

    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor () {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        // verify if we already deployed pricefeed
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        // 1. deploy the mocks
        // 2. return the mock address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});

        return anvilConfig;
    }
}