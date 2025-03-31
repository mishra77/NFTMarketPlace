NFT Marketplace Smart Contract : Successfully verified contract "contracts/NFTMarketplace.sol:NFTMarketplace" for network sepolia:
"https://sepolia.etherscan.io/address/0xdD9bAc24F1015F26D0aF620577c1dFBe2C6837f3#code"

The NFT Marketplace Smart Contract allows users to mint, list, buy, and resell NFTs (Non-Fungible Tokens) on the Ethereum blockchain. The contract enables a decentralized marketplace for trading NFTs, providing a transparent, secure, and decentralized method to manage digital assets. The contract is built using Solidity and uses the OpenZeppelin library for standard ERC721 functionality, ownership management, and protection against reentrancy attacks.

Features :
Mint NFTs: Users can mint new NFTs and assign metadata to them.

List NFTs for Sale: Users can list their NFTs for sale on the marketplace by paying a listing fee.

Buy NFTs: Buyers can purchase NFTs listed for sale on the marketplace.

Resell NFTs: Buyers can resell the NFTs they own on the marketplace.

Marketplace Fee: The marketplace charges a small listing fee for putting NFTs up for sale.

Contract Functions :
mintNFT(string memory tokenURI)
Mints a new NFT with the given metadata URI.

listNFT(uint256 tokenId, uint256 price)
Lists an NFT for sale on the marketplace, paying the listing fee.

createMarketSale(uint256 tokenId)
Buys an NFT listed for sale by paying the seller’s price.

resellToken(uint256 tokenId, uint256 price)
Resells an NFT that has been purchased on the marketplace.

updateListingPrice(uint256 _listingPrice)
Updates the marketplace listing fee (only by the contract owner).

fetchMarketItems(uint256 limit, uint256 offset)
Fetches unsold NFTs available for sale with pagination.

fetchItemsListed()
Fetches all NFTs listed for sale by the caller.

fetchMyNFTs()
Fetches all NFTs owned by the caller.

transferMarketplaceOwnership(address newOwner)
Transfers ownership of the marketplace contract to a new address.

renounceMarketplaceOwnership()
Renounces ownership of the marketplace contract.

Verified Contract on Sepolia
The smart contract has been deployed and successfully verified on the Sepolia test network. You can view the contract on Etherscan by clicking the link below:
Successfully verified contract "contracts/NFTMarketplace.sol:NFTMarketplace" for network sepolia:
"https://sepolia.etherscan.io/address/0xdD9bAc24F1015F26D0aF620577c1dFBe2C6837f3#code"
View NFTMarketplace Contract on Sepolia Etherscan

