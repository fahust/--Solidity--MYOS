// SPDX-License-Identifier: MIT
// Quest Contract
pragma solidity ^0.8.0;

import "../library/LQuest.sol";

interface IQuest {
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
    uint8[] memory stats,
    uint8[] memory items
  ) external;

  ///@notice remove a quest by id
  ///@param questId key index of quest you want delete
  function removeQuest(uint256 questId) external;

  ///@notice return detail of one quest
  ///@param questId id key of quest you want to return
  ///@return questDetail quest structure
  function getQuestDetails(
    uint256 questId
  ) external view returns (QuestLib.QuestStruct memory);

  function getMultiplicateurExp() external view returns (uint8);

  ///@notice Retrieve in a table ids of quest
  ///@return result array of uint256
  function getAllQuests() external view returns (uint256[] memory);
}
