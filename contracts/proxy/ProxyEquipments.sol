// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

import "../immutable/Equipments.sol";
import "../immutable/Items.sol";

import "../library/LItems.sol";
import "../library/LEquipments.sol";

contract ProxyEquipments is Ownable, ReentrancyGuard, IERC1155Receiver, AccessControlEnumerable {
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
  error AlreadyOwned(uint256 tokenId, address sender, address owner);
  error NotEnoughEthPurchase(uint256 tokenId, uint256 price, uint256 value);
  error NotGoodTokenId(uint256 tokenId, address sender, uint256 tokenIdInStructure);
  error EquipmentNotInSales(uint256 tokenId, uint256 price);
  error NotYourToken(uint256 tokenId, address sender, address owner);

  event craftedItem(address indexed sender, uint256 indexed tokenId, address receiver);
  event puttedInSell(address indexed sender, uint256 indexed tokenId, uint256 price);
  event cancelledInSell(address indexed sender, uint256 indexed tokenId);
  event purchasedInSell(address indexed sender, uint256 id, uint256 indexed tokenId, address indexed receiver);
  event buyedEquipment(address indexed sender, uint256 quantity, uint256 indexed tokenId, address indexed receiver);
  event selledEquipment(address indexed sender, uint256 quantity, uint256 indexed tokenId);
  event convertedToAnotherToken(address indexed sender, uint256 quantity, uint256 indexed fromTokenId, uint256 indexed toTokenId, address receiver);

  address private addressEquipment;
  address private addressItem;

  uint256 private constant utilMathMultiply = 10000000;

  mapping(uint256 => EquipmentsLib.EquipmentInSell) public equipmentsInSell;
  uint256 countEquipmentsInSell;

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
      uint256 itemIdQuantity = equipment.itemsQuantitiesCraft[index];

      if (itemContrat.balanceOf(_msgSender(), itemIdCraft) < itemIdQuantity)
        revert NotEnoughBalance({
          balance: itemContrat.balanceOf(_msgSender(), itemIdCraft),
          itemIdQuantity: itemIdQuantity,
          itemIdCraft: itemIdCraft
        });
      itemContrat.burn(_msgSender(), itemIdCraft, itemIdQuantity);
    }

    equipmentContrat.mint(receiver, tokenId, 1);
    emit craftedItem(_msgSender(),tokenId, receiver);
  }

  ///@notice put equipment in sell market
  ///@param tokenId id key of token you want to putt in sell
  ///@param price price of token put in selled
  function putInSell(uint256 tokenId, uint256 price) external {
    Equipments equipmentContrat = Equipments(addressEquipment);
    if (equipmentContrat.balanceOf(_msgSender(), tokenId) < 1)
      revert NoMoreBalanceToken({
        balance: equipmentContrat.balanceOf(_msgSender(), tokenId),
        sender: _msgSender(),
        quantity: 1,
        tokenId: tokenId
      });
    equipmentsInSell[countEquipmentsInSell] = EquipmentsLib.EquipmentInSell(
      tokenId,
      price,
      _msgSender()
    );
    countEquipmentsInSell++;
    equipmentContrat.safeTransferFrom(_msgSender(), address(this), tokenId, 1, "");
    emit puttedInSell(_msgSender(), tokenId, price);
  }

  ///@notice cancel equipment in sell market
  ///@param id id of key array of equipmentsInSell mapping you want cancel
  function cancelInSell(uint256 id) external {
    Equipments equipmentContrat = Equipments(addressEquipment);
    address owner = equipmentsInSell[id].owner;
    uint256 tokenId = equipmentsInSell[id].tokenId;
    if (owner != _msgSender())
      revert NotYourToken({ tokenId: tokenId, sender: _msgSender(), owner: owner });
    delete equipmentsInSell[id];
    equipmentContrat.safeTransferFrom(address(this), _msgSender(), tokenId, 1, "");
    emit cancelledInSell(_msgSender(), tokenId);
  }

  //function stopSell()

  ///@notice return all equipment in sell in market sell
  ///@return tokens return array structure of equipment
  function getInSell() external view returns (EquipmentsLib.EquipmentInSell[] memory) {
    EquipmentsLib.EquipmentInSell[] memory result = new EquipmentsLib.EquipmentInSell[](
      countEquipmentsInSell
    );
    for (uint256 i = 0; i < countEquipmentsInSell; i++) {
      EquipmentsLib.EquipmentInSell memory equipment = equipmentsInSell[i];
      result[i] = equipment;
    }
    return result;
  }

  ///@notice purchase a token previously put in sell
  ///@param id id of key array of equipmentsInSell mapping you want buy
  ///@param tokenId id key of token you want to buy
  function purchase(uint256 id, uint256 tokenId, address receiver) external payable {
    Equipments equipmentContrat = Equipments(addressEquipment);

    uint256 price = equipmentsInSell[id].price;
    address owner = equipmentsInSell[id].owner;

    if (price <= 0) revert EquipmentNotInSales({ tokenId: tokenId, price: price });
    if (msg.value < price)
      revert NotEnoughEthPurchase({ tokenId: tokenId, price: price, value: msg.value });
    if (owner == _msgSender())
      revert AlreadyOwned({ tokenId: tokenId, sender: _msgSender(), owner: owner });
    if (equipmentsInSell[id].tokenId != tokenId)
      revert NotGoodTokenId({
        tokenId: tokenId,
        sender: _msgSender(),
        tokenIdInStructure: equipmentsInSell[id].tokenId
      });

    equipmentsInSell[id].price = 0;
    equipmentsInSell[id].owner = address(0);

    equipmentContrat.safeTransferFrom(address(this), receiver, tokenId, 1, "");

    (bool sent, ) = owner.call{ value: price }("");
    if (sent == false) revert SellEquipmentSendEth({ to: owner, value: price });
    emit purchasedInSell(_msgSender(), id, tokenId, receiver);
  }

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
    emit buyedEquipment(_msgSender(), quantity, tokenId, receiver);
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
    emit selledEquipment(_msgSender(), quantity, tokenId);
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
    emit convertedToAnotherToken(_msgSender(), quantity, fromTokenId, toTokenId, receiver);
    //currentprice = setCurrentPrice();
  }

  /*
  ///@notice convert of a resource to item
  ///@param receiver address of receiver toToken minted
  ///@param quantity quantity of fromToken burned for same quantity burned
  ///@param fromTokenId id of token burned
  ///@param toTokenId if of token minted
  function convertToItem(
    address receiver,
    uint256 quantity,
    uint256 fromTokenId,
    uint256 toTokenId
  ) external nonReentrant {}*/

  /*FUNDS OF CONTRACT*/

  ///@notice Withdraw funds of this contract to an address wallet
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

  function onERC1155Received(
    address,
    address,
    uint256,
    uint256,
    bytes memory
  ) public virtual override returns (bytes4) {
    return this.onERC1155Received.selector;
  }

  function onERC1155BatchReceived(
    address,
    address,
    uint256[] memory,
    uint256[] memory,
    bytes memory
  ) public virtual override returns (bytes4) {
    return this.onERC1155BatchReceived.selector;
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(AccessControlEnumerable, IERC165)
    returns (bool)
  {
    return
      interfaceId == type(IERC1155Receiver).interfaceId ||
      super.supportsInterface(interfaceId);
  }
}
