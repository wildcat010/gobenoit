// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MinerManager.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Upgrade is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // deploy new implementation
        MinerManager newImpl = new MinerManager();

        // upgrade proxy to new implementation
        MinerManager proxy = MinerManager(0x4fFa239F0b73937Fb290f70b52C7c7410E8C742F); // your existing proxy
        proxy.upgradeToAndCall(address(newImpl), "");

        vm.stopBroadcast();

        console.log("New MinerManager implementation:", address(newImpl));
        console.log("Proxy address unchanged:", address(proxy));
    }
}