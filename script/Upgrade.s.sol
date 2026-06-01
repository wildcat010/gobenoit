// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/GBNToken.sol";
import "../src/Miner1155.sol";
import "../src/MinerManager.sol";

contract Upgrade is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);

        // -------------------------
        // 1. Upgrade GBNToken
        // -------------------------
        GBNToken tokenProxy =
            GBNToken(0x456a21C55f215d87dE89e6648BddcfaD32314b58);

        GBNToken newTokenImpl = new GBNToken();

        tokenProxy.upgradeToAndCall(address(newTokenImpl), "");

        // -------------------------
        // 2. Upgrade Miner1155
        // -------------------------
        Miner1155 minerProxy =
            Miner1155(0x30ab54117951876A5A5f86A1498b8890e5406F88);

        Miner1155 newMinerImpl = new Miner1155();

        minerProxy.upgradeToAndCall(address(newMinerImpl), "");

        // -------------------------
        // 3. Upgrade MinerManager
        // -------------------------
        MinerManager managerProxy =
            MinerManager(0x52491C74e7Df3aB94Fb2Db7D42BDe290040A9A74);

        MinerManager newManagerImpl = new MinerManager();

        managerProxy.upgradeToAndCall(address(newManagerImpl), "");

        vm.stopBroadcast();

        console.log("Upgrade complete");
    }
}