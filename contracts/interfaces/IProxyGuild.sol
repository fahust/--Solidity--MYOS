// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

interface IProxyGuild {
  ///@notice Create a guild by also deleting its contract
  ///@param from user for found addresses of your contract by creator mapping
  ///@param name name of your created contract
  ///@param symbol name of your created contract
  function createGuild(
    address from,
    string calldata name,
    string calldata symbol
  ) external;

  ///@notice return one guild by address creator
  ///@param from user for found addresses of your contract by creator mapping
  ///@return addressContract address of the contract guild
  function getOneGuildAddress(address from) external view returns (address);

  ///@notice return all guilds addresses
  ///@return result an array of address for all guilds created
  function getAddressesGuilds() external view returns (address[] memory);
}
