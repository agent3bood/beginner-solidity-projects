pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Swapper {
    mapping(ERC721 => mapping(uint256 => mapping(ERC721 => uint256))) private swaps;

    // sender will offer "a" to be exchanged by "b"
    // when "a" is offered to be exchanged by "b", and "b" is offered to be exchanged by "a",
    // then anyone can execute the exchange
    function offer(ERC721 address_a, uint256 id_a, ERC721 address_b, uint256 id_b) public {
        require(address_a.getApproved(id_a) == address(this) || address_a.isApprovedForAll(msg.sender, address(this)));
        swaps[address_a][id_a][address_b] = id_b;
    }

    function execute(ERC721 address_a, uint256 id_a, ERC721 address_b, uint256 id_b) public {
        require(swaps[address_a][id_a][address_b] == id_b || swaps[address_b][id_b][address_a] == id_a);
        address owner_a;
        address owner_b;
        (owner_a, owner_b) = (address_a.ownerOf(id_a), address_b.ownerOf(id_b));
        require(owner_a == msg.sender || owner_b == msg.sender);
        address_a.transferFrom(owner_a, owner_b, id_a);
        address_b.transferFrom(owner_b, owner_a, id_b);
        delete swaps[address_a][id_a][address_b];
        delete swaps[address_b][id_b][address_a];
    }
}
