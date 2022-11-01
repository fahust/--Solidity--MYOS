// SPDX-License-Identifier: MIT
// Classes contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Class is Ownable {
  struct Classes {
    uint8 rarity; //0 a 100 % et en mêttre une a 100 % qui soit la classique si ont a pas eu la chance de tomber sur une autre
    uint8[] stats; //required
    uint8 id;
    bool valid;
    string name;
  }

  mapping(uint8 => Classes) private _classDetails;

  uint8 classCount;

  function setClass(
    uint8 _id,
    uint8 rarity,
    uint8[] memory stats,
    string memory name
  ) external onlyOwner {
    if (_classDetails[_id].valid == false) classCount++;
    _classDetails[_id] = Classes(rarity, stats, _id, true, name);
  }

  function removeClass(uint8 _id) external onlyOwner {
    if (_classDetails[_id].valid == true) classCount--;
    _classDetails[_id].valid = false;
  }

  function getClassStatsDetails(uint8 classId) external view returns (uint8[] memory) {
    return _classDetails[classId].stats;
  }

  function getClassDetails(uint8 classId) external view returns (Classes memory) {
    return _classDetails[classId];
  }

  function getClassCount() external view returns (uint8) {
    return classCount;
  }

  function getAllClass() external view returns (Classes[] memory) {
    Classes[] memory result = new Classes[](classCount);
    for (uint8 i = 0; i < classCount; i++) {
      Classes storage classe = _classDetails[i];
      result[i] = classe;
    }
    return result;
  }
}
