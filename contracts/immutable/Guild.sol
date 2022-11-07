// SPDX-License-Identifier: MIT
// Guild contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../interfaces/IGuild.sol";
import "../library/LGuild.sol";

contract Guild is ERC20, IGuild {
  mapping(uint8 => GuildLib.Grade) _grades;
  mapping(uint256 => GuildLib.Member) _members;
  mapping(uint256 => GuildLib.Invit) _invits;

  uint256 id;
  uint256 nonceMember;
  uint256 countMember;
  uint256 countInvit;
  address payable owner;
  address myosAddress;

  constructor(
    string memory name,
    string memory symbol,
    address payable _owner,
    address _myosAddress,
    uint256 _id
  ) ERC20(name, symbol) {
    owner = _owner;
    myosAddress = _myosAddress;
    id = _id;
  }

  ///@notice check sender of transaction is creator of guild contract
  modifier onlyCreator() {
    require(_msgSender() == owner || _msgSender() == myosAddress, "Not your guild");
    _;
  }

  ///@notice return a boolean from a uint256 by key
  ///@param _packedBools pack of boolean contained into this uint256
  ///@param _boolNumber key of bool you want to return
  ///@return bool boolean contained into this uint256 by key
  function getBoolean(
    uint256 _packedBools,
    uint256 _boolNumber
  ) internal pure returns (bool) {
    uint256 flag = (_packedBools >> _boolNumber) & uint256(1);
    return (flag == 1 ? true : false);
  }

  ///@notice use this function external view to prepare uint256 of bool to set grade
  ///@param _packedBools pack of boolean contained into this uint256
  ///@param _boolNumber key of bool you want to set
  ///@param _value ?
  function setBoolean(
    uint256 _packedBools,
    uint256 _boolNumber,
    bool _value
  ) external pure returns (uint256) {
    if (_value) {
      _packedBools = _packedBools | (uint256(1) << _boolNumber);
      return _packedBools;
    }
    _packedBools = _packedBools & ~(uint256(1) << _boolNumber);
    return _packedBools;
  }

  ///@dev direct call (not by proxy contract)
  ///@notice upsert grade member and authorization
  ///@param _packedBools pack of boolean contained into this uint256
  ///@param _id key id of grade mapping you want to set
  ///@param name name of this grade
  function setGrade(
    uint256 _packedBools,
    uint8 _id,
    string calldata name
  ) external onlyCreator {
    require(_id > 0 && _id < 10, "10 Grade Max");
    _grades[_id] = GuildLib.Grade(_packedBools, name);
  }

  ///@dev direct call (not by proxy contract)
  ///@notice return grade structure
  ///@param _id key of grade you want to get
  ///@return Grade structure of grade with parameters
  function getGrade(uint8 _id) external view returns (GuildLib.Grade memory) {
    return _grades[_id];
  }

  ///@notice send a subscribtion to this guild by sender
  ///@param description short text for subscription
  function suscribe(string calldata description) external {
    _invits[countInvit] = GuildLib.Invit(true, _msgSender(), description);
    unchecked {
      countInvit++;
    }
  }

  ///@dev direct call (not by proxy contract)
  ///@notice send an un-subscription to this guild by sender
  function unsuscribe(uint256 invit) external {
    require(_invits[invit].valid == true, "This invitation is no more valid");
    uint256 changerId;
    for (uint256 index = 0; index < countMember; index++) {
      if (_members[index].addressMember == _msgSender()) changerId = index;
    }
    require(
      _invits[invit].addr == _msgSender() ||
        (_members[changerId].valid == true &&
          getBoolean(_grades[_members[changerId].grade].datas, 4) == true),
      "Your are not authorized to do this"
    );
    _invits[invit].valid = false;
  }

  ///@dev direct call (not by proxy contract)
  ///@notice return one subscription request
  ///@param invit uint256 id of invitation
  ///@return Invit return structure invit
  function getOneSubscription(
    uint256 invit
  ) external view returns (GuildLib.Invit memory) {
    require(_invits[invit].valid == true, "This invitation is no more valid");
    return _invits[invit];
  }

  /*function getAllSubscription() external view returns (uint256[] memory){
        if(countInvit == 0){
            return new uint256[](0);
        }
        else{
            uint[] memory result = new uint256[](countInvit);
            uint256 resultIndex = 0;
            for(uint256 i = 0; i < countInvit; i++){
                if(_invits[i].valid == true){
                    result[resultIndex] = i;
                    resultIndex++;
                }
            }
            return result;
        }
    }*/

  ///@dev direct call (not by proxy contract)
  ///@notice return all subscription strucuture of this guilds
  ///@return Invit array of invitation subscription
  function getAllSubscriptionStruct() external view returns (GuildLib.Invit[] memory) {
    if (countInvit == 0) {
      return new GuildLib.Invit[](0);
    } else {
      GuildLib.Invit[] memory result = new GuildLib.Invit[](countInvit);
      for (uint256 i = 0; i < countInvit; i++) {
        if (_invits[i].valid == true) {
          GuildLib.Invit storage invit = _invits[i];
          result[i] = invit;
        }
      }
      return result;
    }
  }

  ///@dev direct call (not by proxy contract)
  ///@notice add member to this guild only if we have grade for this
  ///@param _to address of user you want to add member to this guild
  function addMember(address _to) external {
    uint256 changerId;
    uint256 changedId;
    for (uint256 index = 0; index < countMember; index++) {
      if (_members[index].addressMember == _msgSender()) changerId = index;
    }
    for (uint256 index2 = 0; index2 < countInvit; index2++) {
      if (_invits[index2].addr == _to) changedId = index2;
    }
    require(_members[changedId].valid == true, "User not valid");
    require(
      _members[changerId].valid == true &&
        getBoolean(_grades[_members[changerId].grade].datas, 3) == true,
      "Your are not authorized to do this"
    );
    _members[nonceMember] = GuildLib.Member(
      false,
      0,
      block.timestamp,
      0,
      _msgSender(),
      _to
    );
    _members[changedId].valid = false;
    unchecked {
      nonceMember++;
    }
  }

  ///@dev direct call (not by proxy contract)
  ///@notice change grade of one user if you have right
  ///@param _to address of member you want to change grade
  ///@param grade grade id you want to set for this member
  function changeGrade(address _to, uint8 grade) external {
    uint256 changerId;
    uint256 changedId;
    for (uint256 index = 0; index < countMember; index++) {
      if (_members[index].addressMember == _msgSender()) changerId = index;
      if (_members[index].addressMember == _to) changedId = index;
    }
    require(
      getBoolean(_grades[_members[changerId].grade].datas, 7) == true ||
        _msgSender() == owner ||
        _msgSender() == myosAddress,
      "Your rank does not authorize upgrading"
    );
    require(
      (_members[changerId].grade >= grade &&
        _members[changerId].grade > _members[changedId].grade) ||
        _msgSender() == owner ||
        _msgSender() == myosAddress,
      "Your rank is not high enough"
    );
    require(
      _members[changedId].valid == true && _members[changerId].valid == true,
      "Not valid user"
    );
    _members[changerId].grade = grade;
  }

  ///@dev direct call (not by proxy contract)
  ///@notice kick a member from this guild but keep datas, only set valid param to false but we send their money, we are not savage
  ///@param _to address of member you want to kick
  function subMember(address _to) external {
    uint256 changerId;
    uint256 changedId;
    for (uint256 index = 0; index < countMember; index++) {
      if (_members[index].addressMember == _msgSender()) changerId = index;
      if (_members[index].addressMember == _to) changedId = index;
    }

    require(
      getBoolean(_grades[_members[changerId].grade].datas, 4) == true ||
        _msgSender() == owner ||
        _msgSender() == myosAddress,
      "Your rank does not authorize upgrading"
    );
    require(
      _members[changerId].grade > _members[changedId].grade ||
        _msgSender() == owner ||
        _msgSender() == myosAddress,
      "Your rank is not high enough"
    );
    require(
      _members[changedId].valid == true && _members[changerId].valid == true,
      "Not valid user"
    );
    payable(_members[changedId].addressMember).transfer(_members[changedId].chestETH);
    _members[changedId].valid = false;
  }

  ///@dev direct call (not by proxy contract)
  ///@notice return all members valid of this guild
  ///@return Members array of member structure
  function getAllMembers() external view returns (GuildLib.Member[] memory) {
    if (countMember == 0) {
      return new GuildLib.Member[](0);
    } else {
      GuildLib.Member[] memory result = new GuildLib.Member[](countMember);
      for (uint256 i = 0; i < countMember; i++) {
        if (_members[i].valid == true) {
          GuildLib.Member storage member = _members[i];
          result[i] = member;
        }
      }
      return result;
    }
  }

  ///@dev direct call (not by proxy contract)
  ///@notice return one member of this guild
  ///@param member address of member you want to get
  ///@return Member member structure (can be empty stuct)
  function getOneMember(address member) external view returns (GuildLib.Member memory) {
    GuildLib.Member memory tempMember;
    for (uint256 index = 0; index < countMember; index++) {
      if (_members[index].addressMember == member) tempMember = _members[index];
    }
    return tempMember;
  }

  ///@dev direct call (not by proxy contract)
  ///@notice validate or not a member in this guild
  ///@param valid boolean validity of member
  ///@param member id key of member
  function validMember(bool valid, uint256 member) external onlyCreator {
    _members[member].valid = valid;
  }

  ///@dev direct call (not by proxy contract)
  ///@notice put wei in this contract, accessible only by sender
  function sendETHInChest() external payable {
    uint256 idUser;
    for (uint256 index = 0; index < countMember; index++) {
      if (_members[index].addressMember == _msgSender()) idUser = index;
    }
    require(_members[idUser].valid == true, "Not valid user");
    _members[idUser].chestETH += msg.value;
  }

  ///@dev direct call (not by proxy contract)
  ///@notice retrieve money sended by user on this contract
  function withdrawETHMyChest(uint256 value) external {
    uint256 idUser;
    for (uint256 index = 0; index < countMember; index++) {
      if (_members[index].addressMember == _msgSender()) idUser = index;
    }
    require(_members[idUser].valid == true, "Not valid user");
    require(_members[idUser].chestETH >= value, "Not enougth ether in chest");
    payable(_msgSender()).transfer(value);
  }

  //function kill() external onlyCreator {
  //  selfdestruct(owner);
  //}

  ///@notice return id of this contract
  ///@return id number key of this contract
  function getId() external view returns (uint256) {
    return id;
  }

  ///@notice check if owner is creater of this guild contract
  ///@param _owner address of creator guild contract
  ///@return owner boolean
  function isOwner(address _owner) external view returns (bool) {
    return _owner == owner;
  }
}
