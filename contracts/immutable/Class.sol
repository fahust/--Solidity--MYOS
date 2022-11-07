// SPDX-License-Identifier: MIT
// Classes contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IClass.sol";
import "../library/LClass.sol";

contract Class is Ownable, IClass {
  error ClassIsNotValid(uint8 id);

  mapping(uint8 => ClassLib.Classes) private classes;

  uint8 classCount;

  ///@dev direct call (not by proxy contract)
  ///@notice upsert class for hero
  ///@param id key of class you want to set
  ///@param rarity rarity percent 0-1000 to get this class in mint hero
  ///@param stats array of uint8 statistique for start in mint hero
  ///@param name string name of class
  function setClass(
    uint8 id,
    uint8 rarity,
    uint8[] calldata stats,
    string calldata name
  ) external onlyOwner {
    if (classes[id].valid == false) classCount++;
    classes[id] = ClassLib.Classes(rarity, id, stats, true, name);
  }

  ///@dev direct call (not by proxy contract)
  ///@notice remove class validity
  ///@param id key of class you want delete
  function removeClass(uint8 id) external onlyOwner {
    if (classes[id].valid == false) revert ClassIsNotValid({ id: id });
    classCount--;
    classes[id].valid = false;
  }

  ///@notice return stats parameter of class by id
  ///@param id key of class you want to get
  ///@return stats parameter stats of structure class
  function getClassStatsDetails(uint8 id) external view returns (uint8[] memory) {
    return classes[id].stats;
  }

  ///@notice return class structure by id
  ///@param id key of class you want to get
  ///@return class structure class
  function getClassDetails(uint8 id) external view returns (ClassLib.Classes memory) {
    return classes[id];
  }

  ///@notice return class count number
  ///@return classCount
  function getClassCount() external view returns (uint8) {
    return classCount;
  }

  ///@notice return all classes
  ///@return classes array of structure class
  function getAllClass() external view returns (ClassLib.Classes[] memory) {
    ClassLib.Classes[] memory result = new ClassLib.Classes[](classCount);
    for (uint8 i = 0; i < classCount; i++) {
      ClassLib.Classes storage classe = classes[i];
      result[i] = classe;
    }
    return result;
  }
}
