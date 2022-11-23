// SPDX-License-Identifier: MIT
// Token Myos
pragma solidity ^0.8.0;

import "../library/LHero.sol";

interface IHero {
  ///@notice Update the uri of tokens metadatas
  function setBaseURI(string memory _newBaseURI) external;

  ///@notice Pause the contract in case of problems
  function pause(bool _state) external;

  ///@notice Function of mint token
  ///@param receiver receiver address of token _requireMinted
  ///@param params8 array uint8 used for stats
  ///@param params256 array uint256 used for complex parameter
  function mint(
    address receiver,
    uint8[] memory params8,
    uint256[] memory params256
  ) external payable;

  ///@notice Burn a token with its id and decrease the total supply
  function burn(uint256 tokenId) external;

  ///@notice Transfer a token from one address to another using the token id
  function transfer(address from, address to, uint256 tokenId) external;

  ///@notice Retrieve in a table all the ids token of a user
  ///@param user address of user own token
  ///@return ids ids token of user
  function getAllTokensForUser(address user) external view returns (uint256[] memory);

  ///@notice Update the token (hero) in case of level up for example by using the id as key and sending directly the object of the token update
  ///@param tokenTemp structure of token you want to return
  ///@param tokenId id of token you want to update
  ///@param owner sender of tx origin by proxyContract
  function updateToken(
    HeroLib.Token memory tokenTemp,
    uint256 tokenId,
    address owner
  ) external;

  ///@notice Retrieve data from a token using its id
  ///@param tokenId key id of token
  ///@return token structure of token
  function getTokenDetails(uint256 tokenId) external view returns (HeroLib.Token memory);

  ///@notice Update one of the cotnrat data using the key
  ///@param key key index of parameter you want to return
  ///@param value value you want to set
  function setParamsContract(string memory key, uint256 value) external;

  ///@notice Retrieve one of the contract data using the key
  ///@param key key index of parameter you want to return
  ///@return paramContract value of parameter
  function getParamsContract(string memory key) external view returns (uint256);

  ///@notice modify the address of the delegation contract to allow the said contract to interact with this one
  ///@param _address address of proxy contract
  function setAddressProxyContract(address _address) external;

  ///@notice FUNDS OF CONTRACT
  function withdraw() external;

  function getAllTokens() external view returns (HeroLib.Token[] memory);
}
