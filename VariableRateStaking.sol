// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
* @title Variable Rate Staking Contract
* @author Adam O'Callaghan
*/

contract VariableRateStaking is ERC20 {

    mapping(address => uint256) public staked;
    mapping(address => uint256) public stakedFromTimestamp;

    constructor() ERC20("SIRLOIN TOKEN", "SRLN") {
        _mint(msg.sender,100000000000000000000000000);
    }

    function stake(uint256 amount) external {
        // REQUIRES...
        require(amount > 0, "Amount is <= 0");
        require(balanceOf(msg.sender) >= amount, "Balance is <= amount");
        // STAKE TOKENS...
        _transfer(msg.sender, address(this), amount);
        // CLAIM IF DEPOSITOR HAS TOKENS CURRENTLY STAKED...
        if(staked[msg.sender] > 0) {
            claim();
        }
        stakedFromTimestamp[msg.sender] = block.timestamp;
        staked[msg.sender] += amount;
    }

    function unstake(uint256 amount) external {
        // REQUIRES...
        require(amount > 0, "Amount is <= 0");
        require(staked[msg.sender] >= amount, "Amount is > Staked");
        // CLAIM...
        claim();
        // UNSTAKE
        staked[msg.sender] -= amount;
        _transfer(address(this), msg.sender, amount);
    }

    function claim() public {
        // REQUIRES...
        require(staked[msg.sender] > 0, "Staked is <= 0");
        // CALCULATE REWARDS...
        uint256 secondsStaked = block.timestamp - stakedFromTimestamp[msg.sender];
        uint256 rewards;
        if(secondsStaked <= 2.628e6) { // Less than 1 month staked
            rewards = staked[msg.sender] * secondsStaked / 2.628e6;
        } else { // else
            rewards = staked[msg.sender] * secondsStaked / 3.154e7;
        }

        _mint(msg.sender,rewards);

        stakedFromTimestamp[msg.sender] = block.timestamp;
    }
}
