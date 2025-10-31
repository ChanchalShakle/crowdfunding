// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title GreenEnergyFund - A decentralized funding platform for renewable energy projects.
contract Project {
    address public owner;

    struct ProjectInfo {
        string name;
        string description;
        uint256 goalAmount;
        uint256 totalFunded;
        bool goalReached;
    }

    ProjectInfo public project;
    mapping(address => uint256) public contributions;

    event Funded(address indexed contributor, uint256 amount);
    event Withdrawn(uint256 amount);
    event Refunded(address indexed contributor, uint256 amount);
    event GoalUpdated(uint256 newGoal);

    constructor(
        string memory _name,
        string memory _description,
        uint256 _goalAmount
    ) {
        owner = msg.sender;
        project = ProjectInfo({
            name: _name,
            description: _description,
            goalAmount: _goalAmount,
            totalFunded: 0,
            goalReached: false
        });
    }

    /// @notice Fund the project with ETH
    function fundProject() external payable {
        require(msg.value > 0, "You must send ETH to fund the project");
        project.totalFunded += msg.value;
        contributions[msg.sender] += msg.value;

        if (project.totalFunded >= project.goalAmount) {
            project.goalReached = true;
        }

        emit Funded(msg.sender, msg.value);
    }

    /// @notice Withdraw collected funds (only owner, once goal reached)
    function withdrawFunds() external {
        require(msg.sender == owner, "Only owner can withdraw funds");
        require(project.goalReached, "Funding goal not yet reached");
        uint256 amount = address(this).balance;
        require(amount > 0, "No funds to withdraw");
        payable(owner).transfer(amount);
        emit Withdrawn(amount);
    }

    /// @notice Get contract balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /// 🆕 1️⃣ Allow contributors to refund their funds if the goal is not reached
    function refund() external {
        require(!project.goalReached, "Goal reached, refunds not allowed");
        uint256 amount = contributions[msg.sender];
        require(amount > 0, "No funds to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        project.totalFunded -= amount;

        emit Refunded(msg.sender, amount);
    }

    /// 🆕 2️⃣ Owner can update the project goal (only if not reached yet)
    function updateGoal(uint256 newGoal) external {
        require(msg.sender == owner, "Only owner can update goal");
        require(!project.goalReached, "Goal already reached");
        require(newGoal > project.totalFunded, "New goal must exceed current funding");
        project.goalAmount = newGoal;

        emit GoalUpdated(newGoal);
    }
}
