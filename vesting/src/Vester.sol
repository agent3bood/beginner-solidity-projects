pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Vester {
    struct Deposit {
        uint256 amount;
        uint256 time;
    }

    mapping(address => Deposit) public deposits;
    mapping(address => uint256) public withdrawn;

    function deposit(ERC20 token, address receiver, uint256 amount) public {
        address sender = msg.sender;
        require(deposits[receiver].amount == 0);
        (bool ok) = token.transferFrom(sender, address(this), amount);
        require(ok);
        deposits[receiver] = Deposit(amount, block.timestamp);
    }

    function withdraw(ERC20 token, uint256 amount) public {
        address sender = msg.sender;
        Deposit memory d = deposits[sender];
        require(d.amount > 0);

        uint256 elapsed = (block.timestamp - d.time) / 60 / 60 / 24;
        uint256 allowance = d.amount / 100;
        uint256 w = withdrawn[sender];
        uint256 available = allowance * elapsed - w;
        require(available > 0);
        require(amount <= available);
        (bool transfer_ok) = token.transfer(sender, amount);
        require(transfer_ok);
        withdrawn[sender] += amount;
    }
}
