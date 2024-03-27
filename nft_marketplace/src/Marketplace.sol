pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Marketplace {
    error NotApproved();
    error ExpireIsPast();
    error PriceIsTooLow();
    error OfferExists();

    struct Offer {
        address seller;
        uint price;
        uint expire;
    }

    mapping(IERC721 => mapping(uint => Offer)) public offers;

    function sell(IERC721 nft, uint id, uint price, uint expire) external {
        if (!(nft.getApproved(id) != address(this) || !nft.isApprovedForAll(nft.ownerOf(id), address(this)))) {
            revert NotApproved();
        }
        if (expire < block.timestamp) {
            revert ExpireIsPast();
        }
        if (!(price > 0)) {
            revert PriceIsTooLow();
        }
        if (!(offers[nft][id].seller == address(0))) {
            revert OfferExists();
        }
        Offer memory offer = Offer(msg.sender, price, expire);
        offers[nft][id] = offer;
    }

    function cancel(IERC721 nft, uint id) external {
        require(offers[nft][id].seller == msg.sender);
        delete offers[nft][id];
    }

    function buy(IERC721 nft, uint id) external payable {
        Offer memory offer = offers[nft][id];
        require(offer.seller != address(0));
        require(offer.price == msg.value);
        require(offer.expire > block.timestamp);
        payable(offer.seller).transfer(msg.value);
        nft.transferFrom(offer.seller, msg.sender, id);
        delete offers[nft][id];
    }
}
