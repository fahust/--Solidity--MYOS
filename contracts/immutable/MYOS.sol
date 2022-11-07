// SPDX-License-Identifier: MIT
// Items Contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../interfaces/IMYOS.sol";

contract MYOS is ERC20, Ownable, IMYOS {
  error NotProxyContract(address sender, address addressProxyContract);
  error MaxSupplyReached(uint256 totalSupply, uint256 quantity, uint256 maxSupply);
  error TransferIsPaused(uint256 timestamp, uint256 pausedTransferEndDate, address from);
  error MintIsPaused(uint256 timestamp, uint256 pausedMintEndDate, address from);

  address public addressProxyContract;
  uint256 public maxSupply;
  uint256 private pausedTransferEndDate;
  uint256 private pausedMintEndDate;

  constructor(
    uint256 _maxSupply,
    string memory name,
    string memory symbol
  ) ERC20(name, symbol) {
    maxSupply = _maxSupply * (10 ** uint256(decimals()));
  }

  ///@notice Very important function that we add on almost all the other functions to check that the call of the functions is done well from the delegation contract for more security
  modifier byProxy() {
    if (_msgSender() != addressProxyContract && addressProxyContract != address(0))
      revert NotProxyContract({
        sender: _msgSender(),
        addressProxyContract: addressProxyContract
      });
    _;
  }

  ///@notice modify the address of the delegation contract to allow the said contract to interact with this one
  ///@param _address new address of delegation contract
  function setAddressProxyContract(address _address) external onlyOwner {
    addressProxyContract = _address;
  }

  ///@notice Function of mint token
  ///@param to address of receiver's item
  ///@param quantity mint a guantity of item
  function mint(address to, uint256 quantity) external byProxy {
    if (totalSupply() + quantity >= maxSupply)
      revert MaxSupplyReached({
        totalSupply: totalSupply(),
        quantity: quantity,
        maxSupply: maxSupply
      });
    _mint(to, quantity);
  }

  ///@notice Function of burn token
  ///@param to address of burner's item
  ///@param quantity mint a guantity of item
  function burn(address to, uint256 quantity) external byProxy {
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
    if (block.timestamp < pausedTransferEndDate && from != address(0))
      revert TransferIsPaused({
        timestamp: block.timestamp,
        pausedTransferEndDate: pausedTransferEndDate,
        from: from
      });
    if (block.timestamp < pausedMintEndDate && from == address(0))
      revert MintIsPaused({
        timestamp: block.timestamp,
        pausedMintEndDate: pausedMintEndDate,
        from: from
      });
    super._beforeTokenTransfer(from, to, amount);
  }
}
