// SPDX-License-Identifier: MIT
// Token Myos
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IHero.sol";
import "../library/LHero.sol";

contract Hero is ERC721URIStorage, Ownable, IHero {
  using Strings for uint256;

  address addressProxyContract;
  mapping(string => uint256) paramsContract;
  mapping(uint256 => HeroLib.Token) private _tokenDetails;

  string public baseURI;
  string public constant baseExtension = ".json";
  bool private paused = false;

  constructor(
    string memory name,
    string memory symbol,
    string memory _initBaseURI
  ) ERC721(name, symbol) {
    paramsContract["nextId"] = 0;
    paramsContract["totalSupply"] = 0;
    setBaseURI(_initBaseURI);
  }

  ///@notice Returns a random number up to a defined maxNumber
  ///@param maxNumber max number uint8 for generate random number
  ///@return randomNumber generated number uint8
  function random(uint8 maxNumber) internal returns (uint8) {
    uint256 randomnumber = uint256(
      keccak256(abi.encodePacked(block.timestamp, _msgSender(), paramsContract["nonce"]))
    ) % maxNumber;
    unchecked {
      paramsContract["nonce"]++;
    }
    return uint8(randomnumber);
  }

  ///@notice Return the metadatas of a token, essential for opensea and other platforms
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  ///@notice Update the uri of tokens metadatas
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  ///@notice Return the metadatas of a token, essential for opensea and other platforms
  function tokenURI(
    uint256 tokenId
  ) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    string memory currentBaseURI = _baseURI();
    return
      bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  ///@notice very important function that we add on almost all the other functions to check that the call of the functions is done well since the contract of delegation for more security
  modifier byProxy() {
    require(
      (_msgSender() == addressProxyContract || addressProxyContract == address(0)) &&
        !paused,
      "Not good proxy contract"
    );
    _;
  }

  ///@notice Pause the contract in case of problems
  function pause(bool _state) external onlyOwner {
    paused = _state;
  }

  ///@notice Function of mint token
  ///@param receiver receiver address of token _requireMinted
  ///@param params8 array uint8 used for stats
  ///@param params256 array uint256 used for complex parameter
  ///@param _tokenURI uri of metadatas token
  function mint(
    address receiver,
    uint8[] calldata params8,
    uint256[] calldata params256,
    string calldata _tokenURI
  ) external payable byProxy {
    _tokenDetails[paramsContract["nextId"]] = HeroLib.Token(params8, params256);
    _safeMint(receiver, paramsContract["nextId"]);
    _setTokenURI(paramsContract["nextId"], _tokenURI);
    unchecked {
      paramsContract["nextId"]++;
    }
    unchecked {
      paramsContract["totalSupply"]++;
    }
  }

  ///@notice Burn a token with its id and decrease the total supply
  function burn(uint256 tokenId) external byProxy {
    paramsContract["totalSupply"]--;
    _burn(tokenId);
  }

  ///@notice Transfer a token from one address to another using the token id
  function transfer(address from, address to, uint256 tokenId) external byProxy {
    _safeTransfer(from, to, tokenId, "");
  }

  ///@notice Retrieve in a table all the ids token of a user
  ///@param user address of user own token
  ///@return ids ids token of user
  function getAllTokensForUser(address user) external view returns (uint256[] memory) {
    uint256 tokenCount = balanceOf(user);
    if (tokenCount == 0) {
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](tokenCount);
      uint256 totalTokens = paramsContract["nextId"];
      uint256 resultIndex;
      uint256 i;
      for (i = 0; i < totalTokens; i++) {
        if (ownerOf(i) == user) {
          result[resultIndex] = i;
          unchecked {
            resultIndex++;
          }
        }
      }
      return result;
    }
  }

  ///@notice Update the token (hero) in case of level up for example by using the id as key and sending directly the object of the token update
  ///@param tokenTemp structure of token you want to return
  ///@param tokenId id of token you want to update
  ///@param owner sender of tx origin by proxyContract
  function updateToken(
    HeroLib.Token calldata tokenTemp,
    uint256 tokenId,
    address owner
  ) external byProxy {
    require(ownerOf(tokenId) == owner, "Not Your token");
    _tokenDetails[tokenId] = tokenTemp;
  }

  ///@notice Retrieve data from a token using its id
  ///@param tokenId key id of token
  ///@return token structure of token
  function getTokenDetails(uint256 tokenId) external view returns (HeroLib.Token memory) {
    return _tokenDetails[tokenId];
  }

  ///@notice Update one of the cotnrat data using the key
  ///@param key key index of parameter you want to return
  ///@param value value you want to set
  function setParamsContract(string calldata key, uint256 value) external onlyOwner {
    paramsContract[key] = value;
  }

  ///@notice Retrieve one of the contract data using the key
  ///@param key key index of parameter you want to return
  ///@return paramContract value of parameter
  function getParamsContract(string calldata key) external view returns (uint256) {
    return paramsContract[key];
  }

  ///@notice modify the address of the delegation contract to allow the said contract to interact with this one
  ///@param _address address of proxy contract
  function setAddressProxyContract(address _address) external onlyOwner {
    addressProxyContract = _address;
  }

  ///@notice FUNDS OF CONTRACT

  function withdraw() external onlyOwner {
    payable(_msgSender()).transfer(address(this).balance);
  }
}
