// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../immutable/Guild.sol";


//enum Numbers {strong,endurance,concentration,agility,charisma,stealth,exp,level,faction,classe}

contract ProxyGuild is Ownable, ReentrancyGuard {
  error AlreadyHaveGuild(address from, address addressGuild);
  error GuildNotExist(address from, address addressGuild);

  mapping(address => Guild) private guilds; //address = creator
  mapping(uint256 => address) private addressGuilds; //address = creator
  uint8 private countGuilds;

  ///@notice Create a guild by also deleting its contract
  ///@param from user for found addresses of your contract by creator mapping
  ///@param name name of your created contract
  ///@param symbol name of your created contract
  function createGuild(
    address from,
    string calldata name,
    string calldata symbol
  ) external {
    if (address(guilds[from]) != address(0))
      revert AlreadyHaveGuild({ from: from, addressGuild: address(guilds[from]) });
    guilds[from] = new Guild(name, symbol, payable(_msgSender()), owner(), countGuilds);
    addressGuilds[countGuilds] = from;
    countGuilds++;
  }

  ///@notice return one guild by address creator
  ///@param from user for found addresses of your contract by creator mapping
  ///@return addressContract address of the contract guild
  function getOneGuildAddress(address from) external view returns (address) {
    if (address(guilds[from]) == address(0))
      revert GuildNotExist({ from: from, addressGuild: address(guilds[from]) });
    return address(guilds[from]);
  }

  ///@notice return all guilds addresses
  ///@return result an array of address for all guilds created
  function getAddressesGuilds() external view returns (address[] memory) {
    address[] memory result = new address[](countGuilds);
    uint256 resultIndex = 0;
    uint256 i;
    for (i = 0; i < countGuilds; i++) {
      if (addressGuilds[i] != address(0)) {
        result[resultIndex] = addressGuilds[i];
        resultIndex++;
      }
    }
    return result;
  }


  ///@notice Deleted a guild by also deleting its contract
  ///@dev ATTENTION, the totality of the ether contained above atters to the creator of the contract
  ///@param from user for found addresses of your contract by creator mapping
  //function deleteGuild(address from) external {
  //  require(address(guilds[from]) != address(0), "Guild not exist");
  //  require(guilds[from].isOwner(_msgSender()), "Is not your guild");
  //  guilds[from].kill();
  //  addressGuilds[guilds[from].getId()] = address(0);
  //}
}
