pragma solidity 0.9.0;

interface IERC721 {
    function transfer(address, uint256) external;

    function transferFrom(
        address,
        address,
        uint256
    ) external;
}

contract Auction {
    event Start();
    event End(address highestBidder, uint256 highestBid);
    event Bid(address indexed sender, uint256 amount);
    event Withdraw(address indexed bidder, uint256 amount);

    address payable public seller;

    bool public started;
    bool public ended;
    uint256 public endAt;

    IERC721 public nft;
    uint256 public nftId;

    uint256 public highestBid;
    address public highestBidder;
    mapping(address => uint256) public bids;

    constructor() {
        seller = payable(msg.sender);
    }

    function start(
        IERC721 _nft,
        uint256 _nftId,
        uint256 startingBid
    ) external {
        require(!started, "Already Started!");
        require(msg.sender == seller, "You Did Not Start The Auction!");
        highestBid = startingBid;

        nft = _nft;
        nftId = _nftId;
        nft.transferFrom(msg.sender, address(this), nftId);

        started = true;
        endAt = block.timestamp + 2 days;

        emit Start();
    }

    function bid() external payable {
        require(started, "Not Started.");
        require(block.timestamp < endAt, "Ended!");
        require(msg.value > highestBid);

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;

        emit Bid(highestBidder, highestBid);
    }

    function withdraw() external payable {
        uint256 bal = bids[msg.sender];
        bids[msg.sender] = 0;
        (bool sent, bytes memory data) = payable(msg.sender).call{value: bal}(
            ""
        );
        require(sent, "Could Not Withdraw");

        emit Withdraw(msg.sender, bal);
    }

    function end() external {
        require(started, "You Need To Start First!");
        require(block.timestamp >= endAt, "Auction Is Still Ongoing!");
        require(!ended, "Auction Already Ended!");

        if (highestBidder != address(0)) {
            nft.transfer(highestBidder, nftId);
            (bool sent, bytes memory data) = seller.call{value: highestBid}("");
            require(sent, "Could Not Pay Seller!");
        } else {
            nft.transfer(seller, nftId);
        }

        ended = true;
        emit End(highestBidder, highestBid);
    }
}
