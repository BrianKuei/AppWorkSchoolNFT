// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";

contract AppWorkSchoolNFT_v2 is ERC721Upgradeable, OwnableUpgradeable {
  using StringsUpgradeable for uint256;

  using CountersUpgradeable for CountersUpgradeable.Counter;
  CountersUpgradeable.Counter private _nextTokenId;

  uint256 public price;
  uint256 public MAX_SUPPLY;
 
  bool public mintActive;
  bool public earlyMintActive;
  bool public blindBoxOpened;
  
  string public baseURI;
  bytes32 public merkleRoot;
  string private _blindTokenURI;

  mapping(uint256 => string) private _tokenURIs;
  mapping(address => uint256) public addressMintedBalance;

  function initialize() initializer public {
    __ERC721_init("AppWorks", "AW");

    price = 0.01 ether;
    MAX_SUPPLY = 100;
    mintActive = false;
    earlyMintActive = false;
    blindBoxOpened = false;
    _blindTokenURI = "ipfs://link";
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

    for(uint i = 0; i < _amount; i++){
      uint currentId = totalSupply();
      _nextTokenId.increment();
      _setTokenURI(currentId, uri);
      _safeMint(msg.sender, currentId);
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
    return MerkleProofUpgradeable.verifyCalldata(proof, merkleRoot, leaf);
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

  function tokenURI(uint256 tokenId) public view virtual override(ERC721Upgradeable) returns (string memory) {
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
  function setBaseURI(string calldata newBaseURI) external onlyOwner {
    baseURI = newBaseURI;
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
  function modifiyBlindBoxImage(string calldata uri) external onlyOwner {
    _blindTokenURI = uri;
  }
}