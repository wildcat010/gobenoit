// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";

contract Miner1155 is
    Initializable,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable
{

    // =========================
    //  Miner IDs
    // =========================
    uint256 public constant BASIC = 1;
    uint256 public constant PRO = 2;
    uint256 public constant LEGEND = 3;

    // =========================
    // Supply tracking
    // =========================
    mapping(uint256 => uint256) public maxSupply;
    mapping(uint256 => uint256) public totalMinted;

    // =========================
    //  Power system
    // =========================
    mapping(uint256 => uint256) public minerPower;

    address public minerContract;


    modifier onlyMinerContract() {
        require(msg.sender == minerContract, "Not miner contract");
    _;
}

    function setMinerContract(address _miner) external onlyOwner {
        require(_miner != address(0), "Invalid address");
        minerContract = _miner;
    }

    // =========================
    //  initializer (NO constructor)
    // =========================
    function initialize(address owner_) public initializer {
        __ERC1155_init("https://wildcat010.github.io/gobenoit/miners/{id}.json");
        __Ownable_init(owner_);

        // max supply
        maxSupply[BASIC] = 100;
        maxSupply[PRO] = 50;
        maxSupply[LEGEND] = 10;

        // power values
        minerPower[BASIC] = 10;
        minerPower[PRO] = 20;
        minerPower[LEGEND] = 50;
    }

    // =========================
    //  Pause control
    // =========================

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // =========================
    //  Mint miners (game / manager only)
    // =========================
    function mintMiner(
        address to,
        uint256 id,
        uint256 amount
    ) external onlyMinerContract whenNotPaused  {

        require(id >= 1 && id <= 3, "Invalid miner type");

        require(
            totalMinted[id] + amount <= maxSupply[id],
            "Max supply reached"
        );

        totalMinted[id] += amount;

        _mint(to, id, amount, "");
    }

    // =========================
    //  Burn miners (upgrade / mechanic)
    // =========================
    function burnMiner(
        address from,
        uint256 id,
        uint256 amount
    ) external onlyMinerContract whenNotPaused {

        require(totalMinted[id] >= amount, "Invalid burn");

        totalMinted[id] -= amount;

        _burn(from, id, amount);
    }

    // =========================
    //  Compute user power
    // =========================
    function totalPower(address user)
        external
        view
        returns (uint256 power)
    {
        power =
            balanceOf(user, BASIC) * minerPower[BASIC] +
            balanceOf(user, PRO) * minerPower[PRO] +
            balanceOf(user, LEGEND) * minerPower[LEGEND];
    }

    // =========================
    //  UUPS upgrade auth
    // =========================
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}