pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GLDNFT is ERC721 {
    constructor() ERC721("Gold", "GLD") {}

    function mint(IERC20 token, uint256 nft) external {
        require(_ownerOf(nft) == address(0));
        (bool transfer_ok) = token.transferFrom(_msgSender(), address(this), nft);
        require(transfer_ok);
        _safeMint(_msgSender(), nft);
    }
}
