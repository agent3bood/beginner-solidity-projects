pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Auction {
    error NFTNotAuthorised();
    error DeadlineMustBeFuture();
    error AuctionExist();
    error AuctionNotFound();
    error AuctionClosed();
    error AuctionNotClosed();
    error CannotBidZero();
    error CannotBidLower();

    // ERC721 => id => Info
    mapping(address => mapping(uint => AuctionInfo)) private auctions;
    // ERC721 => id => bidder => bid
    mapping(address => mapping(uint => mapping(address => uint))) private bids;
    // ERC721 => id => list of bidders
    mapping(address => mapping(uint => address[])) private auctionBidders;

    struct AuctionInfo {
        uint deadline;
        uint reserve;
        address winner;
        uint winnerBid;
    }

    function deposit(IERC721 nft, uint id, uint deadline, uint reserve) external {
        if (!(nft.getApproved(id) == address(this) || !nft.isApprovedForAll(msg.sender, address(this)))) {
            revert NFTNotAuthorised();
        }
        if (deadline <= block.timestamp) {
            revert DeadlineMustBeFuture();
        }
        if (auctions[address(nft)][id].deadline != 0) {
            revert AuctionExist();
        }
        AuctionInfo memory info = AuctionInfo({deadline: deadline, reserve: reserve, winner: address(0), winnerBid: 0});
        auctions[address(nft)][id] = info;
    }

    function bid(IERC721 nft, uint id) external payable {
        if (msg.value == 0) {
            revert CannotBidZero();
        }
        if (auctions[address(nft)][id].deadline == 0) {
            revert AuctionNotFound();
        }
        if (auctions[address(nft)][id].deadline < block.timestamp) {
            revert AuctionClosed();
        }
        uint existingBid = bids[address(nft)][id][msg.sender];
        uint newBid = msg.value;
        if(newBid <= existingBid) {
            revert CannotBidLower();
        }
        if (existingBid == 0) {
            auctionBidders[address(nft)][id].push(msg.sender);
        }
        bids[address(nft)][id][msg.sender] = newBid;
        if (newBid > auctions[address(nft)][id].winnerBid) {
            auctions[address(nft)][id].winner = msg.sender;
            auctions[address(nft)][id].winnerBid = newBid;
        }
    }

    function sellerEndAuction(IERC721 nft, uint id) external {
        require(nft.ownerOf(id) == msg.sender, "Only seller can end auction");
        if (auctions[address(nft)][id].deadline > block.timestamp) {
            revert AuctionNotClosed();
        }
        if (auctions[address(nft)][id].reserve <= auctions[address(nft)][id].winnerBid) {
            auctionSuccess(nft, id);
        } else {
            auctionCancel(nft, id);
        }
    }

    function auctionSuccess(IERC721 nft, uint id) internal {
        address winner = auctions[address(nft)][id].winner;
        uint winnerBid = auctions[address(nft)][id].winnerBid;
        // sen the NFT to the winner
        nft.transferFrom(msg.sender, winner, id);
        // send eth to the NFT owner
        (bool ok1,) = payable(msg.sender).call{value: winnerBid}("");
        require(ok1);
        // revert everybody else eth
        uint bidsCount = auctionBidders[address(nft)][id].length;
        for (uint i = 0; i < bidsCount; i++) {
            address bidder = auctionBidders[address(nft)][id][i];
            if (bidder != winner) {
                uint userBid = bids[address(nft)][id][bidder];
                (bool ok2, ) = payable(bidder).call{value: userBid}("");
                require(ok2);
                delete bids[address(nft)][id][bidder];
            }
        }
        // cleanup storage
        delete auctions[address(nft)][id];
        delete auctionBidders[address(nft)][id];
    }

    function auctionCancel(IERC721 nft, uint id) internal {
        // send back the eth to the bidders
        uint bidsCount = auctionBidders[address(nft)][id].length;
        for (uint i = 0; i < bidsCount; i++) {
            address bidder = auctionBidders[address(nft)][id][i];
            uint userBid = bids[address(nft)][id][bidder];
            (bool ok, ) = payable(bidder).call{value: userBid}("");
            require(ok);
            delete bids[address(nft)][id][bidder];
        }
        // cleanup storage
        delete auctions[address(nft)][id];
        delete auctionBidders[address(nft)][id];
    }
}
