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
    address public minerManager;

    event MinerManagerUpdated(address indexed newManager);

    function initialize(address owner_) public initializer {
        __ERC20_init("GoBenoit", "GBN");
        __Ownable_init(owner_);
        __UUPSUpgradeable_init();
        __Pausable_init();
    }

    modifier onlyMinerManager() {
        require(msg.sender == minerManager, "Not MinerManager");
        _;
    }

    function setMinerManager(address _manager) external onlyOwner {
        require(_manager != address(0), "Invalid address");
        minerManager = _manager;
        emit MinerManagerUpdated(_manager);
    }

    function mint(address to, uint256 amount)
        external
        onlyMinerManager
        whenNotPaused
    {
        _mint(to, amount);
    }

    function burnFrom(address from, uint256 amount)
        external
        onlyMinerManager
        whenNotPaused
    {
        _burn(from, amount);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}