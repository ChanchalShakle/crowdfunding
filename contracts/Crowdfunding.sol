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
    }

    ProjectInfo public project;
    mapping(address => uint256) public contributions;

    event Funded(address indexed contributor, uint256 amount);
    event Withdrawn(uint256 amount);

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
            totalFunded: 0
        });
    }

    /// @notice Fund the project with ETH
    function fundProject() external payable {
        require(msg.value > 0, "You must send ETH to fund the project");
        project.totalFunded += msg.value;
        contributions[msg.sender] += msg.value;
        emit Funded(msg.sender, msg.value);
    }

    /// @notice Withdraw collected funds (only owner)
    function withdrawFunds() external {
        require(msg.sender == owner, "Only owner can withdraw funds");
        uint256 amount = address(this).balance;
        require(amount > 0, "No funds to withdraw");
        payable(owner).transfer(amount);
        emit Withdrawn(amount);
    }

    /// @notice Get contract balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

