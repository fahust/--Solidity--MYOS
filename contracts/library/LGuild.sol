// SPDX-License-Identifier: MIT
// Classes contract
pragma solidity ^0.8.0;

library GuildLib {
  struct Member {
    bool valid;
    uint8 grade;
    uint256 createdAt;
    uint256 chestETH;
    address addBy;
    address addressMember;
  }

  struct Invit {
    bool valid;
    address addr;
    string description;
  }

  struct Grade {
    uint256 datas;
    /*bool valid;
    bool write;
    bool read;
    bool invit;
    bool desinvit;
    bool sendMoney;
    bool takeMoney;
    bool graduate;*/
    string name;
  }
}
