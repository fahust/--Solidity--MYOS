// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

import "../library/LItems.sol";

interface IProxyEquipments {
  function craft(uint256 tokenId, address receiver) external;

  function putInSell() external;

  function purchase() external;

  ///@notice purchase of a resource for eth/MATIC
  ///@param quantity count of equipment you want purchase
  ///@param receiver receiver address of token
  ///@param tokenId id of equipment
  function buyEquipment(
    uint256 quantity,
    address receiver,
    uint256 tokenId
  ) external payable;

  ///@notice sell of a resource for eth/MATIC
  ///@param quantity count of equipment you want purchase
  ///@param tokenId id of equipment
  function sellEquipment(uint256 quantity, uint256 tokenId) external;

  ///@notice convert of a resource for another token
  ///@param receiver address of receiver toToken minted
  ///@param quantity quantity of fromToken burned for same quantity burned
  ///@param fromTokenId id of token burned
  ///@param toTokenId if of token minted
  function convertToAnotherToken(
    address receiver,
    uint256 quantity,
    uint256 fromTokenId,
    uint256 toTokenId
  ) external;

  /*
  ///@notice convert of a resource for another item
  ///@param receiver address of receiver toToken minted
  ///@param quantity quantity of fromToken burned for same quantity burned
  ///@param fromTokenId id of token burned
  ///@param toTokenId if of token minted
  function convertToAnotherItem(
    address receiver,
    uint256 quantity,
    uint256 fromTokenId,
    uint256 toTokenId
  ) external;*/

  function withdraw() external;

  function calculConversionQuantity(
    uint firstTokenPrice,
    uint twoTokenPrice,
    uint quantity
  ) external pure returns (uint256);
}
