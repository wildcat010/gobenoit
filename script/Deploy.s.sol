// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

import "../src/GBNToken.sol";
import "../src/MinerManager.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy token (implementation)
        GBNToken tokenImpl = new GBNToken();

        // 2. Deploy token proxy
        bytes memory tokenInitData = abi.encodeWithSelector(
            GBNToken.initialize.selector
        );

        ERC1967Proxy tokenProxy = new ERC1967Proxy(
            address(tokenImpl),
            tokenInitData
        );

        GBNToken token = GBNToken(address(tokenProxy));

        // 3. Deploy miner implementation
        MinerManager minerImpl = new MinerManager();

        // 4. Deploy miner proxy
        bytes memory minerInitData = abi.encodeWithSelector(
            MinerManager.initialize.selector,
            address(token)
        );

        ERC1967Proxy minerProxy = new ERC1967Proxy(
            address(minerImpl),
            minerInitData
        );

        MinerManager miner = MinerManager(address(minerProxy));

        // 5. Link contracts
        token.setMinerContract(address(miner));

        vm.stopBroadcast();

        // 6. Logs (VERY useful)
        console.log("GBNToken Proxy:", address(token));
        console.log("MinerManager Proxy:", address(miner));
    }
}