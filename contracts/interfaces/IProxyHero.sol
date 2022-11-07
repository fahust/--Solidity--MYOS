// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

interface IProxyHero {
  ///@notice Update a parameter of contract
  ///@param key key index of params contract you want set
  ///@param value value of params contract you want set
  function setParamsContract(string memory key, uint256 value) external;

  ///@notice Return a parameter of contract by key index
  ///@param key key index of param your want to return
  ///@return param value of parameter contract
  function getParamsContract(string memory key) external view returns (uint256);

  ///@notice mint a hero for a value price and generate stats and parameterr
  ///@param generation generation of creation hero
  ///@param peuple peuple with class and stat linked
  ///@param _tokenUri uri of metadata token hero
  function mintHero(
    uint8 generation,
    uint8 peuple,
    string memory _tokenUri
  ) external payable;

  ///@notice start a quest by id for one hero token
  ///@param tokenId id of token you want to launch in quest
  ///@param questId id of quest you want to start
  function startQuest(uint256 tokenId, uint256 questId) external;

  ///@notice Validation of the quest at the end of a quest
  ///@param tokenId id of token you want to complete quest
  function completeQuest(uint256 tokenId) external;

  ///@notice level up hero and increment one stat
  ///@param statToLvlUp id of stat you wan increment
  ///@param tokenId id of token you want level up
  function levelUp(uint8 statToLvlUp, uint256 tokenId) external;

  function withdraw() external;
}
