# MYOS SMART CONTRACTS

### Install library dependancies for local test

```bash
yarn
```

### Start local network with ganache

```bash
yarn ganache
```

### All available commands

The package.json file contains a set of scripts to help on the development phase. Below is a short description for each

- **"ganache"** run local node (development network) with ganache-cli
- **"migrate"** run migration on development network
- **"test"** run tests locally
- **"test:ci"** run tests in CI system
- **"lint:sol"** lint solidity code according to rules
- **"lint:js"** lint javascript code according to rules
- **"lint"** lint solidity code
- **"truffle test -- -g "name of test""** run specific test

### Solhint

[You can find rules and explanations here](https://github.com/protofire/solhint/blob/master/docs/rules.md)


# CONTRACTS

## DELEGATECONTRACT.SOL

```javascript
// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

interface IDelegateContract {
  ///@notice Create a guild by also deleting its contract
  ///@param _by user for found addresses of your contract by creator mapping
  ///@param name name of your created contract
  ///@param symbol name of your created contract
  function createGuild(address _by, string memory name, string memory symbol) external;

  ///@notice return one guild by address creator
  ///@param _by user for found addresses of your contract by creator mapping
  ///@return addressContract address of the contract guild
  function getOneGuildAddress(address _by) external view returns (address);

  ///@notice return all guilds addresses
  ///@return return an array of address for all guilds created
  function getAddressesGuilds() external view returns (address[] memory);

  ///@notice Update a parameter of contract
  ///@param key key index of params contract you want set
  ///@param value value of params contract you want set
  function setParamsContract(string memory key, uint256 value) external;

  ///@notice Return a parameter of contract by key index
  ///@param key key index of param your want to return
  ///@return param value of parameter contract
  function getParamsContract(string memory key) external view returns (uint256);

  ///@notice convert of a resource for another token
  function convertToAnotherToken(uint256 value, address anotherToken) external;

  ///@notice purchase of a resource for eth/MATIC
  ///@param quantity count of item you want purchase
  ///@param receiver receiver address of token
  ///@param tokenId id of item
  function buyItem(uint256 quantity, address receiver, uint256 tokenId) external payable;

  ///@notice sell of a resource for eth/MATIC
  ///@param quantity count of item you want purchase
  ///@param tokenId id of item
  function sellItem(uint256 quantity, uint256 tokenId) external;

  ///@notice mint a hero for a value price and generate stats and parameterr
  ///@param generation generation of creation hero
  ///@param peuple peuple with class and stat linked
  ///@param _tokenUri uri of metadata token hero
  function mintHero(
    uint8 generation,
    uint8 peuple,
    string memory _tokenUri
  ) external payable;

  ///@notice start a quest by id for one hero token
  ///@param tokenId id of token you want to launch in quest
  ///@param questId id of quest you want to start
  function startQuest(uint256 tokenId, uint256 questId) external;

  ///@notice Validation of the quest at the end of a quest
  ///@param tokenId id of token you want to complete quest
  function completeQuest(uint256 tokenId) external;

  ///@notice level up hero and increment one stat
  ///@param statToLvlUp id of stat you wan increment
  ///@param tokenId id of token you want level up
  function levelUp(uint8 statToLvlUp, uint256 tokenId) external;

  function withdraw() external;
}

```

## CLASS.SOL

```javascript
pragma solidity ^0.8.0;

import "../library/LClass.sol";

interface IClass {
  function setClass(
    uint8 _id,
    uint8 rarity,
    uint8[] memory stats,
    string memory name
  ) external;

  function removeClass(uint8 _id) external;

  function getClassStatsDetails(uint8 classId) external view returns (uint8[] memory);

  function getClassDetails(uint8 classId) external view returns (ClassLib.Classes memory);

  function getClassCount() external view returns (uint8);

  function getAllClass() external view returns (ClassLib.Classes[] memory);
```

## HERO.SOL

```javascript
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
  ///@param _tokenURI uri of metadatas token
  function mint(
    address receiver,
    uint8[] memory params8,
    uint256[] memory params256,
    string memory _tokenURI
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
  ///@param owner sender of tx origin by delegateContract
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
  ///@param _address address of delegate contract
  function setAddressDelegateContract(address _address) external;

  ///@notice FUNDS OF CONTRACT
  function withdraw() external;
}

```

## MYOS.SOL

```javascript
// SPDX-License-Identifier: MIT
// Items Contract
pragma solidity ^0.8.0;

interface IMYOS {
  ///@notice modify the address of the delegation contract to allow the said contract to interact with this one
  ///@param _address new address of delegation contract
  function setAddressDelegateContract(address _address) external;

  ///@notice Function of mint token
  ///@param to address of receiver's item
  ///@param quantity mint a guantity of item
  function mint(address to, uint256 quantity) external;

  ///@notice Function of burn token
  ///@param to address of burner's item
  ///@param quantity mint a guantity of item
  function burn(address to, uint256 quantity) external;

  ///@notice Withdraw funds of this contract to an address wallet
  function withdraw() external;

  ///@notice Pause mint of token between address before time pausedMintEndDate
  ///@param time timestamp until which the contract will be paused for mint
  function setPausedMintEndDate(uint256 time) external;

  ///@notice Pause transfer of token between address before time pausedTransferEndDate
  ///@param time timestamp until which the contract will be paused for transfer
  function setPausedTransferEndDate(uint256 time) external;
}

```

## QUEST.SOL

```javascript
// SPDX-License-Identifier: MIT
// Quest Contract
pragma solidity ^0.8.0;

import "../library/LQuest.sol";

interface IQuest {
  ///@notice create or update quest
  ///@param id id key of quest you want to upsert
  ///@param time during of quest for complete them
  ///@param exp experience gained to complete quest
  ///@param percentDifficulty difficulty of quest 0 - 100 %
  ///@param stats stats needed to complete quest (malus - bonus)
  ///@param items array of items win in complete quest
  function setQuest(
    uint256 id,
    uint256 time,
    uint16 exp,
    uint8 percentDifficulty,
    uint8[] memory stats,
    uint8[] memory items
  ) external;

  ///@notice remove a quest by id
  ///@param questId key index of quest you want delete
  function removeQuest(uint256 questId) external;

  ///@notice return detail of one quest
  ///@param questId id key of quest you want to return
  ///@return questDetail quest structure
  function getQuestDetails(
    uint256 questId
  ) external view returns (QuestLib.QuestStruct memory);

  function getMultiplicateurExp() external view returns (uint8);

  ///@notice Retrieve in a table ids of quest
  ///@return result array of uint256
  function getAllQuests() external view returns (uint256[] memory);
}

```


## ITEMS.SOL

```javascript
// SPDX-License-Identifier: MIT
// Items Contract
pragma solidity ^0.8.0;

import "../library/LItems.sol";

interface IItems {
  ///@notice create or update quest
  ///@param name name of item
  ///@param rarity rarity to loot this item
  ///@param price price of item in wei
  ///@param id id of item you want to set
  function setItem(
    string memory name,
    uint256 rarity,
    uint256 price,
    uint256 id
  ) external;

  function getSupply(uint256 tokenId) external view returns (uint256);

  ///@notice modify the address of the delegation contract to allow the said contract to interact with this one
  ///@param _address new address of delegation contract
  function setaddressDelegateContract(address _address) external;

  ///@notice Function of mint token
  ///@param to address of receiver's item
  ///@param tokenId token id you want to mint
  ///@param amount mint a quantity of item
  function mint(address to, uint256 tokenId, uint256 amount) external payable;

  ///@notice Function of burn token
  ///@param to address of burner's item
  ///@param tokenId token id you want to burn
  ///@param amount mint a quantity of item
  function burn(address to, uint256 tokenId, uint256 amount) external;

  ///@notice Get item structure detail
  ///@param tokenId token id you want to return
  ///@return item stucture Item attached to tokenId
  function getItemDetails(uint256 tokenId) external view returns (ItemsLib.Item memory);
}

```
