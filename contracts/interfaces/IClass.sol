// SPDX-License-Identifier: MIT
// Classes contract
pragma solidity ^0.8.0;

import "../library/LClass.sol";

interface IClass {
  function setClass(
    uint8 _id,
    uint8 rarity,
    uint8[] memory stats,
    string memory name
  ) external;

  function removeClass(uint8 _id) external;

  function getClassStatsDetails(uint8 classId) external view returns (uint8[] memory);

  function getClassDetails(uint8 classId) external view returns (ClassLib.Classes memory);

  function getClassCount() external view returns (uint8);

  function getAllClass() external view returns (ClassLib.Classes[] memory);
}
