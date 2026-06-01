// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import "./GBNToken.sol";
import "./Miner1155.sol";

contract MinerManager is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    GBNToken public token;
    Miner1155 public miner1155;

    mapping(uint256 => uint256) public minerCost;

    uint256 public rate;

    uint256 public rewardIndex;
    uint256 public feeIndex;
    uint256 public lastUpdate;

    address public treasury;

    struct User {
        uint256 minersPower;
        uint256 rewardDebt;
        uint256 feeDebt;
    }

    mapping(address => User) public users;

    modifier userPurchasedOneMinerAtLeast() {
        require(users[msg.sender].minersPower > 0, "Buy a miner first");
        _;
    }

    event MinerPurchased(address indexed user, uint256 minerType, uint256 quantity);
    event RewardClaimed(address indexed user, uint256 rewardAmount, uint256 feeAmount);

    constructor() {
        _disableInitializers();
    }

    function initialize(address _token, address _miner1155) public initializer {
        __Ownable_init(msg.sender);
        __Pausable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        token = GBNToken(_token);
        miner1155 = Miner1155(_miner1155);

        rate = 1000;

        minerCost[1] = 100 ether;
        minerCost[2] = 250 ether;
        minerCost[3] = 1000 ether;

        lastUpdate = block.timestamp;
        treasury = msg.sender;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    // ✅ THIS WAS MISSING IN YOUR FILE
    function buyTokens() external payable whenNotPaused nonReentrant {
        require(msg.value > 0, "Send ETH");

        uint256 amount = msg.value * rate;
        token.mint(msg.sender, amount);
    }

    function pendingReward(address userAddr) public view returns (uint256) {
        User memory user = users[userAddr];

        uint256 supply = token.totalSupply() / 1000 ether;
        uint256 rewardPerDay = (2 ether * 1000) / (1000 + supply);

        uint256 elapsed = block.timestamp - lastUpdate;
        uint256 currentIndex = rewardIndex + (rewardPerDay * elapsed) / 1 days;

        uint256 accumulated = user.minersPower * currentIndex;

        return accumulated - user.rewardDebt;
    }

    function _updateIndex() internal {
        uint256 timePassed = block.timestamp - lastUpdate;
        if (timePassed == 0) return;

        uint256 supply = token.totalSupply() / 1000 ether;

        uint256 baseReward = 2 ether;
        uint256 baseFee = 1 ether;

        uint256 rewardPerDay = (baseReward * 1000) / (1000 + supply);
        uint256 feePerDay = baseFee + (supply * 1 ether / 10);

        rewardIndex += (rewardPerDay * timePassed) / 1 days;
        feeIndex += (feePerDay * timePassed) / 1 days;

        lastUpdate = block.timestamp;
    }

    function buyMiner(uint256 minerId, uint256 quantity)
        external
        whenNotPaused
        nonReentrant
    {
        require(quantity > 0, "Quantity must be greater than 0");
        require(minerId >= 1 && minerId <= 3, "Invalid miner");

        uint256 totalCost = minerCost[minerId] * quantity;

        require(
            token.balanceOf(msg.sender) >= totalCost,
            "Insufficient GBN balance"
        );

        _updateIndex();
        _claim(msg.sender);

        token.burnFrom(msg.sender, totalCost);

        miner1155.mintMiner(msg.sender, minerId, quantity);

        User storage user = users[msg.sender];

        user.minersPower += miner1155.minerPower(minerId) * quantity;

        user.rewardDebt = user.minersPower * rewardIndex;
        user.feeDebt = user.minersPower * feeIndex;

        emit MinerPurchased(msg.sender, minerId, quantity);
    }

    function claim()
        external
        whenNotPaused
        userPurchasedOneMinerAtLeast
        nonReentrant
    {
        _updateIndex();
        _claim(msg.sender);
    }

    function _claim(address userAddr) internal {
        User storage user = users[userAddr];

        if (user.minersPower == 0) return;

        uint256 accumulatedReward = user.minersPower * rewardIndex;
        uint256 accumulatedFee = user.minersPower * feeIndex;

        uint256 pendingRewardAmount = accumulatedReward - user.rewardDebt;
        uint256 pendingFee = accumulatedFee - user.feeDebt;

        user.rewardDebt = accumulatedReward;
        user.feeDebt = accumulatedFee;

        if (pendingRewardAmount > 0) {
            token.mint(userAddr, pendingRewardAmount);
        }

        if (pendingFee > 0) {
            uint256 burnPart = (pendingFee * 50) / 100;
            uint256 treasuryPart = pendingFee - burnPart;

            if (treasuryPart > 0) {
                token.mint(treasury, treasuryPart);
            }

            if (burnPart > 0) {
                token.mint(address(this), burnPart);
                token.burnFrom(address(this), burnPart);
            }
        }

        emit RewardClaimed(userAddr, pendingRewardAmount, pendingFee);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}