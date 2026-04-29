// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

import "./GBNToken.sol";

contract MinerManager is Initializable, OwnableUpgradeable, UUPSUpgradeable, PausableUpgradeable {
    GBNToken public token;

    uint256 public constant MINER_COST = 100 ether;
    uint256 public rate;

    uint256 public rewardIndex;
    uint256 public feeIndex;
    uint256 public lastUpdate;

    struct User {
        uint256 miners;
        uint256 rewardDebt;
        uint256 feeDebt;
    }

    mapping(address => User) public users;

    modifier userPurchasedOneMinerAtLeast() {
        require(users[msg.sender].miners > 0, "Buy a miner first");
        _;
    }

    constructor() {
        _disableInitializers();
    }

    function _updateIndex() internal {
        uint256 timePassed = block.timestamp - lastUpdate;
        if (timePassed == 0) return;

        uint256 supply = token.totalSupply() / 1000 ether;

        uint256 baseReward = 2 ether;
        uint256 baseFee = 1 ether;

        uint256 rewardPerDay =
            (baseReward * 1000) / (1000 + supply);

        uint256 feePerDay =
            baseFee + (supply * 1 ether / 10);

        rewardIndex += (rewardPerDay * timePassed) / 1 days;
        feeIndex += (feePerDay * timePassed) / 1 days;

        lastUpdate = block.timestamp;
    }

    function buyMiner() external whenNotPaused {
        _updateIndex();

        User storage user = users[msg.sender];

        _claimInternal(msg.sender);

        token.burnFrom(msg.sender, MINER_COST);

        user.miners += 1;

        user.rewardDebt = user.miners * rewardIndex;
        user.feeDebt = user.miners * feeIndex;
    }

    function claim() external whenNotPaused userPurchasedOneMinerAtLeast {
        _updateIndex();
        _claimInternal(msg.sender);
    }

    function _claimInternal(address userAddr) internal {
        User storage user = users[userAddr];

        if (user.miners == 0) return;

        uint256 accumulatedReward =
            user.miners * rewardIndex;

        uint256 accumulatedFee =
            user.miners * feeIndex;

        uint256 pendingReward =
            accumulatedReward - user.rewardDebt;

        uint256 pendingFee =
            accumulatedFee - user.feeDebt;

        uint256 net =
            pendingReward > pendingFee
                ? pendingReward - pendingFee
                : 0;

        user.rewardDebt = accumulatedReward;
        user.feeDebt = accumulatedFee;

        if (net > 0) {
            token.mint(userAddr, net);
        }
    }

    function buyTokens() external payable whenNotPaused {
        require(msg.value > 0, "Send ETH");

        uint256 amount = msg.value * rate;
        token.mint(msg.sender, amount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function initialize(address _token) public initializer {
        __Ownable_init(msg.sender);
        __Pausable_init();

        token = GBNToken(_token);
        rate = 1000;

        lastUpdate = block.timestamp;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}