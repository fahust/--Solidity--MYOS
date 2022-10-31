// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MerkleProof.sol";
import "./MYOS.sol";

contract DelegateContractMYOS is Ownable {
  address addressMYOSToken;
  uint256 currentpriceMYOS;
  uint256 merkleEndTime;
  bytes32 merkleRoot;

  ///@notice Update price of MYOS token for static price, if == 0 change for dynamic price
  ///@param newPrice value of price in matic wei (matic / 10**18)
  function setCurrentPriceMYOS(uint256 newPrice) external onlyOwner {
    currentpriceMYOS = newPrice;
  }

  function setAddressMYOSToken(address _addressMYOSToken) external onlyOwner {
    addressMYOSToken = _addressMYOSToken;
  }

  ///@notice Set the merkle tree to create whitelist for mint
  ///@param _merkleRoot A bytes 32 represent root of tree for verify all merkle proof
  ///@param _merkleEndTime Represent a timestamp (in seconds) represents end of whitelist
  function setMerkleTree(bytes32 _merkleRoot, uint256 _merkleEndTime) external onlyOwner {
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
  ) external payable {
    verifyMerkleProof(msg.sender, _proofs, _proofMaxQuantityPerTransaction);
    if (currentpriceMYOS != 0)
      require(msg.value >= (currentpriceMYOS * quantity), "More ETH required");
    if (currentpriceMYOS == 0)
      require(msg.value >= (getDynamicPriceMYOS() * quantity), "More ETH required");
    (bool sent, bytes memory data) = addressMYOSToken.call{ value: msg.value }("");
    MYOS(addressMYOSToken).mint(
      receiver,
      quantity * (10**uint256(MYOS(addressMYOSToken).decimals()))
    );
  }

  ///@notice Sale of MYOS token against MATIC
  ///@param quantity number of token myos you want sell
  function sellMYOS(uint256 quantity) public {
    require(MYOS(addressMYOSToken).totalSupply() > quantity + 1, "No more this token");
    require(
      MYOS(addressMYOSToken).balanceOf(msg.sender) >=
        quantity * (10**uint256(MYOS(addressMYOSToken).decimals())),
      "No more this token"
    );
    if (currentpriceMYOS != 0) payable(msg.sender).transfer(currentpriceMYOS * quantity);
    if (currentpriceMYOS == 0)
      payable(msg.sender).transfer(getDynamicPriceMYOS() * quantity);
    MYOS(addressMYOSToken).burn(
      msg.sender,
      quantity * (10**uint256(MYOS(addressMYOSToken).decimals()))
    );
  }

  ///@notice Converting the MYOS to another token
  ///@param quantity number of token myos you want convert
  ///@param anotherToken address of token you want to convert
  function convertMYOSToAnotherToken(uint256 quantity, address anotherToken) public {
    /*require(totalSupply()>quantity+1,"No more this token");
        require(balanceOf(msg.sender)>=quantity,"No more this token");
        _burn(msg.sender,quantity);
        currentprice = getDynamicPriceMYOS();*/
  }

  ///@notice Verify proof of a claimer to mint in a whitelist
  ///@param _claimer msg.sender address wallet of user he want mint token MYOS
  ///@param _proofs array of bytes 32 represent proof of merkle with merkle tree
  ///@param _proofMaxQuantityPerTransaction useless for us but need it, its for add quantity into merkle tree
  function verifyMerkleProof(
    address _claimer,
    bytes32[] calldata _proofs,
    uint256 _proofMaxQuantityPerTransaction
  ) public view returns (bool validMerkleProof, uint256 merkleProofIndex) {
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
    return
      MYOS(addressMYOSToken).getBalanceContract() / MYOS(addressMYOSToken).totalSupply();
  }
}
