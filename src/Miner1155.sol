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

    address public minerManager;

    event MinerManagerUpdated(address indexed newManager);

    event TokensMinted(
        address indexed to,
        uint256 indexed id,
        uint256 amount
    );

    event TokensBurned(
        address indexed from,
        uint256 indexed id,
        uint256 amount
    );

    modifier onlyMinerManager() {
        require(msg.sender == minerManager, "Not miner manager");
        _;
    }

    error InvalidMinerType();

    function _isValidMiner(uint256 id) internal pure returns (bool) {
        return id >= BASIC && id <= LEGEND;
    }

    function setMinerManager(address _manager) external onlyOwner {
        require(_manager != address(0), "Invalid address");
        minerManager = _manager;

        emit MinerManagerUpdated(_manager);
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
    ) external onlyMinerManager whenNotPaused  {

        if (!_isValidMiner(id)) {
            revert InvalidMinerType();
        }

        require(
            totalMinted[id] + amount <= maxSupply[id],
            "Max supply reached"
        );

        totalMinted[id] += amount;

        _mint(to, id, amount, "");
        emit TokensMinted(to, id, amount);
    }

    // =========================
    //  Burn miners (upgrade / mechanic)
    // =========================
    function burnMiner(
        address from,
        uint256 id,
        uint256 amount
    ) external onlyMinerManager whenNotPaused {

        if (!_isValidMiner(id)) {
            revert InvalidMinerType();
        }

        totalMinted[id] -= amount;

        _burn(from, id, amount);

        emit TokensBurned(from, id, amount);
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