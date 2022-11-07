// SPDX-License-Identifier: MIT
// Guild contract
pragma solidity ^0.8.0;

import "../library/LGuild.sol";

interface IGuild {
  ///@notice use this function external view to prepare uint256 of bool to set grade
  ///@param _packedBools pack of boolean contained into this uint256
  ///@param _boolNumber key of bool you want to set
  ///@param _value ?
  function setBoolean(
    uint256 _packedBools,
    uint256 _boolNumber,
    bool _value
  ) external pure returns (uint256);

  ///@dev direct call (not by proxy contract)
  ///@notice upsert grade member and authorization
  ///@param _packedBools pack of boolean contained into this uint256
  ///@param _id key id of grade mapping you want to set
  ///@param name name of this grade
  function setGrade(uint256 _packedBools, uint8 _id, string memory name) external;

  ///@dev direct call (not by proxy contract)
  ///@notice return grade structure
  ///@param _id key of grade you want to get
  ///@return Grade structure of grade with parameters
  function getGrade(uint8 _id) external view returns (GuildLib.Grade memory);

  ///@notice send a subscribtion to this guild by sender
  ///@param description short text for subscription
  function suscribe(string memory description) external;

  ///@dev direct call (not by proxy contract)
  ///@notice send an un-subscription to this guild by sender
  function unsuscribe(uint256 invit) external;

  ///@dev direct call (not by proxy contract)
  ///@notice return one subscription request
  ///@param invit uint256 id of invitation
  ///@return Invit return structure invit
  function getOneSubscription(
    uint256 invit
  ) external view returns (GuildLib.Invit memory);

  ///@dev direct call (not by proxy contract)
  ///@notice return all subscription strucuture of this guilds
  ///@return Invit array of invitation subscription
  function getAllSubscriptionStruct() external view returns (GuildLib.Invit[] memory);

  ///@dev direct call (not by proxy contract)
  ///@notice add member to this guild only if we have grade for this
  ///@param _to address of user you want to add member to this guild
  function addMember(address _to) external;

  ///@dev direct call (not by proxy contract)
  ///@notice change grade of one user if you have right
  ///@param _to address of member you want to change grade
  ///@param grade grade id you want to set for this member
  function changeGrade(address _to, uint8 grade) external;

  ///@dev direct call (not by proxy contract)
  ///@notice kick a member from this guild but keep datas, only set valid param to false but we send their money, we are not savage
  ///@param _to address of member you want to kick
  function subMember(address _to) external;

  ///@dev direct call (not by proxy contract)
  ///@notice return all members valid of this guild
  ///@return Members array of member structure
  function getAllMembers() external view returns (GuildLib.Member[] memory);

  ///@dev direct call (not by proxy contract)
  ///@notice return one member of this guild
  ///@param member address of member you want to get
  ///@return Member member structure (can be empty stuct)
  function getOneMember(address member) external view returns (GuildLib.Member memory);

  ///@dev direct call (not by proxy contract)
  ///@notice validate or not a member in this guild
  ///@param valid boolean validity of member
  ///@param member id key of member
  function validMember(bool valid, uint256 member) external;

  ///@dev direct call (not by proxy contract)
  ///@notice put wei in this contract, accessible only by sender
  function sendETHInChest() external payable;

  ///@dev direct call (not by proxy contract)
  ///@notice retrieve money sended by user on this contract
  function withdrawETHMyChest(uint256 value) external;

  ///@notice return id of this contract
  ///@return id number key of this contract
  function getId() external view returns (uint256);

  ///@notice check if owner is creater of this guild contract
  ///@param _owner address of creator guild contract
  ///@return owner boolean
  function isOwner(address _owner) external view returns (bool);
}
