// SPDX-License-Identifier: MIT
// Equipments Contract
pragma solidity ^0.8.0;

import "../library/LEquipments.sol";

interface IEquipments {
  ///@notice create or update quest
  ///@param name name of equipment
  ///@param rarity rarity to loot this equipment
  ///@param price price of equipment in wei
  ///@param id id of equipment you want to set
  function setEquipment(
    string calldata name,
    uint256 rarity,
    uint256 price,
    uint256[] calldata itemsCraft,
    uint256 id
  ) external;

  function getSupply(uint256 tokenId) external view returns (uint256);

  ///@notice modify the address of the delegation contract to allow the said contract to interact with this one
  ///@param _address new address of delegation contract
  function setaddressProxyContract(address _address) external;

  ///@notice Function of mint token
  ///@param to address of receiver's equipment
  ///@param tokenId token id you want to mint
  ///@param amount mint a quantity of equipment
  function mint(address to, uint256 tokenId, uint256 amount) external payable;

  ///@notice Function of burn token
  ///@param to address of burner's equipment
  ///@param tokenId token id you want to burn
  ///@param amount mint a quantity of equipment
  function burn(address to, uint256 tokenId, uint256 amount) external;

  ///@notice Get equipment structure detail
  ///@param tokenId token id you want to return
  ///@return equipment stucture Equipment attached to tokenId
  function getEquipmentDetails(
    uint256 tokenId
  ) external view returns (EquipmentsLib.Equipment memory);
}
