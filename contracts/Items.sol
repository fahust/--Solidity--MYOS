// SPDX-License-Identifier: MIT
// Items Contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/**
Premier token d'inventaire, disons la money
 */
contract Items is ERC1155, Ownable {
  address addressDelegateContract;
  uint256 rarity; //0 a 99 999, plus il est haut, moin on a de chance de l'obtenir
  uint256 pricebase;
  uint256 currentprice;
  uint256 itemCount;
  mapping(uint256 => uint256) supplies;
  mapping(uint256 => Item) items;

  struct Item {
    string name;
    uint256 rarity;
    uint256 price;
    bool valid;
  }

  constructor(string memory baseUri) ERC1155(baseUri) {}

  ///@notice Very important function that we add on almost all the other functions to check that the call of the functions is done well from the delegation contract for more security
  modifier byDelegate() {
    require(
      (_msgSender() == addressDelegateContract || addressDelegateContract == address(0)),
      "Not good delegate contract"
    );
    _;
  }

  ///@notice create or update quest
  ///@param name name of item
  ///@param rarity rarity to loot this item
  ///@param price price of item in wei
  ///@param id id of item you want to set
  function setItem(
    string memory name,
    uint256 rarity,
    uint256 price,
    uint256 id
  ) external onlyOwner {
    if (items[id].valid == false) itemCount++;
    items[id] = Item(name, rarity, price, true);
  }

  function getSupply(uint256 tokenId) external view returns (uint256) {
    return supplies[tokenId];
  }

  ///@notice modify the address of the delegation contract to allow the said contract to interact with this one
  ///@param _address new address of delegation contract
  function setaddressDelegateContract(address _address) external onlyOwner {
    addressDelegateContract = _address;
  }

  ///@notice Function of mint token
  ///@param to address of receiver's item
  ///@param tokenId token id you want to mint
  ///@param amount mint a quantity of item
  function mint(
    address to,
    uint256 tokenId,
    uint256 amount
  ) external payable byDelegate {
    supplies[tokenId] += amount;
    _mint(to, tokenId, amount, "");
  }

  ///@notice Function of burn token
  ///@param to address of burner's item
  ///@param tokenId token id you want to burn
  ///@param amount mint a quantity of item
  function burn(
    address to,
    uint256 tokenId,
    uint256 amount
  ) external byDelegate {
    supplies[tokenId] -= amount;
    _burn(to, tokenId, amount);
  }

  ///@notice Get item structure detail
  ///@param myAddress address for return balance sender of this item
  ///@param tokenId token id you want to return
  ///@return item stucture Item attached to tokenId
  function getItemDetails(address myAddress, uint256 tokenId)
    external
    view
    returns (Item memory)
  {
    return items[tokenId];
  }

  /*
  ///@notice Actualize dynamic price
  function setCurrentPrice(uint256 tokenId) public {
    currentprice = address(this).balance / supplies[tokenId];
  }

  ///@notice Get dynamic price
  function getCurrentPrice(uint256 tokenId) public view returns (uint256) {
    return address(this).balance / supplies[tokenId];
  }*/
}
