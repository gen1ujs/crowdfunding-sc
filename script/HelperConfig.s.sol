// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

//HelperConfig.sol allows us to test our script in many different chains such as sepolia,mainnet or even local

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed;
    }

    uint8 public constant DECIMALS = 8;
    int256 public constant ETH_PRICE = 2000e8;

    NetworkConfig public currentNetwork;

    constructor() {
        if (block.chainid == 11155111) {
            currentNetwork = getSepolia();
        } else if (block.chainid == 1) {
            currentNetwork = getMainnet();
        } else {
            currentNetwork = getOrCreateAnvil();
        }
    }

    function getSepolia() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnet() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvil() public returns (NetworkConfig memory) {
        if (currentNetwork.priceFeed != address(0)) {
            return currentNetwork;
        }
        //Deploy mock contracts
        //Get datas inside it
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            ETH_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
