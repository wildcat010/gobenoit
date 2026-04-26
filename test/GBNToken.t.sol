// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GBNToken.sol";

contract GBNTokenTest is Test {
    GBNToken token;

    address miner = address(0xBEEF);
    address user = address(0xCAFE);

    function setUp() public {
        token = new GBNToken();
        token.initialize();

        token.setMinerContract(miner);
    }

    function testInitialization() public view {
        assertEq(token.name(), "GoBenoit");
        assertEq(token.symbol(), "GBN");
    }

    function testMinerCanMint() public {
        vm.prank(miner);
        token.mint(user, 1000);

        assertEq(token.balanceOf(user), 1000);
    }

    function testNonMinerCannotMint() public {
        vm.prank(user);

        vm.expectRevert("Not authorized");
        token.mint(user, 1000);
    }
}