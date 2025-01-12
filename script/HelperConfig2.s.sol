//SPDX-License-Ideitifier:MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig2 is Script {
    int256 private constant PRICE = 3000e8;
    uint8 private constant DECIMAL = 8;

    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfiguration();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaConfiguration() public view returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConf = NetworkConfig({priceFeed: 0x677cD0Acfb977399275d804eF7FEccE817a18632});
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mock = new MockV3Aggregator(DECIMAL, PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvil = NetworkConfig({priceFeed: address(mock)});
        return anvil;
    }
}
