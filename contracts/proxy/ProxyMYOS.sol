// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../immutable/MYOS.sol";

import "../library/MerkleProof.sol";

contract ProxyMYOS is Ownable, ReentrancyGuard {
  error NotEnoughEth(uint256 price, uint256 weiSended, uint256 quantity);
  error NoMoreToken(uint256 totalSupply, uint256 quantity);
  error NoMoreTokenOwned(uint256 balance, uint256 quantity);
  error SellMyosSendEth(address to, uint value);

  event settedCurrentPrice(address indexed sender, uint256 oldPrice, uint256 newPrice);
  event settedAddressMYOSToken(address indexed sender, address indexed oldAddress, address indexed newAddress);
  event settedMerkleTree(address indexed sender, bytes32 indexed oldMerkleRoot, uint256 oldMerkleEndTime, bytes32 indexed newMerkleRoot, uint256 newMerkleEndTime);

  address addressMYOSToken;
  uint256 currentpriceMYOS;
  uint256 merkleEndTime;
  bytes32 merkleRoot;

  ///@notice Update price of MYOS token for static price, if == 0 change for dynamic price
  ///@param newPrice value of price in matic wei (matic / 10**18)
  function setCurrentPriceMYOS(uint256 newPrice) external onlyOwner {
    emit settedCurrentPrice(_msgSender(), currentpriceMYOS, newPrice);
    currentpriceMYOS = newPrice;
  }

  ///@notice Update the destination address of the official contract MYOS token so that the delegation contract can access it
  ///@param _addressMYOSToken address of contract MYOS
  function setAddressMYOSToken(address _addressMYOSToken) external onlyOwner {
    emit settedAddressMYOSToken(_msgSender(), addressMYOSToken, _addressMYOSToken);
    addressMYOSToken = _addressMYOSToken;
  }

  ///@notice Set the merkle tree to create whitelist for mint
  ///@param _merkleRoot A bytes 32 represent root of tree for verify all merkle proof
  ///@param _merkleEndTime Represent a timestamp (in seconds) represents end of whitelist
  function setMerkleTree(bytes32 _merkleRoot, uint256 _merkleEndTime) external onlyOwner {
    emit settedMerkleTree(_msgSender(), merkleRoot, merkleEndTime, _merkleRoot, _merkleEndTime);
    merkleRoot = _merkleRoot;
    merkleEndTime = _merkleEndTime;
  }

  ///@notice Purchase of a resource for eth/MATIC
  ///@param quantity number of token myos you want purchase
  ///@param receiver address waller of receiver's token
  function buyMYOS(
    uint256 quantity,
    address receiver,
    bytes32[] calldata _proofs,
    uint256 _proofMaxQuantityPerTransaction
  ) external payable nonReentrant {
    verifyMerkleProof(_msgSender(), _proofs, _proofMaxQuantityPerTransaction);
    if (currentpriceMYOS != 0) {
      if (msg.value < (currentpriceMYOS * quantity))
        revert NotEnoughEth({
          price: currentpriceMYOS * quantity,
          weiSended: msg.value,
          quantity: quantity
        });
    }
    if (currentpriceMYOS == 0) {
      if (msg.value < (getDynamicPriceMYOS() * quantity))
        revert NotEnoughEth({
          price: getDynamicPriceMYOS() * quantity,
          weiSended: msg.value,
          quantity: quantity
        });
    }
    // (bool sent, ) = addressMYOSToken.call{ value: msg.value }("");
    // require(sent == true, "Send of eth not sent");
    MYOS(addressMYOSToken).mint(
      receiver,
      quantity * (10 ** uint256(MYOS(addressMYOSToken).decimals()))
    );
  }

  ///@notice Sale of MYOS token against MATIC
  ///@param quantity number of token myos you want sell
  function sellMYOS(uint256 quantity) external nonReentrant {
    if (MYOS(addressMYOSToken).totalSupply() <= quantity + 1)
      revert NoMoreToken({
        totalSupply: MYOS(addressMYOSToken).totalSupply(),
        quantity: quantity
      });
    if (
      MYOS(addressMYOSToken).balanceOf(_msgSender()) <
      quantity * (10 ** uint256(MYOS(addressMYOSToken).decimals()))
    )
      revert NoMoreTokenOwned({
        balance: MYOS(addressMYOSToken).balanceOf(_msgSender()),
        quantity: quantity
      });
    if (currentpriceMYOS != 0) {
      (bool sent, ) = _msgSender().call{ value: currentpriceMYOS * quantity }("");
      if (sent == false)
        revert SellMyosSendEth({ to: _msgSender(), value: currentpriceMYOS * quantity });
    }
    if (currentpriceMYOS == 0) {
      (bool sent, ) = _msgSender().call{ value: getDynamicPriceMYOS() * quantity }("");
      if (sent == false)
        revert SellMyosSendEth({
          to: _msgSender(),
          value: getDynamicPriceMYOS() * quantity
        });
    }
    MYOS(addressMYOSToken).burn(
      _msgSender(),
      quantity * (10 ** uint256(MYOS(addressMYOSToken).decimals()))
    );
  }

  ///@notice Converting the MYOS to another token
  ///@param quantity number of token myos you want convert
  ///@param anotherToken address of token you want to convert
  function convertMYOSToAnotherToken(uint256 quantity, address anotherToken) external {
    /*require(totalSupply()>quantity+1,"No more this token");
        require(balanceOf(_msgSender())>=quantity,"No more this token");
        _burn(_msgSender(),quantity);
        currentprice = getDynamicPriceMYOS();*/
  }

  ///@notice Verify proof of a claimer to mint in a whitelist
  ///@param _claimer _msgSender() address wallet of user he want mint token MYOS
  ///@param _proofs array of bytes 32 represent proof of merkle with merkle tree
  ///@param _proofMaxQuantityPerTransaction useless for us but need it, its for add quantity into merkle tree
  function verifyMerkleProof(
    address _claimer,
    bytes32[] calldata _proofs,
    uint256 _proofMaxQuantityPerTransaction
  ) internal view returns (bool validMerkleProof, uint256 merkleProofIndex) {
    if (
      merkleRoot != bytes32(0) && merkleEndTime < block.timestamp && merkleEndTime != 0
    ) {
      (validMerkleProof, merkleProofIndex) = MerkleProofLib.verify(
        _proofs,
        merkleRoot,
        keccak256(abi.encodePacked(_claimer, _proofMaxQuantityPerTransaction))
      );
    }
  }

  ///@notice Function to calculate dynamic price
  function getDynamicPriceMYOS() public view returns (uint256) {
    return address(this).balance / MYOS(addressMYOSToken).totalSupply();
  }

  ///@notice Function to return static price
  function getCurrentpriceMYOS() external view returns (uint256) {
    return currentpriceMYOS;
  }
}
