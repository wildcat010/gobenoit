// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GBNToken.sol";

contract GBNTokenTest is Test {
    GBNToken token;

    address manager = address(0x123);

    function setUp() public {
        token = new GBNToken();
        token.initialize(address(this));

        token.setMinerManager(manager);
    }

    function testMintBurnFlow() public {
        vm.prank(manager);
        token.mint(address(this), 100 ether);

        assertEq(token.balanceOf(address(this)), 100 ether);

        vm.prank(manager);
        token.burnFrom(address(this), 40 ether);

        assertEq(token.balanceOf(address(this)), 60 ether);
    }
}