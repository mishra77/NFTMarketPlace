// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721URIStorage, ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIds; // Counter to keep track of NFTs minted
    Counters.Counter private _itemsSold; // Counter to track the number of items sold
    
    uint256 public listingPrice = 0.025 ether; // Marketplace listing fee

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address owner;
        uint256 price;
        bool sold;
        bool active;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;
    mapping(address => uint256[]) private ownedTokens;
    mapping(address => uint256[]) private listedTokens;
    
    event MarketItemCreated(uint256 indexed tokenId, address indexed seller, address indexed owner, uint256 price, bool sold);
    event MarketItemSold(uint256 indexed tokenId, address indexed buyer, uint256 price);
    event MarketItemRelisted(uint256 indexed tokenId, address indexed seller, uint256 price);
    event ListingCancelled(uint256 indexed tokenId, address indexed seller);
    event ListingUpdated(uint256 indexed tokenId, uint256 newPrice);

    constructor() ERC721("Metaverse Tokens", "METT") Ownable() {} // for remix Ownable(msg.sender)

    // Update the listing fee for the marketplace
    function updateListingPrice(uint256 _listingPrice) external onlyOwner {
        listingPrice = _listingPrice;
    }

    // Mint a new NFT and store its metadata
    function mintNFT(string memory tokenURI) external returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        ownedTokens[msg.sender].push(newTokenId);

        return newTokenId;
    }

    // List an NFT for sale on the marketplace
    function listNFT(uint256 tokenId, uint256 price) external payable nonReentrant {
        require(ownerOf(tokenId) == msg.sender, "You must own the NFT to list it");
        require(price > 0, "Price must be greater than zero");
        require(msg.value == listingPrice, "Must pay the listing fee");

        idToMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            address(this),
            price,
            false,
            true
        );

        listedTokens[msg.sender].push(tokenId);
        _transfer(msg.sender, address(this), tokenId);
        emit MarketItemCreated(tokenId, msg.sender, address(this), price, false);
    }

    // Purchase an NFT listed on the marketplace
    function createMarketSale(uint256 tokenId) external payable nonReentrant {
        MarketItem storage item = idToMarketItem[tokenId];

        require(msg.value == item.price, "Must pay the exact price");
        require(!item.sold, "Item already sold");
        require(item.active, "Item is no longer available");

        address seller = item.seller;
        item.owner = msg.sender;
        item.sold = true;
        item.active = false;
        item.seller = payable(address(0));
        _itemsSold.increment();

        _transfer(address(this), msg.sender, tokenId);

        (bool success1, ) = owner().call{value: listingPrice}("");
        (bool success2, ) = seller.call{value: msg.value - listingPrice}("");
        require(success1 && success2, "Transfer failed");

        emit MarketItemSold(tokenId, msg.sender, item.price);
    }

    // Resell a purchased NFT on the marketplace
    function resellToken(uint256 tokenId, uint256 price) external payable nonReentrant {
        require(ownerOf(tokenId) == msg.sender, "You must own the NFT to resell it");
        require(msg.value == listingPrice, "Must pay the listing fee");
        require(price > 0, "Price must be greater than zero");

        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].owner = address(this);
        idToMarketItem[tokenId].price = price;
        idToMarketItem[tokenId].sold = false;
        idToMarketItem[tokenId].active = true;
        _itemsSold.decrement();

        _transfer(msg.sender, address(this), tokenId);
        emit MarketItemRelisted(tokenId, msg.sender, price);
    }

    // Fetch all unsold NFTs with pagination
    function fetchMarketItems(uint256 limit, uint256 offset) external view returns (MarketItem[] memory) {
        uint256 totalItems = _tokenIds.current();
        uint256 itemCount = 0;
        
        for (uint256 i = 1; i <= totalItems; i++) {
            if (idToMarketItem[i].active && !idToMarketItem[i].sold) {
                itemCount++;
            }
        }
        
        uint256 endIndex = offset + limit > itemCount ? itemCount : offset + limit;
        MarketItem[] memory items = new MarketItem[](endIndex - offset);
        uint256 currentIndex = 0;
        
        for (uint256 i = offset + 1; i <= endIndex; i++) {
            if (idToMarketItem[i].active && !idToMarketItem[i].sold) {
                items[currentIndex] = idToMarketItem[i];
                currentIndex++;
            }
        }
        return items;
    }

    // Fetch all NFTs listed by the caller
    function fetchItemsListed() external view returns (uint256[] memory) {
        return listedTokens[msg.sender];
    }

    // Fetch all NFTs owned by the caller
    function fetchMyNFTs() external view returns (uint256[] memory) {
        return ownedTokens[msg.sender];
    }

    // Transfer ownership of the marketplace contract
    function transferMarketplaceOwnership(address newOwner) external onlyOwner {
        transferOwnership(newOwner);
    }

    // Renounce ownership of the marketplace contract
    function renounceMarketplaceOwnership() external onlyOwner {
        renounceOwnership();
    }
}
