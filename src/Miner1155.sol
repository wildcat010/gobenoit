// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

contract Miner1155 is
    Initializable,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable
{
    uint256 public constant BASIC = 1;
    uint256 public constant PRO = 2;
    uint256 public constant LEGEND = 3;

    mapping(uint256 => uint256) public maxSupply;
    mapping(uint256 => uint256) public totalMinted;
    mapping(uint256 => uint256) public minerPower;

    address public minerManager;

    error NotMinerManager();

    modifier onlyMinerManager() {
        if (msg.sender != minerManager) revert NotMinerManager();
        _;
    }

    function initialize(address owner_) public initializer {
        __ERC1155_init("https://wildcat010.github.io/gobenoit/miners/{id}.json");
        __Ownable_init(owner_);
        __UUPSUpgradeable_init();
        __Pausable_init();
        maxSupply[BASIC] = 100;
        maxSupply[PRO] = 50;
        maxSupply[LEGEND] = 10;

        minerPower[BASIC] = 10;
        minerPower[PRO] = 20;
        minerPower[LEGEND] = 50;
    }

    function setMinerManager(address _manager) external onlyOwner {
        require(_manager != address(0), "Invalid manager");
        minerManager = _manager;
    }

    function mintMiner(address to, uint256 id, uint256 amount)
        external
        onlyMinerManager
        whenNotPaused
    {
        require(totalMinted[id] + amount <= maxSupply[id], "Max supply");

        totalMinted[id] += amount;
        _mint(to, id, amount, "");
    }

    function burnMiner(address from, uint256 id, uint256 amount)
        external
        onlyMinerManager
        whenNotPaused
    {
        totalMinted[id] -= amount;
        _burn(from, id, amount);
    }

    function totalPower(address user) external view returns (uint256 power) {
        return
            balanceOf(user, BASIC) * minerPower[BASIC] +
            balanceOf(user, PRO) * minerPower[PRO] +
            balanceOf(user, LEGEND) * minerPower[LEGEND];
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}