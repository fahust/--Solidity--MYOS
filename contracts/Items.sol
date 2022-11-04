// SPDX-License-Identifier: MIT
// Items Contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
Premier token d'inventaire, disons la money
 */
contract Items is ERC20, Ownable {
  address addressDelegateContract;
  uint256 rarity; //0 a 99 999, plus il est haut, moin on a de chance de l'obtenir
  uint256 pricebase;
  uint256 currentprice;

  struct Item {
    string name;
    uint256 rarity;
    uint256 currentPrice;
    uint256 myBalance;
    uint256 allBalance;
  }

  constructor(
    uint256 _supply,
    string memory name,
    string memory symbol
  ) ERC20(name, symbol) {}

  ///@notice Very important function that we add on almost all the other functions to check that the call of the functions is done well from the delegation contract for more security
  modifier byDelegate() {
    require(
      (_msgSender() == addressDelegateContract || addressDelegateContract == address(0)),
      "Not good delegate contract"
    );
    _;
  }

  ///@notice modify the address of the delegation contract to allow the said contract to interact with this one
  ///@param _address new address of delegation contract
  function setaddressDelegateContract(address _address) external onlyOwner {
    addressDelegateContract = _address;
  }

  ///@notice Function of mint token
  ///@param quantity mint a guantity of item
  ///@param to address of receiver's item
  function mint(uint256 quantity, address to) external payable byDelegate {
    _mint(to, quantity);
  }

  ///@notice Function of burn token
  ///@param quantity mint a guantity of item
  ///@param to address of burner's item
  function burn(uint8 number, address to) external byDelegate {
    _burn(to, number);
  }

  ///@notice Set price param for an item
  ///@param price base price of item in wei
  function setPrice(uint256 price) external onlyOwner {
    pricebase = price;
  }

  ///@notice Get price param for an item
  function getPrice() external view returns (uint256) {
    return pricebase;
  }

  ///@notice Set rarity param for an item
  ///@param rare base rarity of item
  function setRarity(uint256 rare) external onlyOwner {
    rarity = rare;
  }

  ///@notice Get rarity param for an item
  function getRarity() public view returns (uint256) {
    return rarity;
  }

  ///@notice Get name param for an item
  function getName() internal view returns (string memory) {
    return name();
  }

  ///@notice Get item structure detail
  ///@param myAddress address for return balance sender of this item
  function getItemDetails(address myAddress) external view returns (Item memory) {
    return
      Item(
        getName(),
        getRarity(),
        getCurrentPrice(),
        balanceOf(myAddress),
        address(this).balance
      );
  }

  /*ECONOMY*/

  ///@notice purchase of a resource for eth/MATIC
  ///@param quantity count of item you want purchase
  ///@param receiver receiver address of token
  function buyItem(uint256 quantity, address receiver) external payable {
    require(msg.value >= currentprice * quantity, "More ETH required");
    _mint(receiver, quantity);
    setCurrentPrice();
  }

  ///@notice sell of a resource for eth/MATIC
  ///@param quantity count of item you want purchase
  ///@param receiver receiver address of token
  function sellItem(uint256 quantity, address receiver) external {
    require(totalSupply() > quantity + 1, "No more this token");
    require(balanceOf(receiver) >= quantity, "No more this token");
    payable(receiver).transfer(currentprice * quantity);
    _burn(receiver, quantity);
    setCurrentPrice();
  }

  ///@notice convert of a resource for another token
  function convertToAnotherToken(uint256 value, address anotherToken) external {
    /*require(totalSupply()>value+1,"No more this token");
        require(balanceOf(_msgSender())>=value,"No more this token");
        _burn(_msgSender(),value);
        currentprice = setCurrentPrice();*/
  }

  ///@notice Actualize dynamic price
  function setCurrentPrice() public {
    currentprice = address(this).balance / totalSupply();
  }

  ///@notice Get dynamic price
  function getCurrentPrice() public view returns (uint256) {
    return address(this).balance / totalSupply();
  }

  function withdraw() external onlyOwner {
    payable(_msgSender()).transfer(address(this).balance);
    setCurrentPrice();
  }
}
