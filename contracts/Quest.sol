// SPDX-License-Identifier: MIT
// Quest Contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Quest is Ownable {
  /**
    Pour les quetes pas d'obligation de stat
    On défini le taux de réussite de 0 a 100 %
    Quetes avec recommandation de stats (exemple 20 de force) si en dessous de 20 on retire le manque aux % de chance de reussite de 0 a 100 %
    Si plus aucune différence de réussite
    */
  struct Quest {
    uint8 exp;
    uint8 percentDifficulty; //0 a 100
    uint8[] stats; //required
    uint256 id;
    uint256 time;
    bool valid;
  }

  constructor() {
    multiplicateurExp = 1;
  }

  mapping(uint256 => Quest) private _questDetails;

  uint8 questCount;
  uint8 multiplicateurExp;

  /* QUEST */
  function setQuest(
    uint256 id,
    uint256 time,
    uint8 exp,
    uint8 percentDifficulty,
    uint8[] memory stats
  ) external onlyOwner {
    if (_questDetails[id].valid == false) questCount++;
    _questDetails[id] = Quest(exp, percentDifficulty, stats, id, time, true);
  }

  modifier questExist(uint256 questId) {
    require(_questDetails[questId].valid == true, "Quest not exist");
    _;
  }

  function removeQuest(uint256 questId) external onlyOwner questExist(questId) {
    if (_questDetails[questId].valid == true) questCount--;
    _questDetails[questId].valid = false;
  }

  function getQuestDetails(uint256 questId)
    external
    view
    questExist(questId)
    returns (Quest memory)
  {
    return _questDetails[questId];
  }

  function getMultiplicateurExp() external view returns (uint8) {
    return multiplicateurExp;
  }

  /**
    Récupérer dans un tableau tout les id token d'un utilisateur
    */
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
