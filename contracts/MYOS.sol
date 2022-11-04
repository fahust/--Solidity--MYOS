// SPDX-License-Identifier: MIT
// Items Contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MYOS is ERC20, Ownable {
  address public addressDelegateContract;
  uint256 public maxSupply;
  uint256 private pausedTransferEndDate;
  uint256 private pausedMintEndDate;

  constructor(
    uint256 _maxSupply,
    string memory name,
    string memory symbol
  ) ERC20(name, symbol) {
    maxSupply = _maxSupply * (10**uint256(decimals()));
  }

  ///@notice Very important function that we add on almost all the other functions to check that the call of the functions is done well from the delegation contract for more security
  modifier byDelegate() {
    require(
      (_msgSender() == addressDelegateContract || addressDelegateContract == address(0)),
      "Not good delegate contract"
    );
    _;
  }

  ///@notice modify the address of the delegation contract to allow the said contract to interact with this one
  ///@param _address new address of delegation contract
  function setAddressDelegateContract(address _address) external onlyOwner {
    addressDelegateContract = _address;
  }

  ///@notice Function of mint token
  ///@param to address of receiver's item
  ///@param quantity mint a guantity of item
  function mint(address to, uint256 quantity) external byDelegate {
    require(totalSupply() < maxSupply, "Max supply reached");
    _mint(to, quantity);
  }

  ///@notice Function of burn token
  ///@param to address of burner's item
  ///@param quantity mint a guantity of item
  function burn(address to, uint256 quantity) external byDelegate {
    _burn(to, quantity);
  }

  /*FUNDS OF CONTRACT*/

  ///@notice Withdraw funds of this contract to an address wallet
  function withdraw() external onlyOwner {
    payable(_msgSender()).transfer(address(this).balance);
  }

  ///@notice Pause mint of token between address before time pausedMintEndDate
  ///@param time timestamp until which the contract will be paused for mint
  function setPausedMintEndDate(uint256 time) external onlyOwner {
    pausedMintEndDate = time;
  }

  ///@notice Pause transfer of token between address before time pausedTransferEndDate
  ///@param time timestamp until which the contract will be paused for transfer
  function setPausedTransferEndDate(uint256 time) external onlyOwner {
    pausedTransferEndDate = time;
  }

  ///@notice override of function before token transfer to pauser transfer
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override(ERC20) {
    require(
      block.timestamp >= pausedTransferEndDate || from == address(0),
      "Transfer is paused"
    );
    require(block.timestamp >= pausedMintEndDate || from != address(0), "Mint is paused");
    super._beforeTokenTransfer(from, to, amount);
  }
}
