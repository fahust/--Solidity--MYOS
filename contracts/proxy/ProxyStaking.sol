// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../immutable/Items.sol";

import "../library/LItems.sol";

contract ProxyStaking is Ownable, ReentrancyGuard {
  using SafeMath for uint;

  address private addressItem;

  uint256 private constant utilMathMultiply = 10000000;

  constructor(address _addressItem) {
    addressItem = _addressItem;
  }


  ///@notice Withdraw funds of this contract to an address wallet
  function withdraw() external onlyOwner {
    payable(_msgSender()).transfer(address(this).balance);
  }
}
