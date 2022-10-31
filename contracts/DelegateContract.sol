// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Items.sol";
import "./Guild.sol";
import "./Class.sol";
import "./Quest.sol";
import "./Hero.sol";

//enum Numbers {strong,endurance,concentration,agility,charisma,stealth,exp,level,peuple,classe}

contract DelegateContract is Ownable {
  constructor(
    address _addressHero,
    address _addressQuest,
    address _addressClass
  ) {
    addressHero = _addressHero;
    addressQuest = _addressQuest;
    addressClass = _addressClass;
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
  mapping(string => uint256) public paramsContract;
  mapping(uint256 => address) private items;
  mapping(address => Guild) private guilds; //address = creator
  mapping(uint256 => address) private addressGuilds; //address = creator
  uint8 private countItems;
  uint8 private countGuilds;

  ///@notice Create a guild by also deleting its contract
  ///@param _by user for found addresses of your contract by creator mapping
  ///@param name name of your created contract
  ///@param symbol name of your created contract
  function createGuild(
    address _by,
    string memory name,
    string memory symbol
  ) external {
    require(address(guilds[_by]) == address(0), "You already have guild");
    guilds[_by] = new Guild(name, symbol, payable(msg.sender), owner(), countGuilds);
    addressGuilds[countGuilds] = _by;
    countGuilds++;
  }

  ///@notice Deleted a guild by also deleting its contract
  ///@dev ATTENTION, the totality of the ether contained above atters to the creator of the contract
  ///@param _by user for found addresses of your contract by creator mapping
  function deleteGuild(address _by) external {
    require(address(guilds[_by]) != address(0), "Guild not exist");
    require(guilds[_by].isOwner(msg.sender), "Is not your guild");
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

  ///@notice Update the destination address of the official contract items so that the delegation contract can access it
  ///@param item address of contract item
  ///@param idItem key index of contract item you want to set
  function setAddressItem(address item, uint256 idItem) external {
    items[idItem] = item;
    countItems++;
  }

  ///@notice return all items addresses
  ///@return return an array of address for all guilitemsds created
  function getAddressesItems() external view returns (address[] memory) {
    address[] memory result = new address[](countItems);
    uint256 resultIndex = 0;
    uint256 i;
    for (i = 0; i < countItems; i++) {
      result[resultIndex] = items[i];
      resultIndex++;
    }
    return result;
  }

  ///@notice return item address by key
  ///@param idItem key index of item you want to retuen
  ///@return item adress contract item finded
  function getAddressItem(uint256 idItem) external view returns (address) {
    return items[idItem];
  }

  ///@notice return detail of one item
  ///@param addressItem address of item contract you want to get
  ///@return item item structure
  function getItemDetails(address addressItem) external view returns (Items.Item memory) {
    Items contratItems = Items(addressItem);
    Items.Item memory itemTemp = contratItems.getItemDetails(msg.sender);
    return itemTemp;
  }

  ///@notice balance of item for sender
  ///@param idItem key index fo item you want to get
  ///@return balance balance of sender
  function getBalanceOfItem(uint256 idItem) external view returns (uint256) {
    Items itemContrat = Items(items[idItem]);
    return itemContrat.balanceOf(msg.sender);
  }

  ///@notice purchase of a resource for eth/MATIC
  ///@param addressItem address of item contract you want to buy
  ///@param quantity count of item you want purchase
  function buyItem(address payable addressItem, uint256 quantity) external payable {
    (bool sent, bytes memory data) = addressItem.call{ value: msg.value }(
      abi.encodeWithSignature("buyItem(uint256,address)", quantity, msg.sender)
    );
    require(sent, "Failed to send Ether");
  }

  ///@notice sell of a resource for eth/MATIC
  ///@param addressItem address of item contract you want to sell
  ///@param quantity count of item you want sell
  function sellItem(address addressItem, uint256 quantity) external {
    Items itemContrat = Items(addressItem);
    itemContrat.sellItem(quantity, msg.sender);
  }

  ///@notice send eth to item contract
  ///@param addressItem address of item contract you want to interact
  function depositItem(address addressItem) external payable {
    (bool sent, bytes memory data) = addressItem.call{ value: msg.value }(
      abi.encodeWithSignature("deposit()")
    );
    require(sent, "Failed to send Ether");
  }

  ///@notice return price of one contract
  ///@param addressItem address of item contract you want to interact
  ///@return price price of item
  function getCurrentPrice(address addressItem) external view returns (uint256) {
    Items itemContrat = Items(addressItem);
    return itemContrat.getCurrentPrice();
  }

  /**
    appel vers le contrat officiel du jeton
    Offrir un ou plusieurs token a un utilisateur
     */
  // function giveToken(
  //   address to,
  //   uint8 generation,
  //   string memory _tokenUri
  // ) external onlyOwner {
  //   require(paramsContract["tokenLimit"] > 0, "No remaining");
  //   bool[] memory booleans = new bool[](20);
  //   uint8[] memory randomParts = randomParams8(0);
  //   uint256[] memory randomParams = randomParams256(paramsContract["price"], generation);
  //   paramsContract["nextId"]++;

  //   Hero contrat = Hero(addressHero);
  //   contrat.mint(to, booleans, randomParts, randomParams, _tokenUri);
  // }

  ///@notice mint a hero for a value price and generate stats and parameterr
  ///@param generation generation of creation hero
  ///@param peuple peuple with class and stat linked
  ///@param _tokenUri uri of metadata token hero
  function mintDelegate(
    uint8 generation,
    uint8 peuple,
    string memory _tokenUri
  ) external payable {
    require(msg.value >= paramsContract["price"], "More ETH required");
    require(paramsContract["tokenLimit"] > 0, "No remaining");
    bool[] memory booleans = new bool[](20);
    uint8[] memory randomParts = randomParams8(peuple);
    uint256[] memory randomParams = randomParams256(msg.value, generation);
    paramsContract["nextId"]++;

    Hero contrat = Hero(addressHero);
    contrat.mint(msg.sender, booleans, randomParts, randomParams, _tokenUri);
  }

  ///@notice generate stats for your hero in uint8
  ///@param peuple peuple of hero generated
  ///@return randomParams array of stats uint8 for hero
  function randomParams8(uint8 peuple) internal virtual returns (uint8[] memory) {
    /*uint256 totalPnt = paramsContract["totalPnt"];
        if(paramsContract["nextId"]<paramsContract["maxFirstGen"]){totalPnt += 3;}else
        if(paramsContract["nextId"]<paramsContract["maxSecondGen"]){totalPnt += 2;}else
        if(paramsContract["nextId"]<paramsContract["maxthirdGen"]){totalPnt += 1;}*/

    uint8[] memory randomParts = new uint8[](20);

    Class classContrat = Class(addressClass);
    Class.Classes memory tempClass;
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
    //randomParts[6] = 0;//exp
    randomParts[7] = 1; //level
    randomParts[8] = peuple; //peuple
    randomParts[9] = tempClass.id; //class

    return randomParts;
  }

  ///@notice generate parameter for your hero in uint256
  ///@param price price of buying hero
  ///@param generation generation fo hero
  ///@return randomParams array of parameters uint256 for hero
  function randomParams256(uint256 price, uint8 generation)
    internal
    virtual
    returns (uint256[] memory)
  {
    uint256[] memory randomParams = new uint256[](10);
    randomParams[0] = block.timestamp; //date de création
    randomParams[1] = price; //prix d'achat
    randomParams[2] = block.timestamp; //date de la dérnière action (il y a une heure) permettant de participer a des missions
    //randomParams[3] = 0;//Mission choisis (si 0 aucune current mission)
    //randomParams[4] = 0;//seconds pour finir la mission
    //randomParams[5] = 0;//difficulté de la quête (détermine l'exp gagné, et les objets % gagné)
    randomParams[6] = paramsContract["nextId"]; //tokenId
    randomParams[7] = generation; //type
    return randomParams;
  }

  ///@notice start a quest by id for one hero token
  ///@param tokenId id of token you want to launch in quest
  ///@param questId id of quest you want to start
  function startQuest(uint256 tokenId, uint256 questId) external {
    Hero contrat = Hero(addressHero);
    require(contrat.getOwnerOf(tokenId) == msg.sender, "Not your token");
    Quest questContrat = Quest(addressQuest);
    Quest.Quest memory questTemp = questContrat.getQuestDetails(questId);
    Hero.Token memory tokenTemp = contrat.getTokenDetails(tokenId);
    require(tokenTemp.params256[4] == 0, "Quest not finished");
    tokenTemp.params256[2] = block.timestamp;
    tokenTemp.params256[3] = questId;
    tokenTemp.params256[4] = questTemp.time;
    contrat.updateToken(tokenTemp, tokenId, msg.sender);
  }

  ///@notice Validation of the quest at the end of a quest
  ///@param tokenId id of token you want to complete quest
  function completeQuest(uint256 tokenId) external {
    Hero contrat = Hero(addressHero);
    require(contrat.getOwnerOf(tokenId) == msg.sender, "Not your token");
    Hero.Token memory tokenTemp = contrat.getTokenDetails(tokenId);

    Quest questContrat = Quest(addressQuest);
    Quest.Quest memory questTemp = questContrat.getQuestDetails(tokenTemp.params256[3]);
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
    if (random(100 - malus) > questTemp.percentDifficulty) {
      tokenTemp.params8[6] += questTemp.exp * questContrat.getMultiplicateurExp();

      for (uint256 index = 0; index < countItems; index++) {
        Items itemtemp = Items(items[index]);
        if (random256(100000) > itemtemp.getRarity()) {
          itemtemp.mint(1, msg.sender);
        }
      }
    }
    tokenTemp.params256[2] = block.timestamp;
    tokenTemp.params256[3] = 0;
    tokenTemp.params256[4] = 0;

    contrat.updateToken(tokenTemp, tokenId, msg.sender);
  }

  ///@notice level up hero and increment one stat
  ///@param statToLvlUp id of stat you wan increment
  ///@param tokenId id of token you want level up
  function levelUp(uint8 statToLvlUp, uint256 tokenId) external {
    Hero contrat = Hero(addressHero);
    require(contrat.getOwnerOf(tokenId) == msg.sender, "Not your token");
    Hero.Token memory tokenTemp = contrat.getTokenDetails(tokenId);
    require(
      tokenTemp.params8[6] >
        (100 + (paramsContract["expForLevelUp"]**tokenTemp.params8[7])),
      "experience not enought"
    );
    tokenTemp.params8[statToLvlUp]++;
    tokenTemp.params8[6] = 0;
    tokenTemp.params8[7]++;

    contrat.updateToken(tokenTemp, tokenId, msg.sender);
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
    Modifier les paramètre d'un token et l'envoyé au contrat de token pour le mêttre a jour
     */
  /*function paramsToken(uint256 tokenId,bool[] memory booleans, uint8[] memory params8, uint256[] memory params256) external {
        
        Hero contrat = Hero(addressHero);
        Hero.Token memory tokenTemp =  contrat.getTokenDetails(tokenId);
        //if(tokenTemp.params256[2] != params256[2]) tokenTemp.params256[0] = block.timestamp;//mettre a jour la date de création si besoin
        for (uint8 index = 0; index < booleans.length; index++) {
            tokenTemp.booleans[index] = booleans[index];
        }
        for (uint8 index = 0; index < params8.length; index++) {
            tokenTemp.params8[index] = params8[index];
        }
        for (uint8 index = 0; index < params256.length; index++) {
            tokenTemp.params256[index] = params256[index];
        }
        contrat.updateToken(tokenTemp,tokenId,msg.sender);
    }*/

  /**
    appel vers le contrat officiel du jeton
    Achat d'un token par un utilisateur
     */
  /*function purchase(address contactAddr, uint256 tokenId) external payable {
        Hero contrat = Hero(addressHero);
        Hero.Token memory token = contrat.getTokenDetails(tokenId);
        require(msg.value >= token.params256[1], "Insufficient fonds sent");
        require(contrat.getOwnerOf(tokenId) != msg.sender, "Already Owned");
        //contrat.updateToken(token,tokenId,msg.sender);
        contrat.transfer(contactAddr, msg.sender, tokenId);
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
      keccak256(abi.encodePacked(block.timestamp, msg.sender, paramsContract["nonce"]))
    ) % maxNumber;
    paramsContract["nonce"]++;
    return randomNumber;
  }

  /*FUNDS OF CONTRACT*/

  function withdraw() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }
}
