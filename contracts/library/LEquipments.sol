// SPDX-License-Identifier: MIT
// Classes contract
pragma solidity ^0.8.0;

library EquipmentsLib {
  struct Equipment {
    string name;
    uint256 rarity;
    uint256 price;
    uint256[] itemsCraft;
    bool valid;
  }
}
