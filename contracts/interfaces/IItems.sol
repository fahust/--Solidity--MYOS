// SPDX-License-Identifier: MIT
// Items Contract
pragma solidity ^0.8.0;

import "../library/LItems.sol";

interface IItems {
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
  ) external;

  function getSupply(uint256 tokenId) external view returns (uint256);

  ///@notice modify the address of the delegation contract to allow the said contract to interact with this one
  ///@param _address new address of delegation contract
  function setaddressDelegateContract(address _address) external;

  ///@notice Function of mint token
  ///@param to address of receiver's item
  ///@param tokenId token id you want to mint
  ///@param amount mint a quantity of item
  function mint(address to, uint256 tokenId, uint256 amount) external payable;

  ///@notice Function of burn token
  ///@param to address of burner's item
  ///@param tokenId token id you want to burn
  ///@param amount mint a quantity of item
  function burn(address to, uint256 tokenId, uint256 amount) external;

  ///@notice Get item structure detail
  ///@param tokenId token id you want to return
  ///@return item stucture Item attached to tokenId
  function getItemDetails(uint256 tokenId) external view returns (ItemsLib.Item memory);
}
