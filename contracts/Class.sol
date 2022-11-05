// SPDX-License-Identifier: MIT
// Classes contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IClass.sol";
import "./library/LClass.sol";

contract Class is Ownable, IClass {
  mapping(uint8 => ClassLib.Classes) private _classDetails;

  uint8 classCount;

  function setClass(
    uint8 _id,
    uint8 rarity,
    uint8[] memory stats,
    string memory name
  ) external onlyOwner {
    if (_classDetails[_id].valid == false) classCount++;
    _classDetails[_id] = ClassLib.Classes(rarity, _id, stats, true, name);
  }

  function removeClass(uint8 _id) external onlyOwner {
    if (_classDetails[_id].valid == true) classCount--;
    _classDetails[_id].valid = false;
  }

  function getClassStatsDetails(uint8 classId) external view returns (uint8[] memory) {
    return _classDetails[classId].stats;
  }

  function getClassDetails(
    uint8 classId
  ) external view returns (ClassLib.Classes memory) {
    return _classDetails[classId];
  }

  function getClassCount() external view returns (uint8) {
    return classCount;
  }

  function getAllClass() external view returns (ClassLib.Classes[] memory) {
    ClassLib.Classes[] memory result = new ClassLib.Classes[](classCount);
    for (uint8 i = 0; i < classCount; i++) {
      ClassLib.Classes storage classe = _classDetails[i];
      result[i] = classe;
    }
    return result;
  }
}
