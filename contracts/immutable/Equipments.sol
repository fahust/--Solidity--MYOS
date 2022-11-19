// SPDX-License-Identifier: MIT
// Equipments Contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import "../library/LEquipments.sol";

contract Equipments is ERC1155, Ownable {
  address addressProxyContract;
  uint256 equipmentCount;
  mapping(uint256 => uint256) supplies;
  mapping(uint256 => EquipmentsLib.Equipment) equipments;

  constructor(string memory baseUri) ERC1155(baseUri) {}

  ///@notice Very important function that we add on almost all the other functions to check that the call of the functions is done well from the delegation contract for more security
  modifier byProxy() {
    require(
      (_msgSender() == addressProxyContract || addressProxyContract == address(0)),
      "Not good Proxy contract"
    );
    _;
  }

  ///@notice create or update item
  ///@param name name of equipment
  ///@param rarity rarity to loot this equipment
  ///@param price price of equipment in wei
  ///@param id id of equipment you want to set
  function setEquipment(
    string calldata name,
    uint256 rarity,
    uint256 price,
    uint256[] calldata itemsIdsCraft,
    uint256[] calldata itemsQuantitiesCraft,
    uint256 id
  ) external onlyOwner {
    require(itemsIdsCraft.length == itemsQuantitiesCraft.length, "not good array length");

    if (equipments[id].valid == false) {
      unchecked {
        equipmentCount++;
      }
    }
    equipments[id] = EquipmentsLib.Equipment(
      name,
      rarity,
      price,
      itemsIdsCraft,
      itemsQuantitiesCraft,
      true
    );
  }

  function getSupply(uint256 tokenId) external view returns (uint256) {
    return supplies[tokenId];
  }

  ///@notice modify the address of the delegation contract to allow the said contract to interact with this one
  ///@param _address new address of delegation contract
  function setaddressProxyContract(address _address) external onlyOwner {
    addressProxyContract = _address;
  }

  ///@notice Function of mint token
  ///@param to address of receiver's equipment
  ///@param tokenId token id you want to mint
  ///@param amount mint a quantity of equipment
  function mint(address to, uint256 tokenId, uint256 amount) external payable byProxy {
    supplies[tokenId] += amount;
    _mint(to, tokenId, amount, "");
  }

  ///@notice Function of burn token
  ///@param to address of burner's equipment
  ///@param tokenId token id you want to burn
  ///@param amount mint a quantity of equipment
  function burn(address to, uint256 tokenId, uint256 amount) external byProxy {
    supplies[tokenId] -= amount;
    _burn(to, tokenId, amount);
  }

  ///@notice Get equipment structure detail
  ///@param tokenId token id you want to return
  ///@return equipment stucture Equipment attached to tokenId
  function getEquipmentDetails(
    uint256 tokenId
  ) external view returns (EquipmentsLib.Equipment memory) {
    return equipments[tokenId];
  }
}
