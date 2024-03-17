pragma solidity ^0.8.23;

contract Funder {
    uint256 private cursor = 0;
    mapping(uint256 => Fundraiser) public fundraisers;

    struct Fundraiser {
        address payable owner;
        uint256 goal;
        uint256 deadline;
        uint256 balance;
    }

    // donator => fundraiserId => amount
    mapping(address => mapping(uint256 => uint256)) private donations;

    function createFundraiser(uint256 goal, uint256 deadline) public returns (uint256) {
        require(goal > 0, "Goal must be greater than 0");
        require(deadline > block.timestamp, "Deadline must be in the future");
        uint256 fundraiserId = cursor;
        cursor++;
        fundraisers[fundraiserId] = Fundraiser(payable(msg.sender), goal, deadline, 0);
        return fundraiserId;
    }

    function fund(uint256 fundraiserId) public payable {
        require(fundraiserId < cursor, "Fundraiser does not exist");
        Fundraiser storage fundraiser = fundraisers[fundraiserId];
        require(block.timestamp <= fundraiser.deadline, "Fundraiser is closed");
        require(msg.value > 0, "Donation must be greater than 0");
        donations[msg.sender][fundraiserId] += msg.value;
        fundraiser.balance += msg.value;
    }

    function refund(uint256 fundraiserId) public {
        Fundraiser storage fundraiser = fundraisers[fundraiserId];
        require(block.timestamp > fundraiser.deadline, "Cannot refund before deadline");
        require(fundraiser.goal > fundraiser.balance, "Cannot refund when goal is met");
        uint donated = donations[msg.sender][fundraiserId];
        payable(msg.sender).transfer(donated);
        donations[msg.sender][fundraiserId] = 0;
        fundraiser.balance -= donated;
    }

    function withdraw(uint256 fundraiserId) public {
        require(fundraiserId < cursor, "Fundraiser does not exist");
        Fundraiser storage fundraiser = fundraisers[fundraiserId];
        require(msg.sender == fundraiser.owner, "Only owner can withdraw");
        require(block.timestamp > fundraiser.deadline, "Fundraiser not closed yet");
        require(fundraiser.balance >= fundraiser.goal, "Fundraiser did not meet goal");
        fundraiser.owner.transfer(fundraiser.balance);
        fundraiser.balance = 0;
    }
}
