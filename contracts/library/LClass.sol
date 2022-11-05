// SPDX-License-Identifier: MIT
// Classes contract
pragma solidity ^0.8.0;

library ClassLib {
  struct Classes {
    uint8 rarity;
    uint8 id;
    uint8[] stats;
    bool valid;
    string name;
  }
}
