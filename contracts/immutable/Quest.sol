// SPDX-License-Identifier: MIT
// Quest Contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../library/LQuest.sol";

contract Quest is Ownable {
  constructor() {
    multiplicateurExp = 1;
  }

  mapping(uint256 => QuestLib.QuestStruct) private _questDetails;

  uint8 questCount;
  uint8 multiplicateurExp;

  ///@notice create or update quest
  ///@param id id key of quest you want to upsert
  ///@param time during of quest for complete them
  ///@param exp experience gained to complete quest
  ///@param percentDifficulty difficulty of quest 0 - 100 %
  ///@param stats stats needed to complete quest (malus - bonus)
  ///@param items array of items win in complete quest
  function setQuest(
    uint256 id,
    uint256 time,
    uint16 exp,
    uint8 percentDifficulty,
    uint8[] calldata stats,
    uint8[] calldata items
  ) external onlyOwner {
    if (_questDetails[id].valid == false) questCount++;
    _questDetails[id] = QuestLib.QuestStruct(
      exp,
      percentDifficulty,
      stats,
      items,
      id,
      time,
      true
    );
  }

  ///@notice modifier to check if quest exist by id
  ///@param questId id key of quest you want to check
  modifier questExist(uint256 questId) {
    require(_questDetails[questId].valid == true, "Quest not exist");
    _;
  }

  ///@notice remove a quest by id
  ///@param questId key index of quest you want delete
  function removeQuest(uint256 questId) external onlyOwner questExist(questId) {
    if (_questDetails[questId].valid == true) questCount--;
    _questDetails[questId].valid = false;
  }

  ///@notice return detail of one quest
  ///@param questId id key of quest you want to return
  ///@return questDetail quest structure
  function getQuestDetails(
    uint256 questId
  ) external view questExist(questId) returns (QuestLib.QuestStruct memory) {
    return _questDetails[questId];
  }

  function getMultiplicateurExp() external view returns (uint8) {
    return multiplicateurExp;
  }

  ///@notice Retrieve in a table ids of quest
  ///@return result array of uint256
  function getAllQuests() external view returns (uint256[] memory) {
    uint256[] memory result = new uint256[](questCount);
    uint256 resultIndex = 0;
    uint256 i;
    for (i = 0; i < questCount; i++) {
      result[resultIndex] = _questDetails[i].id;
      resultIndex++;
    }
    return result;
  }
}
