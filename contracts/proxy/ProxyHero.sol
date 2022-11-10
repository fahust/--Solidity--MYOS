// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../immutable/Items.sol";
import "../immutable/Class.sol";
import "../immutable/Quest.sol";
import "../immutable/Hero.sol";

import "../library/LClass.sol";
import "../library/LHero.sol";
import "../library/LItems.sol";
import "../library/LQuest.sol";

import "../interfaces/IProxyHero.sol";

//enum Numbers {strong,endurance,concentration,agility,charisma,stealth,exp,level,faction,classe}

contract ProxyHero is Ownable, IProxyHero, ReentrancyGuard {
  using SafeMath for uint;
  error NotEnoughEth(uint256 price, uint256 weiSended, uint256 tokenId, uint256 quantity);
  error NotEnoughEthHero(uint256 price, uint256 weiSended);
  error NotRemainingHero(uint256 tokenLimit, uint256 nextTokenIdToMint);
  error NotYourToken(address sender, address ownerOfToken, uint256 tokenId);
  error AlreadyInQuest(
    address sender,
    uint256 questId,
    uint256 currentQuestId,
    uint256 tokenId
  );
  error QuestNotFinished(
    uint256 blockTimestamp,
    uint256 heroQuestTime,
    uint256 currentQuestTime,
    uint256 tokenId
  );
  error NotEnoughExperience(
    uint256 experienceHero,
    uint256 experienceNeeded,
    uint256 tokenId
  );
  error NotAStat(uint256 statToLvlUp, uint256 tokenId);
  error SellMyosSendEth(address to, uint value);
  error TokenNotInSales(uint256 tokenId, uint256 price);
  error NotEnoughEthPurchase(uint256 tokenId, uint256 price, uint256 value);
  error AlreadyOwned(uint256 tokenId, address sender, address owner);
  error NotEnoughEnergy(address sender, uint256 questId, uint256 energy, uint256 tokenId);
  error NotInQuest(address sender, uint256 tokenId);

  address private addressHero;
  address private addressQuest;
  address private addressClass;
  address private addressItem;
  mapping(string => uint256) public paramsContract;

  uint256 private constant utilMathMultiply = 10000000;

  constructor(
    address _addressHero,
    address _addressQuest,
    address _addressClass,
    address _addressItem
  ) {
    addressHero = _addressHero;
    addressQuest = _addressQuest;
    addressClass = _addressClass;
    addressItem = _addressItem;
    paramsContract["nextTokenIdToMint"] = Hero(addressHero).getParamsContract(
      "nextTokenIdToMint"
    );
    paramsContract["price"] = 100000000000000000; //dev:100000000000000000000 == 100 eth
    paramsContract["totalPnt"] = 5;
    paramsContract["tokenLimit"] = 10000;
    paramsContract["nonce"] = 0;
    paramsContract["expForLevelUp"] = 100;
  }

  modifier isYourToken(uint256 tokenId) {
    Hero contrat = Hero(addressHero);
    if (contrat.ownerOf(tokenId) != _msgSender())
      revert NotYourToken({
        sender: _msgSender(),
        ownerOfToken: contrat.ownerOf(tokenId),
        tokenId: tokenId
      });
    _;
  }

  function unsafeInc(uint x) private pure returns (uint) {
    unchecked {
      return x + 1;
    }
  }

  ///@notice Update a parameter of contract
  ///@param key key index of params contract you want set
  ///@param value value of params contract you want set
  function setParamsContract(string calldata key, uint256 value) external onlyOwner {
    paramsContract[key] = value;
  }

  ///@notice Return a parameter of contract by key index
  ///@param key key index of param your want to return
  ///@return param value of parameter contract
  function getParamsContract(string calldata key) external view returns (uint256) {
    return paramsContract[key];
  }

  ///@notice Update a parameter of hero contract
  ///@param key key index of params contract you want set
  ///@param value value of params contract you want set
  function setParamsHeroContract(string calldata key, uint256 value) internal {
    Hero contrat = Hero(addressHero);
    contrat.setParamsContract(key, value);
  }

  ///@notice mint a hero for a value price and generate stats and parameterr
  ///@param generation generation of creation hero
  ///@param faction faction with class and stat linked
  ///@param _tokenUri uri of metadata token hero
  function mintHero(
    uint8 generation,
    uint8 faction,
    string calldata _tokenUri
  ) external payable nonReentrant {
    require(msg.value >= paramsContract["price"], "More ETH required");
    if (msg.value < paramsContract["price"])
      revert NotEnoughEthHero({ price: paramsContract["price"], weiSended: msg.value });
    if (paramsContract["tokenLimit"] <= paramsContract["nextTokenIdToMint"])
      revert NotRemainingHero({
        tokenLimit: paramsContract["tokenLimit"],
        nextTokenIdToMint: paramsContract["nextTokenIdToMint"]
      });
    uint8[] memory randomParts = randomStats(faction);
    uint256[] memory randomParams = randomParameters(msg.value, generation);
    unchecked {
      paramsContract["nextTokenIdToMint"]++;
    }

    Hero contrat = Hero(addressHero);
    contrat.mint(_msgSender(), randomParts, randomParams, _tokenUri);
  }

  ///@notice generate stats for your hero in uint8
  ///@param faction faction of hero generated
  ///@return randomParts array of stats uint8 for hero
  function randomStats(uint8 faction) internal virtual returns (uint8[] memory) {
    uint8[] memory randomParts = new uint8[](20);

    Class classContrat = Class(addressClass);
    ClassLib.Classes memory class;
    class = classContrat.getClassDetails(0);
    for (uint8 index = 0; index < classContrat.getClassCount(); index++) {
      if (random(100) < classContrat.getClassDetails(index).rarity)
        class = classContrat.getClassDetails(index);
    }
    uint8[] memory stats = class.stats;

    randomParts[0] = stats[0]; //Strong
    randomParts[1] = stats[1]; //Stamina
    randomParts[2] = stats[2]; //Focus
    randomParts[3] = stats[3]; //Swiftness
    randomParts[4] = stats[4]; //Charisma
    randomParts[5] = stats[5]; //Stealth

    randomParts[8] = faction; //faction
    randomParts[9] = class.id; //class

    return randomParts;
  }

  ///@notice generate parameter for your hero in uint256
  ///@param price price of buying hero
  ///@param generation generation fo hero
  ///@return randomParams array of parameters uint256 for hero
  function randomParameters(
    uint256 price,
    uint8 generation
  ) internal virtual returns (uint256[] memory) {
    uint256[] memory randomParams = new uint256[](20);
    randomParams[0] = block.timestamp; //date de création
    randomParams[1] = price; //prix d'achat
    randomParams[2] = block.timestamp; //date de la dérnière action (il y a une heure) permettant de participer a des missions
    //randomParams[3] = 0;//Mission choisis (si 0 aucune current mission)
    //randomParams[4] = 0;//seconds pour finir la mission
    //randomParams[5] = 0;//difficulté de la quête (détermine l'exp gagné, et les objets % gagné)
    //randomParams[6] = 0;//last quest succeded
    randomParams[6] = paramsContract["nextTokenIdToMint"]; //tokenId
    randomParams[7] = generation; //type
    //randomParams[8] = 0;//exp
    randomParams[9] = 1; //level
    randomParams[10] = 100; //maxEnergy
    randomParams[11] = 0; //priceInSell
    return randomParams;
  }

  ///@notice start a quest by id for one hero token
  ///@param tokenId id of token you want to launch in quest
  ///@param questId id of quest you want to start
  function startQuest(uint256 tokenId, uint256 questId) external isYourToken(tokenId) {
    Hero contrat = Hero(addressHero);
    Quest questContrat = Quest(addressQuest);
    QuestLib.QuestStruct memory questTemp = questContrat.getQuestDetails(questId);
    HeroLib.Token memory hero = contrat.getTokenDetails(tokenId);
    if (hero.params256[4] != 0)
      revert AlreadyInQuest({
        sender: _msgSender(),
        questId: questId,
        currentQuestId: hero.params256[4],
        tokenId: tokenId
      });
    uint256 energy = block.timestamp - hero.params256[2];
    if (energy > hero.params256[10]) energy = hero.params256[10];
    if (energy < questTemp.time)
      revert NotEnoughEnergy({
        sender: _msgSender(),
        questId: questId,
        energy: energy,
        tokenId: tokenId
      });
    hero.params256[3] = questId;
    hero.params256[4] = questTemp.time;
    contrat.updateToken(hero, tokenId, _msgSender());
  }

  function cancelQuest(uint256 tokenId) external isYourToken(tokenId) {
    Hero contrat = Hero(addressHero);
    HeroLib.Token memory hero = contrat.getTokenDetails(tokenId);
    if (hero.params256[4] == 0)
      revert NotInQuest({ sender: _msgSender(), tokenId: tokenId });
    hero.params256[4] = 0;
    contrat.updateToken(hero, tokenId, _msgSender());
  }

  ///@notice Validation of the quest at the end of a quest
  ///@param tokenId id of token you want to complete quest
  function completeQuest(uint256 tokenId) external isYourToken(tokenId) {
    Hero contrat = Hero(addressHero);
    HeroLib.Token memory hero = contrat.getTokenDetails(tokenId);

    Quest questContrat = Quest(addressQuest);
    QuestLib.QuestStruct memory questTemp = questContrat.getQuestDetails(
      hero.params256[3]
    );
    if (block.timestamp - hero.params256[2] <= (questTemp.time))
      revert QuestNotFinished({
        blockTimestamp: block.timestamp,
        heroQuestTime: hero.params256[2],
        currentQuestTime: questTemp.time,
        tokenId: tokenId
      });
    uint8 malus = 0;
    for (uint8 index = 0; index < questTemp.stats.length; index++) {
      if (questTemp.stats[index] > hero.params8[index]) {
        malus += questTemp.stats[index] - hero.params8[index];
      }
    }
    ///SUCCESS QUEST
    uint256 percentSuccess = random(100 - malus);
    hero.params256[7] = percentSuccess;
    if (percentSuccess > questTemp.percentDifficulty) {
      hero.params256[6] = 1;
      hero.params256[8] += (questTemp.exp * questContrat.getMultiplicateurExp());

      Items itemContrat = Items(addressItem);

      for (uint256 index = 0; index < questTemp.items.length; index = unsafeInc(index)) {
        itemContrat.mint(_msgSender(), questTemp.items[index], 1);
      }
      //recuperer les items dans la quest !IMPORTANT
      /*for (uint256 index = 0; index < countItems;  index = unsafeInc(index) {
        Items itemtemp = Items(items[index]);
        if (random256(100000) > itemtemp.getRarity()) {
          itemtemp.mint(1, _msgSender());
        }
      }*/
    } else {
      hero.params256[6] = 0;
    }
    hero.params256[2] = block.timestamp;
    hero.params256[4] = 0;

    contrat.updateToken(hero, tokenId, _msgSender());
  }

  ///@notice level up hero and increment one stat
  ///@param statToLvlUp id of stat you wan increment
  ///@param tokenId id of token you want level up
  function levelUp(uint8 statToLvlUp, uint256 tokenId) external isYourToken(tokenId) {
    Hero contrat = Hero(addressHero);
    HeroLib.Token memory hero = contrat.getTokenDetails(tokenId);
    if (
      hero.params256[8] <= (100 + (paramsContract["expForLevelUp"] ** hero.params256[9]))
    )
      revert NotEnoughExperience({
        experienceHero: hero.params256[8],
        experienceNeeded: (100 + (paramsContract["expForLevelUp"] ** hero.params256[9])),
        tokenId: tokenId
      });
    if (statToLvlUp < 0 || statToLvlUp > 5)
      revert NotAStat({ statToLvlUp: statToLvlUp, tokenId: tokenId });
    unchecked {
      hero.params8[statToLvlUp]++;
    }
    hero.params256[8] = 0;
    unchecked {
      hero.params256[9]++;
    }

    contrat.updateToken(hero, tokenId, _msgSender());
  }

  /****************************************
    UTILS
     ****************************************/

  ///@notice return random number
  ///@param maxNumber max number random to return
  ///@return randomNumber random uint256 returned
  function random(uint8 maxNumber) internal returns (uint8) {
    return uint8(random256(uint8(maxNumber)));
  }

  ///@notice return random number
  ///@param maxNumber max number random to return
  ///@return randomNumber random uint256 returned
  function random256(uint256 maxNumber) internal returns (uint256) {
    uint256 randomNumber = uint256(
      keccak256(abi.encodePacked(block.timestamp, _msgSender(), paramsContract["nonce"]))
    ) % maxNumber;
    unchecked {
      paramsContract["nonce"]++;
    }
    return randomNumber;
  }

  ///@notice put hero in sell market
  ///@param tokenId id key of token you want to putt in sell
  ///@param price price of token put in selled
  function putHeroInSell(uint256 tokenId, uint256 price) external isYourToken(tokenId) {
    Hero contrat = Hero(addressHero);
    HeroLib.Token memory hero = contrat.getTokenDetails(tokenId);
    hero.params256[11] = price;
    contrat.updateToken(hero, tokenId, _msgSender());
  }

  ///@notice return all heroes in market sell
  ///@return tokens return structure of heroes
  function getHerosInSell() external view returns (HeroLib.Token[] memory) {
    Hero contrat = Hero(addressHero);
    HeroLib.Token[] memory result = new HeroLib.Token[](
      paramsContract["nextTokenIdToMint"]
    );
    uint256 resultIndex;

    for (uint256 i = 0; i < paramsContract["nextTokenIdToMint"]; i = unsafeInc(i)) {
      HeroLib.Token memory hero = contrat.getTokenDetails(i);
      if (hero.params256[11] > 0) {
        result[resultIndex] = hero;
        unchecked {
          resultIndex++;
        }
      }
    }
    return result;
  }

  ///@notice purchase a token previously put in sell
  ///@param tokenId id of token you want buy
  function purchase(uint256 tokenId) external payable {
    Hero contrat = Hero(addressHero);
    HeroLib.Token memory hero = contrat.getTokenDetails(tokenId);
    uint256 price = hero.params256[11];
    address owner = contrat.ownerOf(tokenId);
    if (price <= 0) revert TokenNotInSales({ tokenId: tokenId, price: price });
    if (msg.value < price)
      revert NotEnoughEthPurchase({ tokenId: tokenId, price: price, value: msg.value });
    if (owner == _msgSender())
      revert AlreadyOwned({ tokenId: tokenId, sender: _msgSender(), owner: owner });

    hero.params256[11] = 0;
    contrat.updateToken(hero, tokenId, owner);

    contrat.transfer(owner, _msgSender(), tokenId);

    (bool sent, ) = owner.call{ value: price }("");
    if (sent == false) revert SellMyosSendEth({ to: _msgSender(), value: price });
  }

  /*FUNDS OF CONTRACT*/

  function withdraw() external onlyOwner {
    payable(_msgSender()).transfer(address(this).balance);
  }

  /**
    a finaliser
     */
  /*function calculPriceSupply() public{
        Hero contrat = Hero(addressHero);
        uint totalSupply = contrat.getParamsContract("totalSupply");
        //priceInUsd = (item.price/(10**18)) * (latestPrice/10**8)
    }*/
}
