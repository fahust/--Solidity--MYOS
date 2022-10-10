// SPDX-License-Identifier: MIT
// Items Contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MYOS is ERC20, Ownable {
  address public adressDelegateContract;
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
      (msg.sender == adressDelegateContract || adressDelegateContract == address(0)),
      "Not good delegate contract"
    );
    _;
  }

  ///@notice Modify the address of the delegation contract to allow the said contract to interact with this one
  function setAdressDelegateContract(address _adress) external onlyOwner {
    adressDelegateContract = _adress;
  }

  ///@notice Function to offer myos tokens to a wallet address
  function mint(address to, uint256 value) external byDelegate {
    require(totalSupply() < maxSupply, "Max supply reached");
    _mint(to, value);
  }

  ///@notice Function to destroy myos tokens to a wallet address
  function burn(address to, uint256 number) external byDelegate {
    _burn(to, number);
  }

  ///@notice Return native token (MATIC) from this contract
  function getBalanceContract() external view returns (uint256) {
    return address(this).balance;
  }

  /*FUNDS OF CONTRACT*/

  ///@notice Withdraw funds of this contract to an address wallet
  function withdraw() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  ///@notice Deposit funds to this contract
  function deposit() external payable {}

  ///@notice Pause mint of token between address before time pausedMintEndDate
  function setPausedMintEndDate(uint256 time) external onlyOwner {
    pausedMintEndDate = time;
  }

  ///@notice Pause transfer of token between address before time pausedTransferEndDate
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
