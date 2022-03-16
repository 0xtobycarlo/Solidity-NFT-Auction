# .sol NFT Auction

A basic Solidity contract outline for an NFT Auction. 

For production use, this contract would need to be tweaked because:
- Withdraw() can be called before auction ends. Someone could bid and withdraw their bid in the same transaction and still be the highest bidder despite the contract having 0 eth in the contract.

- Seller can probably drain all of the bids once the auction is over using a re-entrancy attack when (bool sent, bytes memory data) = seller.call{value: highestBid}(""); is called. Seller contract's callback function just needs to call end() again to get paid a second time.
