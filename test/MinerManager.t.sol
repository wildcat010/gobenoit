// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MinerManager.sol";
import "../src/GBNToken.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";


contract MinerManagerTest is Test {
    MinerManager minerManager;
    GBNToken token;

    address user = address(0xCAFE);

    

    function setUp() public {
        //deploy token
        token = new GBNToken();
        token.initialize();

        // ⛏ Deploy miner manager
        minerManager = new MinerManager();

        // encode initializer call
        bytes memory initData = abi.encodeWithSelector(
            MinerManager.initialize.selector,
            address(token)
        );

        // deploy proxy pointing to implementation
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(minerManager),
            initData
        );

        // interact through proxy
        minerManager = MinerManager(address(proxy));

        // 🔗 Link contracts
        token.setMinerContract(address(minerManager));
    }

    function testInitialization() public view {
        assertEq(token.name(), "GoBenoit");
        assertEq(token.symbol(), "GBN");

        assertEq(minerManager.MINER_COST(), 100 ether);
    }

    function testBuyTokens() public{
        address bob = address(0xB0B);

        // give Bob ETH
        vm.deal(bob, 1 ether);

        vm.prank(bob);
        minerManager.buyTokens{value: 0.1 ether}();

        uint256 balance = token.balanceOf(bob);
        assertEq(balance, 100 ether);
    }

    function bobBuyMiner() public{
        address bob = address(0xB0B);
        vm.deal(bob, 1 ether);

        vm.startPrank(bob);
        minerManager.buyTokens{value: 0.1 ether}();

        minerManager.buyMiner();

        vm.stopPrank();

        // ✅ destructure tuple correctly
        (uint256 miners, uint256 lastClaim) = minerManager.users(bob);

        assertEq(miners, 1);
        assertGt(lastClaim, 0);
    }

    function getFeePerDayTest() public{
        address bob = address(0xB0B);
        vm.deal(bob, 1 ether);

        vm.prank(bob);
        minerManager.buyTokens{value: 0.1 ether}();

        uint256 balance = token.balanceOf(bob);
        assertEq(balance, 100 ether);

        vm.prank(bob);
        uint256 fee = minerManager.getFeePerDay();

        assertEq(fee, 1 ether);
    }
}