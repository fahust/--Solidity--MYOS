<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->

<a name="readme-top"></a>

# MY0S SMART CONTRACTS

![MY0S](./doc/Myos.png?raw=true "MY0S")

<!-- TABLE OF CONTENTS -->
<details open>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
        <li><a href="#white-paper">White Paper</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#available-commands">Available Commands</a></li>
        <li><a href="#test-contract">Test Contracts</a></li>
        <li><a href="#good-practices">Solidity Good Practices</a></li>
      </ul>
    </li>
    <li>
      <a href="#contracts">Proxy Contracts</a>
      <ul>
        <li><a href="#proxy-hero">Proxy Hero</a></li>
        <li><a href="#proxy-myos">Proxy Myos</a></li>
        <li><a href="#proxy-items">Proxy Items</a></li>
        <li><a href="#proxy-equipments">Proxy Equipments</a></li>
      </ul>
    </li>
    <li>
      <a href="#contracts">Immutable Contracts</a>
      <ul>
        <li><a href="#class-contract">Class Contract</a></li>
        <li><a href="#hero-contract">Hero Contract</a></li>
        <li><a href="#myos-contract">MYOS Token Contract</a></li>
        <li><a href="#quest-contract">Quest Contract</a></li>
        <li><a href="#item-contract">Items Contract</a></li>
        <li><a href="#item-contract">Equipments Contract</a></li>
      </ul>
    </li>
    <li>
      <a href="#external-call">External Calls</a>
    </li>
  </ol>
</details>

<a name="about-the-project"></a>

## About The Project

The **MY0S** project orientation is inspired by an analog technique from the Metaverse: the **RpVerse**. At a time when the Metaverse is not operational, but is rather an out-of-body experience where the senses make the mind travel to unknown places, we have concentrated our resources on character embodiment within a universe imagined from scratch by a team of enthusiasts.

Therefore, the **RpVerse** offers many advantages for the audience. The game is accessible as long as you have a browser and an internet connection.

You don’t need an expensive VR headset or a high-speed internet connection to play our game.

Playing an existing character in a fantastical universe, that’s what the **MY0S** project is offering to its playerbase. The opportunity to interact with a community, making impactful decisions that will influence your progression, be it as a lone wolf or as a united group..

Beyond character incarnation, progression and character evolution are the flagship concepts of the project .

The **Damnos**, **Ylldrase** or **Ark-IA** playable character will earn experience and progress over time, thus increasing its value.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<p align="center" width="100%"><img align="center" src="./doc/hero1.png?raw=true" /></p>

<a name="white-paper"></a>

## White Paper

