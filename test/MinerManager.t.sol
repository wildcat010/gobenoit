// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MinerManager.sol";
import "../src/GBNToken.sol";

import "forge-std/console.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";



contract MinerManagerTest is Test {
    MinerManager minerManager;
    GBNToken token;

    uint256 constant GBN_UNIT = 1e18;

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

        assertEq(minerManager.MINER_COST(), 100 * GBN_UNIT);
    }

    function testBuyTokens() public{
        address bob = address(0xB0B);

        // give Bob ETH
        vm.deal(bob, 1 ether);

        vm.prank(bob);
        minerManager.buyTokens{value: 0.1 ether}();

        uint256 balance = token.balanceOf(bob);
        assertEq(balance, 100 * GBN_UNIT);
    }

    function bobBuyMiner() public{
        address bob = address(0xB0B);
        vm.deal(bob, 1 ether);

        vm.startPrank(bob);
        minerManager.buyTokens{value: 0.1 ether}();

        minerManager.buyMiner();

        vm.stopPrank();

        // ✅ destructure tuple correctly
        (uint256 miners, uint256 rewardDebt, uint256 feeDebt) = minerManager.users(bob);

        assertEq(miners, 1);
        assertGt(rewardDebt, 0);
        assertGt(feeDebt, 0);
    }

    function testPendingRewardAfter3Days() public {
        
        address bob = address(0xB0B);
        vm.deal(bob, 1 ether);

        vm.startPrank(bob);

        minerManager.buyTokens{value: 0.1 ether}();
        token.approve(address(minerManager), 100 ether);

        console.log("balance 1",token.balanceOf(bob));

        minerManager.buyMiner();


        console.log("balance 2",token.balanceOf(bob));

        vm.stopPrank();

        uint256 initialTokenBalance = token.balanceOf(bob);
        uint256 initialPending = minerManager.pendingReward(bob);

        vm.warp(block.timestamp + 3 days);

        uint256 laterPending = minerManager.pendingReward(bob);
        
        console.log("initialPending", initialPending);
        console.log("laterPending", laterPending);

        assertGt(laterPending, initialPending);
    }

    function testPendingRewardAfter3DaysFor100Users() public {
        for( uint256 i = 0; i < 100; i++) {
            address user = address(uint160(i + 1));
            vm.deal(user, 1 ether);

            vm.startPrank(user);
            minerManager.buyTokens{value: 0.1 ether}();
            token.approve(address(minerManager), 100 ether);
            if(i % 2 == 0) {
                minerManager.buyMiner();
            }

            vm.stopPrank();
        }

        console.log("totalSupply",token.totalSupply());
        assertEq(token.totalSupply(), 5000 * GBN_UNIT);

        vm.warp(block.timestamp + 3 days);

        address user = address(uint160(1));
        vm.prank(user);
        uint256 laterPending = minerManager.pendingReward(user);
        console.log("laterPending",laterPending);
        assertEq(laterPending, 5970149253731343282);
    }

   
}