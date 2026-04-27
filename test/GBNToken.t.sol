// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GBNToken.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";


contract GBNTokenTest is Test {
    GBNToken token;

    address miner = address(0xBEEF);
    address user = address(0xCAFE);

    function setUp() public {
        // deploy implementation
        GBNToken impl = new GBNToken();

        // encode initializer call
        bytes memory data = abi.encodeWithSelector(
            GBNToken.initialize.selector
        );

        // deploy proxy
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            data
        );

        // cast proxy to token interface
        token = GBNToken(address(proxy));

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

    function testBurnTokens() public {
        vm.prank(miner);
        token.mint(user, 1000);

        vm.prank(miner);
        token.burnFrom(user, 500);

        assertEq(token.balanceOf(user), 500);
    }

    function testMinerCanMintWhenPaused() public {
        token.pause();

        vm.prank(miner);
        vm.expectRevert();
        token.mint(user, 1000);

    }

    function testMinerCanBurnWhenPaused() public {
        vm.prank(miner);
        token.mint(user, 1000);

        token.pause();

        vm.prank(miner);
        vm.expectRevert();
        token.burnFrom(user, 500);

    }

    function testMintBurnFlow() public {
    vm.prank(miner);
    token.mint(user, 1000);

    vm.prank(miner);
    token.burnFrom(user, 200);

    vm.prank(miner);
    token.mint(user, 500);

    assertEq(token.balanceOf(user), 1300);
}
}