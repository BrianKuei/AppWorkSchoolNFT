// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract AppWorkSchoolNFT is ERC721, Ownable {
  using Strings for uint256;

  using Counters for Counters.Counter;
  Counters.Counter private _nextTokenId;

  uint256 public price = 0.01 ether;
  uint256 public constant MAX_SUPPLY = 100;
 
  bool public mintActive = false;
  bool public earlyMintActive = false;
  bool public blindBoxOpened = false;
  
  string public baseURI;
  bytes32 public merkleRoot;
  string private _blindTokenURI = "ipfs://link";

  mapping(uint256 => string) private _tokenURIs;
  mapping(address => uint256) public addressMintedBalance;

  constructor() ERC721("AppWorks", "AW") {
 
  }

  modifier checkActiveMintableFund (bool _active, uint _amount) {
    //Current state is available for Public Mint
    require(_active, "is not available to mint");

    //Check how many NFTs are available to be minted
    require(totalSupply() + _amount <= MAX_SUPPLY, "no more");

    //Check user has sufficient funds
    require(msg.value >= _amount * price, "no sufficient funds");

    _;
  }

  function processMint(uint256 _amount, string calldata uri) private{
    addressMintedBalance[msg.sender] += _amount;
    uint currentId = totalSupply();

    for(uint i; i < _amount; ++i){
      _nextTokenId.increment();
      _safeMint(msg.sender, currentId + i);
    }
  }
  
  // Public mint function - week 8
  function mint(uint256 _mintAmount, string calldata uri) public payable checkActiveMintableFund(mintActive, _mintAmount) {
    //Please make sure you check the following things:
    
    require(mintLimit(), "Excess max to mint");

    processMint(_mintAmount, uri);
  }

  // Set mint per user limit to 10 and owner limit to 20 - Week 8
  function mintLimit() private view returns(bool) {
    uint mintedBalance = addressMintedBalance[msg.sender];
    if(msg.sender == owner()) {
      return mintedBalance < 20;
    }
    return mintedBalance < 10;
  }

  function isValid(bytes32[] calldata proof, bytes32 leaf) public view returns (bool) {
    return MerkleProof.verifyCalldata(proof, merkleRoot, leaf);
  }

  // Early mint function for people on the whitelist - week 9
  function earlyMint(bytes32[] calldata _merkleProof, uint256 _mintAmount, string calldata uri) public payable checkActiveMintableFund(earlyMintActive, _mintAmount) {
    //Please make sure you check the following things:
    //Check user is in the whitelist - use merkle tree to validate
    require(isValid(_merkleProof, keccak256(abi.encodePacked(msg.sender))), "Not a part of whitlist");
    processMint(_mintAmount, uri);
  }

   // Implement totalSupply() Function to return current total NFT being minted - week 8
  function totalSupply() public view returns(uint) {
      return _nextTokenId.current();
  }

  // Function to return the base URI
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function tokenURI(uint256 tokenId) public view virtual override(ERC721) returns (string memory) {
     _requireMinted(tokenId);

    if(blindBoxOpened){
      return bytes(_baseURI()).length > 0 ? string(abi.encodePacked(_baseURI(), tokenId.toString())) : "";
    } else {
      return _blindTokenURI;
    }
  }

  // Implement setMerkleRoot(merkleRoot) Function to set new merkle root - week 9
  function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
    merkleRoot = _merkleRoot;
  }

  function _setTokenURI(uint256 tokenId, string calldata _tokenURI) internal virtual {
      require(!_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
      _tokenURIs[tokenId] = _tokenURI;
  }

   // Implement setPrice(price) Function to set the mint price - week 8
  function setPrice(uint _newPrice) external onlyOwner {
      price = _newPrice;
  }

   // Implement setBaseURI(newBaseURI) Function to set BaseURI - week 9
  function setBaseURI(string calldata _newBaseURI) external onlyOwner {
    baseURI = _newBaseURI;
  }

  // Implement toggleMint() Function to toggle the public mint available or not - week 8
  function toggleMint() external onlyOwner {
    mintActive = !mintActive;
  }

  // Implement toggleReveal() Function to toggle the blind box is blindBoxOpened - week 9
  function toggleBlindBoxOpened() external onlyOwner {
    blindBoxOpened = !blindBoxOpened;
  }
  
  // Implement toggleEarlyMint() Function to toggle the early mint available or not - week 9
  function toggleEarlyMint() external onlyOwner {
    earlyMintActive = !earlyMintActive;
  }

  // Implement withdrawBalance() Function to withdraw funds from the contract - week 8
  function withdrawBalance() external onlyOwner {
    (bool success,) = msg.sender.call{value: address(this).balance}("");
    require(success, "withdraw failed");
  }

  // Let this contract can be upgradable, using openzepplin proxy library - week 10
  // Try to modify blind box images by using proxy
  
}