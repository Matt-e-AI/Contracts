// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts@4.8.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.8.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.0/utils/Counters.sol";
import "@openzeppelin/contracts@4.8.0/utils/Strings.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";


contract MatteNft is DefaultOperatorFilterer, ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 public price = 0; //0.005 ETH

    constructor() ERC721("matt-e nft", "matte") {}

    // Base URI
    string private _baseURL = "https://mattenft.blob.core.windows.net/bsc/nft-metadata/";

    // The following functions are for setting and viewing the baseURI

    function _baseURI() internal view override returns (string memory) {
        return _baseURL;
    }

    /**
     * @dev Returns the base URI set via {_setBaseURI}. This will be
     * automatically added as a prefix in {tokenURI} to each token's URI, or
     * to the token ID if no specific URI is set for that token ID.
     */

    function baseURI() public view virtual returns (string memory) {
        return _baseURI();
    }

    function setBaseURI(string memory bURI) public onlyOwner {
        _setBaseURI(bURI);
    }

    /**
     * @dev Internal function to set the base URI for all token IDs. It is
     * automatically added as a prefix to the value returned in {tokenURI},
     * or to the token ID if {tokenURI} is empty.
     */

    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURL = baseURI_;
    }

    // Function to set the price of the NFT by the owner
    function setPrice(uint256 _price) public onlyOwner {
        // Set the price
        price = _price;
    }

    // Function for minting the NFT
    function mint() public payable {
        require(msg.value >= price, "Ether value sent is not correct");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, Strings.toString(tokenId));
    }

    // Function for the owner to withdrawl all the ETH from the contract
    function withdrawETH() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function isContract(address account) public onlyOwner view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function withdrawERC20(address _erc20Contract) public onlyOwner {
        require(isContract(_erc20Contract), "The contract passed as an argument is not a valid contract");
        // Calculate the amount of ERC-20 tokens to withdraw
        uint256 erc20Balance = ERC20(_erc20Contract).balanceOf(address(this));
        // Transfer the ERC-20 tokens to the contract owner
        ERC20(_erc20Contract).transfer(owner(), erc20Balance);
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // OVERRIDING ERC-721 IMPLEMENTATION TO ALLOW OPENSEA ROYALTIES ENFORCEMENT PROTOCOL

    /**
        @dev implements `setApprovalForAll` with additional approved Operator checking
     */
    function setApprovalForAll(address operator, bool approved) public override(ERC721, IERC721) onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    /**
        @dev implements `approve` with additional approved Operator checking
     */
    function approve(address operator, uint256 tokenId) public override(ERC721, IERC721) onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    /**
        @dev implements `transferFrom` with additional approved Operator checking
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    /**
        @dev implements `safeTransferFrom` with additional approved Operator checking
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    /**
        @dev implements `safeTransferFrom` with additional approved Operator checking
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override(ERC721, IERC721) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

}
