pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("MyToken", "TKN") {
        _mint(_msgSender(), 1_000_000);
    }
}
