// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Items.sol";
import "./Guild.sol";
import "./Class.sol";
import "./Quest.sol";
import "./Hero.sol";

import "./library/LClass.sol";
import "./library/LHero.sol";
import "./library/LItems.sol";
import "./library/LQuest.sol";

import "./interfaces/IDelegateContract.sol";

//enum Numbers {strong,endurance,concentration,agility,charisma,stealth,exp,level,peuple,classe}

contract DelegateContract is Ownable, IDelegateContract {
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
    paramsContract["nextId"] = Hero(addressHero).getParamsContract("nextId");
    paramsContract["price"] = 100000000000000000; //dev:100000000000000000000 == 100 eth
    paramsContract["totalPnt"] = 5;
    paramsContract["tokenLimit"] = 10000;
    paramsContract["nonce"] = 0;
    paramsContract["expForLevelUp"] = 100;
  }

  address private addressHero;
  address private addressQuest;
  address private addressClass;
  address private addressItem;
  mapping(string => uint256) public paramsContract;
  mapping(address => Guild) private guilds; //address = creator
  mapping(uint256 => address) private addressGuilds; //address = creator
  uint8 private countGuilds;

  ///@notice Create a guild by also deleting its contract
  ///@param _by user for found addresses of your contract by creator mapping
  ///@param name name of your created contract
  ///@param symbol name of your created contract
  function createGuild(address _by, string memory name, string memory symbol) external {
    require(address(guilds[_by]) == address(0), "You already have guild");
    guilds[_by] = new Guild(name, symbol, payable(_msgSender()), owner(), countGuilds);
    addressGuilds[countGuilds] = _by;
    countGuilds++;
  }

  ///@notice Deleted a guild by also deleting its contract
  ///@dev ATTENTION, the totality of the ether contained above atters to the creator of the contract
  ///@param _by user for found addresses of your contract by creator mapping
  function deleteGuild(address _by) external {
    require(address(guilds[_by]) != address(0), "Guild not exist");
    require(guilds[_by].isOwner(_msgSender()), "Is not your guild");
    guilds[_by].kill();
    addressGuilds[guilds[_by].getId()] = address(0);
  }

  ///@notice return one guild by address creator
  ///@param _by user for found addresses of your contract by creator mapping
  ///@return addressContract address of the contract guild
  function getOneGuildAddress(address _by) external view returns (address) {
    require(address(guilds[_by]) != address(0), "Guild not exist");
    return address(guilds[_by]);
  }

  ///@notice return all guilds addresses
  ///@return return an array of address for all guilds created
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

  ///@notice Update the destination address of the official contract hero so that the delegation contract can access it
  ///@param _addressHero address of contract hero
  function setaddressHero(address _addressHero) external onlyOwner {
    addressHero = _addressHero;
  }

  ///@notice Update a parameter of contract
  ///@param key key index of params contract you want set
  ///@param value value of params contract you want set
  function setParamsContract(string memory key, uint256 value) external onlyOwner {
    paramsContract[key] = value;
  }

  ///@notice Return a parameter of contract by key index
  ///@param key key index of param your want to return
  ///@return param value of parameter contract
  function getParamsContract(string memory key) external view returns (uint256) {
    return paramsContract[key];
  }

  ///@notice Update a parameter of hero contract
  ///@param key key index of params contract you want set
  ///@param value value of params contract you want set
  function setParamsHeroContract(string memory key, uint256 value) internal {
    Hero contrat = Hero(addressHero);
    contrat.setParamsContract(key, value);
  }

  ///@notice convert of a resource for another token
  function convertToAnotherToken(uint256 value, address anotherToken) external {
    /*require(supplies[tokenId]>value+1,"No more this token");
        require(balanceOf(_msgSender())>=value,"No more this token");
        _burn(_msgSender(),value);
        currentprice = setCurrentPrice();*/
  }

  ///@notice purchase of a resource for eth/MATIC
  ///@param quantity count of item you want purchase
  ///@param receiver receiver address of token
  ///@param tokenId id of item
  function buyItem(uint256 quantity, address receiver, uint256 tokenId) external payable {
    Items itemContrat = Items(addressItem);
    ItemsLib.Item memory item = itemContrat.getItemDetails(tokenId);
    require(msg.value >= item.price * quantity, "More ETH required");
    itemContrat.mint(receiver, tokenId, quantity);
    //setCurrentPrice();
  }

  ///@notice sell of a resource for eth/MATIC
  ///@param quantity count of item you want purchase
  ///@param tokenId id of item
  function sellItem(uint256 quantity, uint256 tokenId) external {
    Items itemContrat = Items(addressItem);
    ItemsLib.Item memory item = itemContrat.getItemDetails(tokenId);
    require(itemContrat.getSupply(tokenId) >= quantity, "No more this token");
    require(
      itemContrat.balanceOf(_msgSender(), tokenId) >= quantity,
      "No more this token"
    );
    payable(_msgSender()).transfer(item.price * quantity);
    itemContrat.burn(_msgSender(), tokenId, quantity);
    //setCurrentPrice();
  }

  /**
    appel vers le contrat officiel du jeton
    Offrir un ou plusieurs token a un utilisateur
     */
  // function giveHero(
  //   address to,
  //   uint8 generation,
  //   string memory _tokenUri
  // ) external onlyOwner {
  //   require(paramsContract["tokenLimit"] > 0, "No remaining");
  //   bool[] memory booleans = new bool[](20);
  //   uint8[] memory randomParts = randomStats(0);
  //   uint256[] memory randomParams = randomParams(paramsContract["price"], generation);
  //   paramsContract["nextId"]++;

  //   Hero contrat = Hero(addressHero);
  //   contrat.mint(to, booleans, randomParts, randomParams, _tokenUri);
  // }

  ///@notice mint a hero for a value price and generate stats and parameterr
  ///@param generation generation of creation hero
  ///@param peuple peuple with class and stat linked
  ///@param _tokenUri uri of metadata token hero
  function mintHero(
    uint8 generation,
    uint8 peuple,
    string memory _tokenUri
  ) external payable {
    require(msg.value >= paramsContract["price"], "More ETH required");
    require(paramsContract["tokenLimit"] > 0, "No remaining");
    uint8[] memory randomParts = randomStats(peuple);
    uint256[] memory randomParams = randomParameters(msg.value, generation);
    paramsContract["nextId"]++;

    Hero contrat = Hero(addressHero);
    contrat.mint(_msgSender(), randomParts, randomParams, _tokenUri);
  }

  ///@notice generate stats for your hero in uint8
  ///@param peuple peuple of hero generated
  ///@return randomParts array of stats uint8 for hero
  function randomStats(uint8 peuple) internal virtual returns (uint8[] memory) {
    /*uint256 totalPnt = paramsContract["totalPnt"];
        if(paramsContract["nextId"]<paramsContract["maxFirstGen"]){totalPnt += 3;}else
        if(paramsContract["nextId"]<paramsContract["maxSecondGen"]){totalPnt += 2;}else
        if(paramsContract["nextId"]<paramsContract["maxthirdGen"]){totalPnt += 1;}*/

    uint8[] memory randomParts = new uint8[](20);

    Class classContrat = Class(addressClass);
    ClassLib.Classes memory tempClass;
    tempClass = classContrat.getClassDetails(0);
    for (uint8 index = 0; index < classContrat.getClassCount(); index++) {
      if (random(100) < classContrat.getClassDetails(index).rarity)
        tempClass = classContrat.getClassDetails(index);
    }
    uint8[] memory stats = tempClass.stats;

    randomParts[0] = stats[0]; //strong
    randomParts[1] = stats[1]; //endurance
    randomParts[2] = stats[2]; //concentration
    randomParts[3] = stats[3]; //agility
    randomParts[4] = stats[4]; //charisma
    randomParts[5] = stats[5]; //stealth

    randomParts[8] = peuple; //peuple
    randomParts[9] = tempClass.id; //class

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
    randomParams[6] = paramsContract["nextId"]; //tokenId
    randomParams[7] = generation; //type
    //randomParams[8] = 0;//exp
    randomParams[9] = 1; //level
    return randomParams;
  }

  ///@notice start a quest by id for one hero token
  ///@param tokenId id of token you want to launch in quest
  ///@param questId id of quest you want to start
  function startQuest(uint256 tokenId, uint256 questId) external {
    Hero contrat = Hero(addressHero);
    require(contrat.ownerOf(tokenId) == _msgSender(), "Not your token");
    Quest questContrat = Quest(addressQuest);
    QuestLib.QuestStruct memory questTemp = questContrat.getQuestDetails(questId);
    HeroLib.Token memory tokenTemp = contrat.getTokenDetails(tokenId);
    require(tokenTemp.params256[4] == 0, "Quest not finished");
    tokenTemp.params256[2] = block.timestamp;
    tokenTemp.params256[3] = questId;
    tokenTemp.params256[4] = questTemp.time;
    contrat.updateToken(tokenTemp, tokenId, _msgSender());
  }

  ///@notice Validation of the quest at the end of a quest
  ///@param tokenId id of token you want to complete quest
  function completeQuest(uint256 tokenId) external {
    Hero contrat = Hero(addressHero);
    require(contrat.ownerOf(tokenId) == _msgSender(), "Not your token");
    HeroLib.Token memory tokenTemp = contrat.getTokenDetails(tokenId);

    Quest questContrat = Quest(addressQuest);
    QuestLib.QuestStruct memory questTemp = questContrat.getQuestDetails(
      tokenTemp.params256[3]
    );
    require(
      block.timestamp - tokenTemp.params256[2] > (questTemp.time),
      "Quest not finished"
    );
    uint8 malus = 0;
    for (uint8 index = 0; index < questTemp.stats.length; index++) {
      if (questTemp.stats[index] > tokenTemp.params8[index]) {
        malus += questTemp.stats[index] - tokenTemp.params8[index];
      }
    }
    ///SUCCESS QUEST
    uint256 percentSuccess = random(100 - malus);
    tokenTemp.params256[7] = percentSuccess;
    if (percentSuccess > questTemp.percentDifficulty) {
      tokenTemp.params256[6] = 1;
      tokenTemp.params256[8] += (questTemp.exp * questContrat.getMultiplicateurExp());

      Items itemContrat = Items(addressItem);

      for (uint256 index = 0; index < questTemp.items.length; index++) {
        itemContrat.mint(_msgSender(), questTemp.items[index], 1);
      }
      /*for (uint256 index = 0; index < countItems; index++) {
        Items itemtemp = Items(items[index]);
        if (random256(100000) > itemtemp.getRarity()) {
          itemtemp.mint(1, _msgSender());
        }
      }*/
    } else {
      tokenTemp.params256[6] = 0;
    }
    //recuperer les imtes dans la quest !IMPORTANT
    tokenTemp.params256[2] = block.timestamp;
    tokenTemp.params256[4] = 0;

    contrat.updateToken(tokenTemp, tokenId, _msgSender());
  }

  ///@notice level up hero and increment one stat
  ///@param statToLvlUp id of stat you wan increment
  ///@param tokenId id of token you want level up
  function levelUp(uint8 statToLvlUp, uint256 tokenId) external {
    Hero contrat = Hero(addressHero);
    require(contrat.ownerOf(tokenId) == _msgSender(), "Not your token");
    HeroLib.Token memory tokenTemp = contrat.getTokenDetails(tokenId);
    require(
      tokenTemp.params256[8] >
        (100 + (paramsContract["expForLevelUp"] ** tokenTemp.params256[9])),
      "experience not enought"
    );
    require(statToLvlUp >= 0 && statToLvlUp <= 5, "this is not a stats");
    tokenTemp.params8[statToLvlUp]++;
    tokenTemp.params256[8] = 0;
    tokenTemp.params256[9]++;

    contrat.updateToken(tokenTemp, tokenId, _msgSender());
  }

  /**
    a finaliser
     */
  /*function calculPriceSupply() public{
        Hero contrat = Hero(addressHero);
        uint totalSupply = contrat.getParamsContract("totalSupply");
        //priceInUsd = (item.price/(10**18)) * (latestPrice/10**8)
    }*/

  /**
    appel vers le contrat officiel du jeton
    Achat d'un token par un utilisateur
     */
  /*function purchase(address contactAddr, uint256 tokenId) external payable {
        Hero contrat = Hero(addressHero);
        HeroLib.Token memory token = contrat.getTokenDetails(tokenId);
        require(msg.value >= token.params256[1], "Insufficient fonds sent");
        require(contrat.getOwnerOf(tokenId) != _msgSender(), "Already Owned");
        //contrat.updateToken(token,tokenId,_msgSender());
        contrat.transfer(contactAddr, _msgSender(), tokenId);
    }*/

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
    paramsContract["nonce"]++;
    return randomNumber;
  }

  /*FUNDS OF CONTRACT*/

  function withdraw() external onlyOwner {
    payable(_msgSender()).transfer(address(this).balance);
  }
}
