// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

interface IDelegateContractMyos {
  ///@notice Update price of MYOS token for static price, if == 0 change for dynamic price
  ///@param newPrice value of price in matic wei (matic / 10**18)
  function setCurrentPriceMYOS(uint256 newPrice) external;

  ///@notice Update the destination address of the official contract MYOS token so that the delegation contract can access it
  ///@param _addressMYOSToken address of contract MYOS
  function setAddressMYOSToken(address _addressMYOSToken) external;

  ///@notice Set the merkle tree to create whitelist for mint
  ///@param _merkleRoot A bytes 32 represent root of tree for verify all merkle proof
  ///@param _merkleEndTime Represent a timestamp (in seconds) represents end of whitelist
  function setMerkleTree(bytes32 _merkleRoot, uint256 _merkleEndTime) external;

  ///@notice Purchase of a resource for eth/MATIC
  ///@param quantity number of token myos you want purchase
  ///@param receiver address waller of receiver's token
  function buyMYOS(
    uint256 quantity,
    address receiver,
    bytes32[] calldata _proofs,
    uint256 _proofMaxQuantityPerTransaction
  ) external payable;

  ///@notice Sale of MYOS token against MATIC
  ///@param quantity number of token myos you want sell
  function sellMYOS(uint256 quantity) external;

  ///@notice Converting the MYOS to another token
  ///@param quantity number of token myos you want convert
  ///@param anotherToken address of token you want to convert
  function convertMYOSToAnotherToken(uint256 quantity, address anotherToken) external;

  ///@notice Function to calculate dynamic price
  function getDynamicPriceMYOS() external view returns (uint256);
}