[You can found here a white paper of the project](https://my0s.io/wp-content/uploads/2022/10/Eng-Whitepaper-MY0S-V2209.pdf)

<a name="built-with"></a>

## Built With

- **Solidity Version** 0.8.11
- **truffle** 5.6.3
- **prettier-plugin-solidity** 1.0.0-rc.1
- **web3-onboard** 2.10.0
- **openzeppelin/contracts** 4.4.1
- **slither**
- **mythril**

<a name="getting-started"></a>

## Getting Started

First of all you will need to install all the libraries to be able to launch the project, you can do it with npm or yarn.

```bash
yarn
```

```bash
npm i
```

<a name="prerequisites"></a>

## Prerequisites

Install [Ganache](https://trufflesuite.com/ganache/) locally, and start local network with them.

```bash
yarn ganache
```

```bash
npm run ganache
```

<a name="available-commands"></a>

## Available commands

The **package.json** file contains a set of scripts to help on the development phase. Below is a short description for each

- **"ganache"** run local node (development network) with ganache-cli
- **"migrate"** run migration on development network
- **"test"** run tests locally
- **"test:ci"** run tests in CI system
- **"test:MYOS"** run tests in myos contract
- **"test:HERO"** run tests in hero / items / quest / classes contract
- **"lint:sol"** lint solidity code according to rules
- **"lint:js"** lint javascript code according to rules
- **"lint"** lint solidity code
- **"truffle test -- -g "name of test""** run specific test

### Solhint

[You can find rules and explanations here](https://github.com/protofire/solhint/blob/master/docs/rules.md)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<a name="test-contract"></a>

## Tests Contracts

We test every function of our contracts in every possible context.
We use **mocha** and **eth-gaz-reporter** to perform our tests and get a visual rendering of the **gas costs** and the price in euros depending on the current network congestion and the price of ethereum.

<p align="center" width="100%"><img align="center" src="./doc/testMyos.png?raw=true" /></p>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<a name="good-practices"></a>

## Solidity Good Practices


| Ref | Description |
| --- | --- |
| [Zero knowledge proof](https://docs.zksync.io/userdocs/) | Accelerating the mass adoption of crypto for personal sovereignty |
| [byte32](https://ethereum.stackexchange.com/questions/11556/use-string-type-or-bytes32) | Use strings for dynamically allocated data, otherwise Byte32 is going to perform better. Bytes32 is also going to be better in gas |
| [Use uint instead bool](https://ethereum.stackexchange.com/questions/39932/solidity-bool-size-in-structs) | It's more efficient to pack multiple booleans in a uint256, and extract them with a mask. You can store 256 booleans in a single uint256 |
| [.call()](https://medium.com/coinmonks/solidity-transfer-vs-send-vs-call-function-64c92cfc878a) | using call, one can also trigger other functions defined in the contract and send a fixed amount of gas to execute the function. The transaction status is sent as a boolean and the return value is sent in the data variable. |
| [Interfaces](https://www.tutorialspoint.com/solidity/solidity_interfaces.htm) | Interfaces are most useful in scenarios where your dapps require extensibility without introducing added complexity |
| [Change State Local Variable](https://ethereum.stackexchange.com/questions/118754/is-it-more-gas-efficient-to-declare-variable-inside-or-outside-of-a-for-or-while) | It's cheaper to to declare the variable outside the loop |
| [CallData](https://medium.com/coinmonks/solidity-storage-vs-memory-vs-calldata-8c7e8c38bce) | It is recommended to try to use calldata because it avoids unnecessary copies and ensures that the data is unaltered |
| [Pack your variables](https://mudit.blog/solidity-gas-optimization-tips/) | Packing is done by solidity compiler and optimizer automatically, you just need to declare the packable functions consecutively |
| [Type Function Visibility](https://www.ajaypalcheema.com/function-visibility-in-solidty/#:~:text=There%20are%20four%20types%20of,internal%20%2C%20private%20%2C%20and%20public%20.&text=private%20modifier%20specifies%20that%20this,by%20children%20inheriting%20the%20contract.) |  This is the most restrictive visibility and more gas efficient |
| [Delete Variable](https://mudit.blog/solidity-gas-optimization-tips/) | If you don’t need a variable anymore, you should delete it using the delete keyword provided by solidity or by setting it to its default value |
| [Immutable / constant variable](https://dev.to/jamiescript/gas-saving-techniques-in-solidity-324c) | Use constant and immutable variables for variable that don't change |
| [Unchecked state change](https://www.linkedin.com/pulse/optimizing-smart-contract-gas-cost-harold-achiando/) | Add unchecked {} for subtractions where the operands cannot underflow |
| [Use revert instead of require](https://dev.to/jamiescript/gas-saving-techniques-in-solidity-324c) | Using revert instead of require is more gas efficient |
| [Index events](https://ethereum.stackexchange.com/questions/8658/what-does-the-indexed-keyword-do) | The indexed parameters for logged events will allow you to search for these events using the indexed parameters as filters |
| [Mythril](https://mythril-classic.readthedocs.io/en/master/about.html) | Mythril is a security analysis tool for Ethereum smart contracts |
| [Slither](https://medium.com/coinmonks/automated-smart-contract-security-review-with-slither-1834e9613b01) | Automated smart contract security review with Slither |
| [Reporter gaz](https://www.npmjs.com/package/eth-gas-reporter) | Gas usage per unit test |
| [Hyper ledger factory](https://www.ibm.com/fr-fr/topics/hyperledger) | Hyperledger Fabric, an open source project from the Linux Foundation, is the modular blockchain framework and de facto standard for enterprise blockchain platforms. |
| [Chain link](https://docs.chain.link/getting-started/consuming-data-feeds) | Oracles provide a bridge between the real-world and on-chain smart contracts by being a source of data that smart contracts can rely on, and act upon |
| [UniSwap](https://docs.uniswap.org/sdk/guides/quick-start) | |
| [Reentrancy](https://solidity-by-example.org/hacks/re-entrancy/) | The Reentrancy attack is one of the most destructive attacks in the Solidity smart contract. A reentrancy attack occurs when a function makes an external call to another untrusted contract |
| [Front Running](https://coinsbench.com/front-running-hack-solidity-10-57d0765d0179) | The attacker can execute something called the Front-Running Attack wherein, they basically prioritize their transaction over other users by setting higher gas fees |
| [Delegate Call](https://coinsbench.com/unsafe-delegatecall-part-1-hack-solidity-5-81d5f295edb6) | In order to update the owner of the HackMe contract, we pass the function signature of the pwn function via abi.encodeWithSignature(“pwn()”) from the malicious contract |
| [Self Destruct](https://hackernoon.com/how-to-hack-smart-contracts-self-destruct-and-solidity) | an attacker can create a contract with a selfdestruct() function, send ether to it, call selfdestruct(target) and force ether to be sent to a target |
| [Block Timestamp Manipulation](https://cryptomarketpool.com/block-timestamp-manipulation-attack/) | To prevent this type of attack do not use block.timestamp in your contract or follow the 15 second rule. The 15 second rule states |
| [Phishing with tx.origin](https://hackernoon.com/hacking-solidity-contracts-using-txorigin-for-authorization-are-vulnerable-to-phishing) | Let’s say a call could be made to the vulnerable contract that passes the authorization check since tx.origin returns the original sender of the transaction which in this case is the authorized account |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<a name="contracts"></a>

<p align="center" width="100%"><img align="center" src="./doc/hero2.png?raw=true" /></p>

# PROXY CONTRACTS

<a name="proxy-hero"></a>

## ProxyHero.SOL

This contract is used as a proxy to the contract :

- Class.sol
- Items.sol
- Hero.sol
- Quest.sol

> **Warning** > **These contracts are not deletable once deployed because they contain the tokens of the users and their linked datas (especially for the heroes)**

To modify as much as necessary the functions of call towards these contracts which cannot be removed, we placed the logic of code in the contract proxy which does not contain any datas, only logic of functions and can thus be replaced without risk of data loss.

| Name Function | Description Function |
| --- | --- |
| `setParamsContract(string memory key, uint256 value)` | Update a parameter of contract |
| `getParamsContract(string memory key)` | Return a parameter of contract by key index |
| `mintHero(uint8 generation, uint8 peuple, string memory tokenUri) payable` | Mint a hero for a value price and generate stats and parameter |
| `startQuest(uint256 tokenId, uint256 questId)` | Start a quest by id for one hero token |
| `completeQuest(uint256 tokenId)` | Validation of the quest at the end of a quest |
| `levelUp(uint8 statToLvlUp, uint256 tokenId)` | Level up hero and increment one stat |
| `putHeroInSell(uint256 tokenId, uint256 price)` | Put hero in sell market |
| `getHerosInSell()` | Return all heroes in market sell |
| `purchase(uint256 tokenId)` | Purchase a token previously put in sell |
| `cancelQuest(uint256 tokenId)` | Cancel a quest by id for one hero token |

<details>
  <summary>Code Interface</summary>
  <p>
  
```javascript
// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

interface IProxyHero {
///@notice Update a parameter of contract
///@param key key index of params contract you want set
///@param value value of params contract you want set
function setParamsContract(string memory key, uint256 value) external;

///@notice Return a parameter of contract by key index
///@param key key index of param your want to return
///@return param value of parameter contract
function getParamsContract(string memory key) external view returns (uint256);

///@notice mint a hero for a value price and generate stats and parameter
///@param generation generation of creation hero
///@param peuple peuple with class and stat linked
///@param \_tokenUri uri of metadata token hero
function mintHero(
uint8 generation,
uint8 peuple,
string memory \_tokenUri
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

///@notice put hero in sell market
///@param tokenId id key of token you want to putt in sell
///@param price price of token put in selled
function putHeroInSell(uint256 tokenId, uint256 price) external;

///@notice return all heroes in market sell
///@return tokens return structure of heroes
function getHerosInSell() external view returns (HeroLib.Token[] memory);

///@notice purchase a token previously put in sell
///@param tokenId id of token you want buy
function purchase(uint256 tokenId) external payable;

///@notice cancel a quest by id for one hero token
///@param tokenId id of token you want to launch in quest
function cancelQuest(uint256 tokenId) external;
}

```
  </p>
</details>


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<a name="proxy-myos"></a>

## ProxyMYOS.SOL

This contract is used as a proxy to the contract Myos.sol

> **Warning**
> **This contracts are not deletable once deployed because they contain the tokens of the users**

To modify as much as necessary the functions of call towards these contracts which cannot be removed, we placed the logic of code in the contract proxy which does not contain any datas, only logic of functions and can thus be replaced without risk of data loss.

| Name Function | Description Function |
| --- | --- |
| `setCurrentPriceMYOS(uint256 newPrice)` | Update price of MYOS token for static price, if == 0 change for dynamic price |
| `setAddressMYOSToken(address _addressMYOSToken)` | Update the destination address of the official contract MYOS token so that the delegation contract can access it |
| `setMerkleTree(bytes32 _merkleRoot, uint256 _merkleEndTime)` | Set the merkle tree to create whitelist for mint |
| `buyMYOS(uint256 quantity, address receiver, bytes32[] calldata _proofs, uint256 _proofMaxQuantityPerTransaction)` | Purchase of a resource for eth/MATIC |
| `sellMYOS(uint256 quantity)` | Sale of MYOS token against MATIC |
| `convertMYOSToAnotherToken(uint256 quantity, address anotherToken)` | Converting the MYOS to another token |
| `getDynamicPriceMYOS()` | Function to calculate dynamic price |

<details>
  <summary>Code Interface</summary>
  <p>

```javascript
// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

interface IProxyMyos {
  ///@notice Update price of MYOS token for static price, if == 0 change for dynamic price
  ///@param newPrice value of price in matic wei (matic / 10**18)
  function setCurrentPriceMYOS(uint256 newPrice) external;

  ///@notice Update the destination address of the official contract MYOS token so that the delegation contract can access it
  ///@param _addressMYOSToken address of contract MYOS
  function setAddressMYOSToken(address _addressMYOSToken) external;

  ///@notice Set the merkle tree to create whitelist for mint
  ///@param _merkleRoot A bytes 32 represent root of tree for verify all merkle proof
  ///@param _merkleEndTime Represent a timestamp (in seconds) represents end of whitelist
  function setMerkleTree(bytes32 _merkleRoot, uint256 _merkleEndTime) external;

  ///@notice Purchase of a resource for eth/MATIC
  ///@param quantity number of token myos you want purchase
  ///@param receiver address waller of receiver's token
  function buyMYOS(
    uint256 quantity,
    address receiver,
    bytes32[] calldata _proofs,
    uint256 _proofMaxQuantityPerTransaction
  ) external payable;

  ///@notice Sale of MYOS token against MATIC
  ///@param quantity number of token myos you want sell
  function sellMYOS(uint256 quantity) external;

  ///@notice Converting the MYOS to another token
  ///@param quantity number of token myos you want convert
  ///@param anotherToken address of token you want to convert
  function convertMYOSToAnotherToken(uint256 quantity, address anotherToken) external;

  ///@notice Function to calculate dynamic price
  function getDynamicPriceMYOS() external view returns (uint256);
}

```

  </p>
</details>

<a name="proxy-items"></a>

## ProxyITEMS.SOL

This contract is used as a proxy to the contract Items.sol

> **Warning** 
> **This contracts are not deletable once deployed because they contain the tokens of the users**

To modify as much as necessary the functions of call towards these contracts which cannot be removed, we placed the logic of code in the contract proxy which does not contain any datas, only logic of functions and can thus be replaced without risk of data loss.

| Name Function | Description Function |
| --- | --- |
| `buyItem(uint256 quantity, address receiver, uint256 tokenId)` | purchase of a resource for eth/MATIC |
| `sellItem(uint256 quantity, uint256 tokenId)` | sell of a resource for eth/MATIC |
| `convertToAnotherToken(address receiver, uint256 quantity, uint256 fromTokenId, uint256 toTokenId)` | convert of a resource for another token |
| `calculConversionQuantity(uint firstTokenPrice, uint twoTokenPrice, uint quantity)` | calcul price in myos token of conversion |

<details>
  <summary>Code Interface</summary>
  <p>

```javascript
// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

interface IProxyItems {
  ///@notice purchase of a resource for eth/MATIC
  ///@param quantity count of item you want purchase
  ///@param receiver receiver address of token
  ///@param tokenId id of item
  function buyItem(uint256 quantity, address receiver, uint256 tokenId) external payable;

  ///@notice sell of a resource for eth/MATIC
  ///@param quantity count of item you want purchase
  ///@param tokenId id of item
  function sellItem(uint256 quantity, uint256 tokenId) external;

  ///@notice convert of a resource for another token
  ///@param receiver address of receiver toToken minted
  ///@param quantity quantity of fromToken burned for same quantity burned
  ///@param fromTokenId id of token burned
  ///@param toTokenId if of token minted
  function convertToAnotherToken(
    address receiver,
    uint256 quantity,
    uint256 fromTokenId,
    uint256 toTokenId
  ) external;

  function withdraw() external;

  function calculConversionQuantity(
    uint firstTokenPrice,
    uint twoTokenPrice,
    uint quantity
  ) external pure returns (uint256);
}

```

  </p>
</details>

<a name="proxy-equipments"></a>

## ProxyEQUIPMENTS.SOL

This contract is used as a proxy to the contract Equipments.sol

> **Warning** > **This contracts are not deletable once deployed because they contain the tokens of the users**

To modify as much as necessary the functions of call towards these contracts which cannot be removed, we placed the logic of code in the contract proxy which does not contain any datas, only logic of functions and can thus be replaced without risk of data loss.

| Name Function | Description Function |
| --- | --- |
| `craft(uint256 tokenId, address receiver)` | Craft an equipments with different items |
| `putInSell(uint256 tokenId, uint256 price)` | put equipment in sell market |
| `getInSell()` | return all equipment in sell in market sell |
| `purchase(uint256 id, uint256 tokenId, address receiver)` | purchase a token previously put in sell |
| `buyEquipment(uint256 quantity, address receiver, uint256 tokenId)` | purchase of a resource for eth/MATIC |
| `sellEquipment(uint256 quantity, uint256 tokenId)` | sell of a resource for eth/MATIC |
| `convertToAnotherToken(address receiver, uint256 quantity, uint256 fromTokenId, uint256 toTokenId)` | convert of a resource for another token |
| `calculConversionQuantity(uint firstTokenPrice, uint twoTokenPrice, uint quantity)` | Calcul price in myos token of conversion |

<details>
  <summary>Code Interface</summary>
  <p>

```javascript
// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

interface IProxyEquipments {
  ///@notice Craft an equipments with different items 
  function craft(uint256 tokenId, address receiver) external;

  ///@notice put equipment in sell market
  ///@param tokenId id key of token you want to putt in sell
  ///@param price price of token put in selled
  function putInSell(uint256 tokenId, uint256 price) external;

  //function stopSell()

  ///@notice return all equipment in sell in market sell
  ///@return tokens return array structure of equipment
  function getInSell() external view returns (EquipmentsLib.EquipmentInSell[] memory);

  ///@notice purchase a token previously put in sell
  ///@param id id of key array of equipmentsInSell mapping you want buy
  ///@param tokenId id key of token you want to buy
  function purchase(uint256 id, uint256 tokenId, address receiver) external payable;

  ///@notice purchase of a resource for eth/MATIC
  ///@param quantity count of equipment you want purchase
  ///@param receiver receiver address of token
  ///@param tokenId id of equipment
  function buyEquipment(
    uint256 quantity,
    address receiver,
    uint256 tokenId
  ) external payable;

  ///@notice sell of a resource for eth/MATIC
  ///@param quantity count of equipment you want purchase
  ///@param tokenId id of equipment
  function sellEquipment(uint256 quantity, uint256 tokenId) external;

  ///@notice convert of a resource for another token
  ///@param receiver address of receiver toToken minted
  ///@param quantity quantity of fromToken burned for same quantity burned
  ///@param fromTokenId id of token burned
  ///@param toTokenId if of token minted
  function convertToAnotherToken(
    address receiver,
    uint256 quantity,
    uint256 fromTokenId,
    uint256 toTokenId
  ) external;

  function withdraw() external;

  function calculConversionQuantity(
    uint firstTokenPrice,
    uint twoTokenPrice,
    uint quantity
  ) external pure returns (uint256);
}

```

  </p>
</details>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# IMMUTABLE CONTRACTS

> **Warning**
> Be careful, these contracts cannot be deleted once deployed because they contain user tokens, or data that must be kept for the proper use of the game.

<a name="class-contract"></a>

## CLASS.SOL

This contract is a utility contract allowing to create classes and to use them to the creation of HERO token.

| Name Function | Description Function |
| --- | --- |
| `setClass(uint8 _id, uint8 rarity, uint8[] memory stats, string memory name)` | set a parameter class |
| `removeClass(uint8 _id)` | |
| `getClassStatsDetails(uint8 classId)` | |
| `getClassDetails(uint8 classId)` | |
| `getClassCount()` | |
| `getAllClass()` | |

<details>
  <summary>Code Interface</summary>
  <p>

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

  </p>
</details>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<a name="hero-contract"></a>

## HERO.SOL

This contract contains the characters of MYOS users, they are erc721 tokens with their characteristics, they can be mint, burn, exchange or sold.

| Name Function | Description Function |
| --- | --- |
| `setBaseURI(string memory _newBaseURI)` | Update the uri of tokens metadatas |
| `pause(bool _state)` | Pause the contract in case of problems |
| `mint(address receiver, uint8[] memory params8, uint256[] memory params256, string memory _tokenURI)` | Function of mint token |
| `burn(uint256 tokenId)` | Burn a token with its id and decrease the total supply |
| `transfer(address from, address to, uint256 tokenId)` | Transfer a token from one address to another using the token id |
| `getAllTokensForUser(address user)` | Retrieve in a table all the ids token of a user |
| `updateToken(HeroLib.Token memory tokenTemp, uint256 tokenId, address owner)` | Update the token (hero) in case of level up for example by using the id as key and sending directly the object of the token update |
| `getTokenDetails(uint256 tokenId)` | Retrieve data from a token using its id |
| `setParamsContract(string memory key, uint256 value))` | Update one of the cotnrat data using the key |
| `getParamsContract(string memory key)` | Retrieve one of the contract data using the key |
| `setAddressDelegateContract(address _address)` | Modify the address of the delegation contract to allow the said contract to interact with this one |

<details>
  <summary>Code Interface</summary>
  <p>

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

  </p>
</details>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<a name="myos-contract"></a>

## MYOS.SOL

This contract contains the MYOS token of users, they are erc20 tokens, they can be mint, burn, win, exchange or sold.

| Name Function | Description Function |
| --- | --- |
| `setAddressDelegateContract(address _address)` | Modify the address of the delegation contract to allow the said contract to interact with this one |
| `mint(address to, uint256 quantity)` | Function of mint token |
| `burn(address to, uint256 quantity)` | Function of burn token |
| `setPausedMintEndDate(uint256 time)` | Pause mint of token between address before time pausedMintEndDate |
| `setPausedTransferEndDate(uint256 time)` | Pause transfer of token between address before time pausedTransferEndDate |

<details>
  <summary>Code Interface</summary>
  <p>

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

  </p>
</details>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<a name="quest-contract"></a>

## QUEST.SOL

The quest contract contains the missions of the game set up and prepared to be called from the delegation contract, each mission has its chances of success, its reward items, and its duration.

| Name Function | Description Function |
| --- | --- |
| `setQuest(uint256 id, uint256 time, uint16 exp, uint8 percentDifficulty, uint8[] memory stats, uint8[] memory items)` | Create or update quest |
| `removeQuest(uint256 questId)` | Remove a quest by id |
| `getQuestDetails(uint256 questId)` | Return detail of one quest |
| `getAllQuests()` | Retrieve in a table ids of quest |

<details>
  <summary>Code Interface</summary>
  <p>

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

  </p>
</details>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<a name="item-contract"></a>

## ITEMS.SOL

This contract contains the items of MYOS users, they are erc1155 tokens with their characteristics, they can be mint, burn, exchange or sold.

| Name Function | Description Function |
| --- | --- |
| `setItem(string memory name, uint256 rarity, uint256 price, uint256 id)` | Create or update item |
| `getSupply(uint256 tokenId)` | Level up hero and increment one stat |
| `setaddressDelegateContract(address _address)` | Modify the address of the proxy contract to allow the said contract to interact with this one |
| `mint(address to, uint256 tokenId, uint256 amount)` | Function of mint token |
| `burn(address to, uint256 tokenId, uint256 amount)` | Function of burn token |
| `getItemDetails(uint256 tokenId)` | Get item structure detail |

<details>
  <summary>Code Interface</summary>
  <p>

```javascript
// SPDX-License-Identifier: MIT
// Items Contract
pragma solidity ^0.8.0;

import "../library/LItems.sol";

interface IItems {
  ///@notice create or update item
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

  ///@notice modify the address of the proxy contract to allow the said contract to interact with this one
  ///@param _address new address of proxy contract
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

  </p>
</details>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<a name="external-call"></a>

# EXTERNAL CALLS

All the call functions to MYOS contracts are in an object that you can find in the /MYOS folder

```javascript
import MYOSContract from "@abi/MYOS.json";
import ClassContract from "@abi/Class.json";
import DelegateContractMYOS from "@abi/DelegateContractMYOS.json";
import DelegateContract from "@abi/DelegateContract.json";
import HeroContract from "@abi/Hero.json";
import QuestContract from "@abi/Quest.json";
import ItemsContract from "@abi/Items.json";
import GuildContract from "@abi/Guild.json";
import { ethers } from "ethers";
import { ADDRESS_ENUM, CONTRACT_ENUM } from "@enums/enum";

export default class MYOS {
  provider!: ethers.providers.Web3Provider | ethers.providers.BaseProvider;
  signer!: ethers.providers.JsonRpcSigner | any;
  addressContract!: string;

  providerNode!: ethers.providers.BaseProvider;
  walletWithProvider!: ethers.Wallet;

  connectedWeb3 = false;
  testing = false;

  /**
   * Create an instance of contract with them you want interact
   * @param {CONTRACT_ENUM} type
   * @param {string} address
   * @returns {ethers.Contract} contract instance
   */
  contractInstance(type: CONTRACT_ENUM, address: string): ethers.Contract {
    return new ethers.Contract(
      address,
      this.abiContract(type),
      this.walletWithProvider ? this.walletWithProvider : this.signer,
    );
  }

  abiContract(type: CONTRACT_ENUM) {
    switch (type) {
      case CONTRACT_ENUM.CLASS:
        return ClassContract.abi;
      case CONTRACT_ENUM.DELEGATE:
        return DelegateContract.abi;
      case CONTRACT_ENUM.DELEGATEMYOS:
        return DelegateContractMYOS.abi;
      case CONTRACT_ENUM.GUILD:
        return GuildContract.abi;
      case CONTRACT_ENUM.HERO:
        return HeroContract.abi;
      case CONTRACT_ENUM.ITEMS:
        return ItemsContract.abi;
      case CONTRACT_ENUM.MYOS:
        return MYOSContract.abi;
      case CONTRACT_ENUM.QUEST:
        return QuestContract.abi;
      default:
        return MYOSContract.abi;
    }
  }

  /**
   * Return signed public address of current wallet
   * @returns {string} address wallet
   * @category UTILS
   */
  async getMySignedAddress(): Promise<string> {
    if (this.connectedWeb3) {
      return await this.signer.getAddress();
    } else if (this.testing === true) {
      return ADDRESS_ENUM.CONTRACT_CREATOR;
    } else {
      return "Not connected to web3";
    }
  }

  /**
   * Force await a transaction
   * @param tx
   */
  async waitTx(tx: ethers.ContractTransaction) {
    await tx.wait();
  }

  /**
   * Call smart contract DelegateContractMYOS.sol to buy a quantity of myos token
   * @param quantity
   * @param to
   * @param expectedProof
   * @param proofMaxQuantityPerTransaction
   * @returns
   */
  async buyMYOS(
    quantity: number,
    to = this.getMySignedAddress(),
    expectedProof = [],
    proofMaxQuantityPerTransaction = 0,
  ) {
    const contractInstance = this.contractInstance(
      CONTRACT_ENUM.DELEGATEMYOS,
      this.addressContract,
    );
    let price = +((await contractInstance.getCurrentpriceMYOS()) + "");
    if (price === 0) price = +((await contractInstance.getDynamicPriceMYOS()) + "");
    const tx = contractInstance.buyMYOS(
      quantity,
      to,
      expectedProof,
      proofMaxQuantityPerTransaction,
      {
        from: this.getMySignedAddress(),
        value: price * quantity,
      },
    );
    await this.waitTx(tx);
    return tx;
  }
}


```

<p align="right">(<a href="#readme-top">back to top</a>)</p>
