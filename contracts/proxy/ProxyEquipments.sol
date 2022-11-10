// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../immutable/Equipments.sol";
import "../immutable/Items.sol";

import "../library/LItems.sol";

contract ProxyEquipments is Ownable, ReentrancyGuard {
  using SafeMath for uint;
  error NotEnoughEth(uint256 price, uint256 weiSended, uint256 tokenId, uint256 quantity);
  error NoMoreSupplyToken(uint256 supply, uint256 quantity, uint256 tokenId);
  error NoMoreBalanceToken(
    uint256 balance,
    address sender,
    uint256 quantity,
    uint256 tokenId
  );
  error ZeroQuantityConvertAvailable(
    uint256 balance,
    address sender,
    uint256 quantity,
    uint256 tokenId
  );
  error SellEquipmentSendEth(address to, uint value);
  error NotEnoughBalance(uint256 balance, uint256 itemIdQuantity, uint256 itemIdCraft);

  address private addressEquipment;
  address private addressItem;

  uint256 private constant utilMathMultiply = 10000000;

  constructor(address _addressEquipment, address _addressItem) {
    addressEquipment = _addressEquipment;
    addressItem = _addressItem;
  }

  function craft(uint256 tokenId, address receiver) external {
    Equipments equipmentContrat = Equipments(addressEquipment);
    Items itemContrat = Items(addressItem);

    EquipmentsLib.Equipment memory equipment = equipmentContrat.getEquipmentDetails(
      tokenId
    );

    for (uint256 index = 0; index < equipment.itemsIdsCraft.length; index++) {
      uint256 itemIdCraft = equipment.itemsIdsCraft[index];
      uint256 itemIdQuantity = equipment.itemsIdsCraft[index];

      if (itemContrat.balanceOf(_msgSender(), itemIdCraft) < itemIdQuantity)
        revert NotEnoughBalance({
          balance: itemContrat.balanceOf(_msgSender(), itemIdCraft),
          itemIdQuantity: itemIdQuantity,
          itemIdCraft: itemIdCraft
        });
    }

    equipmentContrat.mint(receiver, tokenId, 1);
  }

  function putInSell() external {}

  function purchase() external {}

  ///@notice purchase of a resource for eth/MATIC
  ///@param quantity count of equipment you want purchase
  ///@param receiver receiver address of token
  ///@param tokenId id of equipment
  function buyEquipment(
    uint256 quantity,
    address receiver,
    uint256 tokenId
  ) external payable {
    Equipments equipmentContrat = Equipments(addressEquipment);
    EquipmentsLib.Equipment memory equipment = equipmentContrat.getEquipmentDetails(
      tokenId
    );
    if (msg.value < equipment.price * quantity)
      revert NotEnoughEth({
        price: equipment.price * quantity,
        weiSended: msg.value,
        tokenId: tokenId,
        quantity: quantity
      });
    equipmentContrat.mint(receiver, tokenId, quantity);
    //setCurrentPrice();
  }

  ///@notice sell of a resource for eth/MATIC
  ///@param quantity count of equipment you want purchase
  ///@param tokenId id of equipment
  function sellEquipment(uint256 quantity, uint256 tokenId) external {
    Equipments equipmentContrat = Equipments(addressEquipment);
    EquipmentsLib.Equipment memory equipment = equipmentContrat.getEquipmentDetails(
      tokenId
    );
    if (equipmentContrat.getSupply(tokenId) < quantity)
      revert NoMoreSupplyToken({
        supply: equipmentContrat.getSupply(tokenId),
        quantity: quantity,
        tokenId: tokenId
      });
    if (equipmentContrat.balanceOf(_msgSender(), tokenId) < quantity)
      revert NoMoreBalanceToken({
        balance: equipmentContrat.balanceOf(_msgSender(), tokenId),
        sender: _msgSender(),
        quantity: quantity,
        tokenId: tokenId
      });

    equipmentContrat.burn(_msgSender(), tokenId, quantity);
    (bool sent, ) = _msgSender().call{ value: equipment.price * quantity }("");
    if (sent == false)
      revert SellEquipmentSendEth({
        to: _msgSender(),
        value: equipment.price * quantity
      });
    //payable(_msgSender()).transfer(equipment.price * quantity);
    //setCurrentPrice();
  }

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
  ) external nonReentrant {
    Equipments equipmentContrat = Equipments(addressEquipment);
    EquipmentsLib.Equipment memory fromEquipment = equipmentContrat.getEquipmentDetails(
      fromTokenId
    );
    EquipmentsLib.Equipment memory toEquipment = equipmentContrat.getEquipmentDetails(
      toTokenId
    );

    if (equipmentContrat.getSupply(fromTokenId) < quantity)
      revert NoMoreSupplyToken({
        supply: equipmentContrat.getSupply(fromTokenId),
        quantity: quantity,
        tokenId: fromTokenId
      });

    if (equipmentContrat.balanceOf(_msgSender(), fromTokenId) < quantity)
      revert NoMoreBalanceToken({
        balance: equipmentContrat.balanceOf(_msgSender(), fromTokenId),
        sender: _msgSender(),
        quantity: quantity,
        tokenId: fromTokenId
      });

    uint256 toQuantityAvailable = calculConversionQuantity(
      fromEquipment.price,
      toEquipment.price,
      quantity
    );

    if (toQuantityAvailable <= 0)
      revert ZeroQuantityConvertAvailable({
        balance: equipmentContrat.balanceOf(_msgSender(), fromTokenId),
        sender: _msgSender(),
        quantity: quantity,
        tokenId: toTokenId
      });

    equipmentContrat.burn(_msgSender(), fromTokenId, quantity);
    equipmentContrat.mint(receiver, toTokenId, toQuantityAvailable);
    //currentprice = setCurrentPrice();
  }

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
  ) external nonReentrant {
    Equipments equipmentContrat = Equipments(addressEquipment);
    EquipmentsLib.Equipment memory fromEquipment = equipmentContrat.getEquipmentDetails(
      fromTokenId
    );
    EquipmentsLib.Equipment memory toEquipment = equipmentContrat.getEquipmentDetails(
      toTokenId
    );

    if (equipmentContrat.getSupply(fromTokenId) < quantity)
      revert NoMoreSupplyToken({
        supply: equipmentContrat.getSupply(fromTokenId),
        quantity: quantity,
        tokenId: fromTokenId
      });

    if (equipmentContrat.balanceOf(_msgSender(), fromTokenId) < quantity)
      revert NoMoreBalanceToken({
        balance: equipmentContrat.balanceOf(_msgSender(), fromTokenId),
        sender: _msgSender(),
        quantity: quantity,
        tokenId: fromTokenId
      });

    uint256 toQuantityAvailable = calculConversionQuantity(
      fromEquipment.price,
      toEquipment.price,
      quantity
    );

    if (toQuantityAvailable <= 0)
      revert ZeroQuantityConvertAvailable({
        balance: equipmentContrat.balanceOf(_msgSender(), fromTokenId),
        sender: _msgSender(),
        quantity: quantity,
        tokenId: toTokenId
      });

    equipmentContrat.burn(_msgSender(), fromTokenId, quantity);
    equipmentContrat.mint(receiver, toTokenId, toQuantityAvailable);
    //currentprice = setCurrentPrice();
  }*/

  /*FUNDS OF CONTRACT*/

  function withdraw() external onlyOwner {
    payable(_msgSender()).transfer(address(this).balance);
  }

  function calculConversionQuantity(
    uint firstTokenPrice,
    uint twoTokenPrice,
    uint quantity
  ) public pure returns (uint256) {
    return
      firstTokenPrice.mul(utilMathMultiply).div(twoTokenPrice).mul(quantity).div(
        utilMathMultiply
      );
  }
}
