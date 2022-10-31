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

  /**
    Foncton très importante que l'ont rajoute sur presque toutes les autres fonctions pour vérifier que l'appel des fonctions ce fais bien depuis le contrat de délégation pour plus de sécuriter
    */
  modifier byDelegate() {
    require(
      (msg.sender == addressDelegateContract || addressDelegateContract == address(0)),
      "Not good delegate contract"
    );
    _;
  }

  /** 
    modifier l'addresse du contrat de délégation pour permettre aux dit contrat d'intéragir avec celui ci
     */
  function setaddressDelegateContract(address _address) external onlyOwner {
    addressDelegateContract = _address;
  }

  function mint(uint256 number, address to) external payable byDelegate {
    _mint(to, number);
  }

  function burn(uint8 number, address to) external byDelegate {
    _burn(to, number);
  }

  function setPrice(uint256 price) external onlyOwner {
    pricebase = price;
  }

  function getPrice() external view returns (uint256) {
    return pricebase;
  }

  function setRarity(uint256 rare) external onlyOwner {
    rarity = rare;
  }

  function getRarity() public view returns (uint256) {
    return rarity;
  }

  function getBalanceContract() internal view returns (uint256) {
    return address(this).balance;
  }

  function getName() internal view returns (string memory) {
    return name();
  }

  function getItemDetails(address myAddress) external view returns (Item memory) {
    return
      Item(
        getName(),
        getRarity(),
        getCurrentPrice(),
        balanceOf(myAddress),
        getBalanceContract()
      );
  }

  /*ECONOMY*/

  /**
    achat d'une ressource contre de l'eth/MATIC
     */
  function buyItem(uint256 quantity, address sender) external payable {
    require(msg.value >= currentprice * quantity, "More ETH required");
    _mint(sender, quantity);
    setCurrentPrice();
  }

  /**
    Vente du jeton contre de l'eth/MATIC
     */
  function sellItem(uint256 quantity, address sender) external {
    require(totalSupply() > quantity + 1, "No more this token");
    require(balanceOf(sender) >= quantity, "No more this token");
    payable(sender).transfer(currentprice * quantity);
    _burn(sender, quantity);
    setCurrentPrice();
  }

  /**
    Vente du jeton contre de l'eth/MATIC
     */
  function convertToAnotherToken(uint256 value, address anotherToken) external {
    /*require(totalSupply()>value+1,"No more this token");
        require(balanceOf(msg.sender)>=value,"No more this token");
        _burn(msg.sender,value);
        currentprice = setCurrentPrice();*/
  }

  function setCurrentPrice() public {
    currentprice = address(this).balance / totalSupply();
  }

  function getCurrentPrice() public view returns (uint256) {
    return address(this).balance / totalSupply();
  }

  /*FUNDS OF CONTRACT*/

  function withdraw() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
    setCurrentPrice();
  }

  function deposit() external payable {
    setCurrentPrice();
  }

  function getBalance() external view returns (uint256) {
    return address(this).balance;
  }

  //receive() external payable {}
}
