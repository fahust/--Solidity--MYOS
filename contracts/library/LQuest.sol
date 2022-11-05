// SPDX-License-Identifier: MIT
// Classes contract
pragma solidity ^0.8.0;

library QuestLib {
  ///@dev For the quests no obligation of stat
  ///@dev We define the success rate from 0 to 100%.
  ///@dev Quests with recommendation of stats (example 20 of strength) if below 20 we remove the lack to the % of chance of success from 0 to 100
  ///@dev If no more difference in success
  struct QuestStruct {
    uint16 exp;
    uint8 percentDifficulty; //0 - 100
    uint8[] stats; //required
    uint8[] items;
    uint256 id;
    uint256 time;
    bool valid;
  }
}
