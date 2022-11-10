// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../immutable/Items.sol";

import "../interfaces/IProxyItems.sol";

import "../library/LItems.sol";

contract ProxyItems is Ownable, ReentrancyGuard, IProxyItems {
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
  error SellItemSendEth(address to, uint value);

  address private addressItem;

  uint256 private constant utilMathMultiply = 10000000;

  constructor(
    address _addressItem
  ) {
    addressItem = _addressItem;
  }

  ///@notice purchase of a resource for eth/MATIC
  ///@param quantity count of item you want purchase
  ///@param receiver receiver address of token
  ///@param tokenId id of item
  function buyItem(
    uint256 quantity,
    address receiver,
    uint256 tokenId
  ) external payable {
    Items itemContrat = Items(addressItem);
    ItemsLib.Item memory item = itemContrat.getItemDetails(tokenId);
    if (msg.value < item.price * quantity)
      revert NotEnoughEth({
        price: item.price * quantity,
        weiSended: msg.value,
        tokenId: tokenId,
        quantity: quantity
      });
    itemContrat.mint(receiver, tokenId, quantity);
    //setCurrentPrice();
  }

  ///@notice sell of a resource for eth/MATIC
  ///@param quantity count of item you want purchase
  ///@param tokenId id of item
  function sellItem(uint256 quantity, uint256 tokenId) external {
    Items itemContrat = Items(addressItem);
    ItemsLib.Item memory item = itemContrat.getItemDetails(tokenId);
    if (itemContrat.getSupply(tokenId) < quantity)
      revert NoMoreSupplyToken({
        supply: itemContrat.getSupply(tokenId),
        quantity: quantity,
        tokenId: tokenId
      });
    if (itemContrat.balanceOf(_msgSender(), tokenId) < quantity)
      revert NoMoreBalanceToken({
        balance: itemContrat.balanceOf(_msgSender(), tokenId),
        sender: _msgSender(),
        quantity: quantity,
        tokenId: tokenId
      });

    itemContrat.burn(_msgSender(), tokenId, quantity);
    (bool sent, ) = _msgSender().call{ value: item.price * quantity }("");
    if (sent == false)
      revert SellItemSendEth({ to: _msgSender(), value: item.price * quantity });
    //payable(_msgSender()).transfer(item.price * quantity);
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
    Items itemContrat = Items(addressItem);
    ItemsLib.Item memory fromItem = itemContrat.getItemDetails(fromTokenId);
    ItemsLib.Item memory toItem = itemContrat.getItemDetails(toTokenId);

    if (itemContrat.getSupply(fromTokenId) < quantity)
      revert NoMoreSupplyToken({
        supply: itemContrat.getSupply(fromTokenId),
        quantity: quantity,
        tokenId: fromTokenId
      });

    if (itemContrat.balanceOf(_msgSender(), fromTokenId) < quantity)
      revert NoMoreBalanceToken({
        balance: itemContrat.balanceOf(_msgSender(), fromTokenId),
        sender: _msgSender(),
        quantity: quantity,
        tokenId: fromTokenId
      });

    uint256 toQuantityAvailable = calculConversionQuantity(
      fromItem.price,
      toItem.price,
      quantity
    );

    if (toQuantityAvailable <= 0)
      revert ZeroQuantityConvertAvailable({
        balance: itemContrat.balanceOf(_msgSender(), fromTokenId),
        sender: _msgSender(),
        quantity: quantity,
        tokenId: toTokenId
      });

    itemContrat.burn(_msgSender(), fromTokenId, quantity);
    itemContrat.mint(receiver, toTokenId, toQuantityAvailable);
    //currentprice = setCurrentPrice();
  }

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
