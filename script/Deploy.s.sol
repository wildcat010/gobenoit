// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

import "../src/GBNToken.sol";
import "../src/MinerManager.sol";
import "../src/Miner1155.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy token (implementation)
        GBNToken tokenImpl = new GBNToken();
        ERC1967Proxy tokenProxy = new ERC1967Proxy(
            address(tokenImpl),
            abi.encodeWithSelector(GBNToken.initialize.selector)
        );
        GBNToken token = GBNToken(address(tokenProxy));

    //deploy miner erc 1155
        Miner1155 miner1155Impl = new Miner1155();
        ERC1967Proxy miner1155Proxy = new ERC1967Proxy(
            address(miner1155Impl),
            abi.encodeWithSelector(Miner1155.initialize.selector)
        );
        Miner1155 miner1155 = Miner1155(address(miner1155Proxy));

      //Deploy miner implementation
        MinerManager minerImpl = new MinerManager();

       //Deploy miner proxy
        bytes memory minerInitData = abi.encodeWithSelector(
            MinerManager.initialize.selector,
            address(token),
            address(miner1155)
        );

        ERC1967Proxy minerProxy = new ERC1967Proxy(
            address(minerImpl),
            minerInitData
        );

        MinerManager miner = MinerManager(address(minerProxy));

        //  Link contracts
        token.setMinerManager(address(miner));
        miner1155.setMinerManager(address(miner));

        vm.stopBroadcast();

        //  Logs
        console.log("GBNToken Proxy:", address(token));
        console.log("Miner1155 Proxy:", address(miner1155));
        console.log("MinerManager Proxy:", address(miner));
    }
}