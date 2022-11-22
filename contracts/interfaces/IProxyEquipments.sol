// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

import "../library/LEquipments.sol";

interface IProxyEquipments {
  function craft(uint256 tokenId, address receiver) external;

  ///@notice put equipment in sell market
  ///@param tokenId id key of token you want to putt in sell
  ///@param price price of token put in selled
  function putInSell(uint256 tokenId, uint256 price) external;

  ///@notice cancel equipment in sell market
  ///@param id id of key array of equipmentsInSell mapping you want cancel
  function cancelInSell(uint256 id) external;

  //function stopSell()

  ///@notice return all equipment in sell in market sell
  ///@return tokens return array structure of equipment
  function getInSell() external view returns (EquipmentsLib.EquipmentInSell[] memory);

  ///@notice purchase a token previously put in sell
  ///@param id id of key array of equipmentsInSell mapping you want buy
  ///@param tokenId id key of token you want to buy
  function purchase(uint256 id, uint256 tokenId, address receiver) external payable;

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
