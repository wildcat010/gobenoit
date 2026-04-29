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

    address public treasury;

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

    function pendingReward(address userAddr) public view returns (uint256) {
        User memory user = users[userAddr];

        uint256 supply = token.totalSupply() / 1000 ether;

        uint256 rewardPerDay = (2 ether * 1000) / (1000 + supply);

        uint256 elapsed = block.timestamp - lastUpdate;

        uint256 currentIndex = rewardIndex + (rewardPerDay * elapsed) / 1 days;

        uint256 accumulated = user.miners * currentIndex;

        return accumulated - user.rewardDebt;
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

        _claim(msg.sender);

        token.burnFrom(msg.sender, MINER_COST);

        user.miners += 1;

        user.rewardDebt = user.miners * rewardIndex;
        user.feeDebt = user.miners * feeIndex;
    }

    function claim() external whenNotPaused userPurchasedOneMinerAtLeast {
        _updateIndex();
        _claim(msg.sender);
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury; 
    }

    function _claim(address userAddr) internal {
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

        user.rewardDebt = accumulatedReward;
        user.feeDebt = accumulatedFee;

        if (pendingReward > 0) {
            token.mint(userAddr, pendingReward);
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
        treasury = msg.sender;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}