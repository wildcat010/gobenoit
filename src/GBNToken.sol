// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

contract GBNToken is 
    Initializable, 
    ERC20Upgradeable, 
    OwnableUpgradeable, 
    UUPSUpgradeable,
    PausableUpgradeable
{
    address public minerContract;

    function initialize() public initializer {
        __ERC20_init("GoBenoit", "GBN");
        __Ownable_init(msg.sender);
        __Pausable_init();
    }

    function setMinerContract(address _miner) external onlyOwner {
        require(_miner != address(0), "Invalid address");
        minerContract = _miner;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) external whenNotPaused {
        require(msg.sender == minerContract, "Not authorized");
        _mint(to, amount);
    }

    function burnFrom(address from, uint256 amount) external whenNotPaused {
        require(msg.sender == minerContract, "Not authorized");
        _burn(from, amount);
    }

    function _update(address from, address to, uint256 amount)
        internal
        override
        whenNotPaused
    {
        super._update(from, to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}