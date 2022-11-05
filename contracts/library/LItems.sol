// SPDX-License-Identifier: MIT
// Classes contract
pragma solidity ^0.8.0;

library ItemsLib {
  struct Item {
    string name;
    uint256 rarity;
    uint256 price;
    bool valid;
  }
}
