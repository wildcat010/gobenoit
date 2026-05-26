// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Miner1155.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";


contract Miner1155Test is Test {
    Miner1155 token;

    address miner = address(0xBEEF);
    address user = address(0xCAFE);

    function setUp() public {
        // deploy implementation
        Miner1155 impl = new Miner1155();

        // encode initializer call
        bytes memory data = abi.encodeWithSelector(
            Miner1155.initialize.selector,
            address(this)
        );

        // deploy proxy
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            data
        );

        // cast proxy to token interface
        token = Miner1155(address(proxy));

        token.setMinerContract(miner);
    }

    function testInitialization() public view {
         assertEq(token.owner(), address(this));

          assertEq(
            token.uri(1),
            "https://wildcat010.github.io/gobenoit/miners/{id}.json"
            );

            // max supply checks
            assertEq(token.maxSupply(1), 100); // BASIC
            assertEq(token.maxSupply(2), 50);  // PRO
            assertEq(token.maxSupply(3), 10);  // LEGEND

            // power checks
            assertEq(token.minerPower(1), 10);
            assertEq(token.minerPower(2), 20);
            assertEq(token.minerPower(3), 50);

            // initial minted state
            assertEq(token.totalMinted(1), 0);
            assertEq(token.totalMinted(2), 0);
            assertEq(token.totalMinted(3), 0);
    }

    function testMinerCanMint() public {
        vm.prank(miner);
        token.mintMiner(user,2/*PRO*/, 12);

        //check supply it should always be 50
        assertEq(token.maxSupply(2),50);

        // ✔ minted increases
        assertEq(token.totalMinted(2), 12);

        assertEq(token.maxSupply(2) - token.totalMinted(2), 38);
    }

    function testMinerCanMintAndBurn() public {
        vm.prank(miner);
        token.mintMiner(user,2/*PRO*/, 12);

        assertEq(token.maxSupply(2) - token.totalMinted(2), 38);

        vm.prank(miner);
        token.burnMiner(user, 2/*PRO*/, 5);
        assertEq(token.maxSupply(2) - token.totalMinted(2), 43);
    }

    function testMinerCanMintAndCalculPower() public {
        vm.prank(miner);
        token.mintMiner(user,2/*PRO*/, 12);

        assertEq(token.maxSupply(2) - token.totalMinted(2), 38);

        uint256 power = token.totalPower(user);
        assertEq(power, 240); // 12 PRO miners * 20 power each
    }

    function testMinerCanMintAndBurnCalculPower() public {
        vm.prank(miner);
        token.mintMiner(user,2/*PRO*/, 12);
        assertEq(token.maxSupply(2) - token.totalMinted(2), 38);

        vm.prank(miner);
        token.burnMiner(user, 2/*PRO*/, 5);
        assertEq(token.maxSupply(2) - token.totalMinted(2), 43);

        uint256 power = token.totalPower(user);
        assertEq(power, 140); // 7 PRO miners * 20 power each
    }
}