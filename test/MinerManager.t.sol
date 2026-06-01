// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MinerManager.sol";
import "../src/GBNToken.sol";
import "../src/Miner1155.sol";

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract MinerManagerTest is Test {
    MinerManager minerManager;
    GBNToken token;
    Miner1155 miner1155;

    uint256 constant GBN_UNIT = 1e18;

    address user = address(0xCAFE);

    function setUp() public {
        // deploy implementations
        token = new GBNToken();
        miner1155 = new Miner1155();

        // initialize IMPLEMENTATIONS directly (important for your setup)
        token.initialize(address(this));
        miner1155.initialize(address(this));

        // deploy MinerManager implementation
        MinerManager impl = new MinerManager();

        bytes memory data = abi.encodeWithSelector(
            MinerManager.initialize.selector,
            address(token),
            address(miner1155)
        );

        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), data);

        minerManager = MinerManager(address(proxy));

        // wire permissions
        token.setMinerManager(address(minerManager));
        miner1155.setMinerManager(address(minerManager));
    }

    function testInitialization() public {
        assertEq(token.name(), "GoBenoit");
        assertEq(token.symbol(), "GBN");

        assertEq(minerManager.minerCost(1), 100 ether);

        assertEq(address(token.minerManager()), address(minerManager));
        assertEq(address(miner1155.minerManager()), address(minerManager));

        assertEq(minerManager.rate(), 1000);
        assertEq(minerManager.treasury(), address(this));
        assertEq(minerManager.rewardIndex(), 0);
    }

    function testBuyTokens() public {
        address bob = address(0xB0B);

        vm.deal(bob, 1 ether);

        vm.prank(bob);
        minerManager.buyTokens{value: 0.1 ether}();

        assertEq(token.balanceOf(bob), 100 * GBN_UNIT);
    }

    function testBobBuyBasicMiner() public {
        address bob = address(0xB0B);
        vm.deal(bob, 1 ether);

        vm.startPrank(bob);

        minerManager.buyTokens{value: 0.2 ether}();
        minerManager.buyMiner(1, 2);

        vm.stopPrank();

        (uint256 minersPower,,) = minerManager.users(bob);

        assertEq(minersPower, 20);
    }

    function testBobBuy3MinersType() public {
        address bob = address(0xB0B);
        vm.deal(bob, 200 ether);

        vm.startPrank(bob);

        minerManager.buyTokens{value: 100 ether}();
        minerManager.buyMiner(1, 2);
        minerManager.buyMiner(2, 1);
        minerManager.buyMiner(3, 1);

        vm.stopPrank();

        (uint256 minersPower,,) = minerManager.users(bob);

        assertEq(minersPower, 90);
    }
}