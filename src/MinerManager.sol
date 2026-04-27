// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";


import "./GBNToken.sol";

contract MinerManager is  Initializable, OwnableUpgradeable, UUPSUpgradeable, PausableUpgradeable {
    GBNToken public token;

    uint256 public constant MINER_COST = 100 ether;
    uint256 public rate;

    struct User {
        uint256 miners;
        uint256 lastClaim;
    }

    mapping(address => User) public users;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // 🔥 Buy miner (burn tokens)
    function buyMiner() external {
        token.burnFrom(msg.sender, MINER_COST);

        users[msg.sender].miners += 1;
        users[msg.sender].lastClaim = block.timestamp;
    }


    function getRewardPerDay() public view returns (uint256) {
        uint256 baseReward = 2 ether;
        uint256 supplyFactor = token.totalSupply() / 1000 ether;

        return baseReward * 1000 / (1000 + supplyFactor);
    }

  
    function getFeePerDay() public view returns (uint256) {
        uint256 baseFee = 1 ether;
        uint256 supplyFactor = token.totalSupply() / 1000 ether;

        return baseFee + (supplyFactor / 10);
    }

  
    function claim() external {
        User storage user = users[msg.sender];

        uint256 timePassed = block.timestamp - user.lastClaim;
        require(timePassed > 0, "Nothing to claim");

        uint256 rewardPerDay = getRewardPerDay();
        uint256 feePerDay = getFeePerDay();

        uint256 reward = (rewardPerDay * user.miners * timePassed) / 1 days;
        uint256 fee = (feePerDay * user.miners * timePassed) / 1 days;

        uint256 net = reward > fee ? reward - fee : 0;

        user.lastClaim = block.timestamp;

        // 🪙 Mint reward
        token.mint(msg.sender, net);

        // 🔥 Burn fee
        token.mint(address(this), fee);
        token.burnFrom(address(this), fee);
    }

    function buyTokens() external payable {
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
        rate = 1000; // 1 ETH = 1000 GBN
    }

    // REQUIRED by UUPS
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner{

    }
}