// SPDX-License-Identifier: MIT
// Delegation contract
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Items.sol";
import "./Guild.sol";
import "./Class.sol";
import "./Quest.sol";
import "./Hero.sol";

contract DelegateContract is Ownable {
  constructor(
    address _addressHero,
    address _addressQuest,
    address _addressClass
  ) {
    addressHero = _addressHero;
    addressQuest = _addressQuest;
    addressClass = _addressClass;
    Hero contrat = Hero(addressHero);
    paramsContract["nextId"] = contrat.getParamsContract("nextId");
    paramsContract["price"] = 100000000000000000; //dev:100000000000000000000 == 100 eth
    paramsContract["totalPnt"] = 5;
    paramsContract["tokenLimit"] = 10000;
    paramsContract["nonce"] = 0;
    paramsContract["expForLevelUp"] = 100;
  }

  address addressHero;
  address addressQuest;
  address addressClass;
  address addressMYOSToken;
  mapping(string => uint256) paramsContract;
  mapping(uint256 => address) items;
  mapping(address => Guild) guilds; //address = creator
  mapping(uint256 => address) addressGuilds; //address = creator
  uint8 countItems;
  uint8 countGuilds;

  /**
    Créer une guild en créant directement un contrat lié
    Puis ajouté ce contrat au map guilds
     */
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

  /**
    Supprimé une guilde en supprimant également son contrat
    ATTENTION, la totalité de l'ether contenu dessus attérit chez le créateur du contrat
     */
  function deleteGuild(address _by) external {
    require(address(guilds[_by]) != address(0), "Guild not exist");
    require(guilds[_by].isOwner(msg.sender), "Is not your guild");
    guilds[_by].kill();
    addressGuilds[guilds[_by].getId()] = address(0);
  }

  /**
    Récupérer l'addresse d'un contrat de guild avec l'address du créateur
     */
  function getOneGuildAddress(address _by) external view returns (address) {
    require(address(guilds[_by]) != address(0), "Guild not exist");
    return address(guilds[_by]);
  }

  /**
    Récupérer la totalité des addresse de guilds
     */
  function getAddressGuilds() external view returns (address[] memory) {
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

  /**
    Mêttre a jour l'addresse de destination du contrat officiel pour que le contrat de délégation puisse y accèder
     */
  function setaddressHero(address _addressHero) external onlyOwner {
    addressHero = _addressHero;
  }

  /**
    Mêttre à jour un paramètre du contrat de délégation
    */
  function setParamsContract(string memory keyParams, uint256 valueParams)
    external
    onlyOwner
  {
    paramsContract[keyParams] = valueParams;
  }

  /**
    récupérer une valeur du tableau de paramètre du contrat de délégation
    */
  function getParamsContract(string memory keyParams) external view returns (uint256) {
    return paramsContract[keyParams];
  }

  /**
    appel vers le contrat officiel du jeton
    Mêttre a jour un paramètre du contrat officiel depuis le contrat de délégation
     */
  function setParamsDelegate(string memory keyParams, uint256 valueParams) internal {
    Hero contrat = Hero(addressHero);
    contrat.setParamsContract(keyParams, valueParams);
  }

  function setAddressItem(address item, uint256 idItem) external {
    items[idItem] = item;
    countItems++;
  }

  function getAddressItems() external view returns (address[] memory) {
    address[] memory result = new address[](countItems);
    uint256 resultIndex = 0;
    uint256 i;
    for (i = 0; i < countItems; i++) {
      result[resultIndex] = items[i];
      resultIndex++;
    }
    return result;
  }

  function getAddressItem(uint256 idItem) external view returns (address) {
    return items[idItem];
  }

  function getParamsItem(address addressItem) external view returns (Items.Item memory) {
    Items contratItems = Items(addressItem);
    Items.Item memory itemTemp = contratItems.getItemDetails(msg.sender);
    return itemTemp;
  }

  function getBalanceOfItem(uint256 idItem) external view returns (uint256) {
    Items itemContrat = Items(items[idItem]);
    //return itemContrat.balanceOf(msg.sender);
    return itemContrat.balanceOf(msg.sender);
  }

  /**
    achat d'une ressource contre de l'eth/MATIC
     */
  function buyItem(address payable addressItem, uint256 value) public payable {
    (bool sent, bytes memory data) = addressItem.call{ value: msg.value }(
      abi.encodeWithSignature("buyItem(uint256,address)", value, msg.sender)
    );
    require(sent, "Failed to send Ether");
  }

  /**
    Vente du jeton contre de l'eth/MATIC
     */
  function sellItem(address addressItem, uint256 value) public {
    Items itemContrat = Items(addressItem);
    itemContrat.sellItem(value, msg.sender);
  }

  function depositItem(address addressItem) public payable {
    (bool sent, bytes memory data) = addressItem.call{ value: msg.value }(
      abi.encodeWithSignature("deposit()")
    );
    require(sent, "Failed to send Ether");
  }

  function getCurrentPrice(address addressItem) public view returns (uint256) {
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

  /**
    appel vers le contrat officiel du jeton
    Modifier les paramètre d'un token et l'envoyé au contrat de token pour le mêttre a jour
     */
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

  /**
    une autre idée pour calculer les stats de départ, ma préféré
     */
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

  function startQuest(uint256 tokenId, uint256 questId) public {
    Hero contrat = Hero(addressHero);
    require(contrat.getOwnerOf(tokenId) == msg.sender, "Not your token");
    /*Quest questContrat = Quest(addressQuest);
        Quest.Quest memory questTemp =  questContrat.getQuestDetails(questId);
        require(questTemp.valid == true,"Quest not exist");*/
    Hero.Token memory tokenTemp = contrat.getTokenDetails(tokenId);
    require(tokenTemp.params256[3] == 0, "Quest not finished");
    tokenTemp.params256[3] = questId;
    contrat.updateToken(tokenTemp, tokenId, msg.sender);
  }

  /**
    Validation de la quête a la fin du comteur time d'une quest
     */
  function completeQuest(uint256 tokenId) public {
    Hero contrat = Hero(addressHero);
    require(contrat.getOwnerOf(tokenId) == msg.sender, "Not your token");
    Hero.Token memory tokenTemp = contrat.getTokenDetails(tokenId);

    Quest questContrat = Quest(addressQuest);
    Quest.Quest memory questTemp = questContrat.getQuestDetails(tokenTemp.params256[3]);
    require(
      block.timestamp - tokenTemp.params256[2] > (questTemp.time),
      "Quest not finished"
    ); //BON CA VA PAS REVISER COMPLEMENT LE TIME ET COTER FRONT AUSSI
    //require(block.timestamp > tokenTemp.params256[2]+(questTemp.time), "Quest not finished");//ça fonctionnais mais celle du dessus est surement plus propre
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

  function getQuest(uint8 questId) external view returns (Quest.Quest memory) {
    Quest contrat = Quest(addressQuest);
    Quest.Quest memory questTemp = contrat.getQuestDetails(questId);
    return questTemp;
  }

  /**
    Quand l'exp est a fond, luser peut rajouter un point ou il veux
    Réfléchir a la logique d'exp max, pour l'instant (100+(?**level))
    Est ce qu'ont rajouterai pas de façon random des points autres part
    */
  function levelUp(uint8 statToLvlUp, uint256 tokenId) public {
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

  /**
    appel vers le contrat officiel du jeton
    récupérer un tableau d'id des tokens d'un utilisateur
     */
  function getAllTokensForUser(address user) external view returns (uint256[] memory) {
    Hero contrat = Hero(addressHero);
    return contrat.getAllTokensForUser(user);
  }

  /**
    appel vers le contrat officiel du jeton
    récupérer les data d'un token avec son id
     */
  function getTokenDetails(uint256 tokenId) external view returns (Hero.Token memory) {
    Hero contrat = Hero(addressHero);
    return contrat.getTokenDetails(tokenId);
  }

  function random(uint8 maxNumber) internal returns (uint8) {
    uint256 randomnumber = uint256(
      keccak256(abi.encodePacked(block.timestamp, msg.sender, paramsContract["nonce"]))
    ) % maxNumber;
    paramsContract["nonce"]++;
    return uint8(randomnumber);
  }

  /****************************************
    UTILS
     ****************************************/

  function random256(uint256 maxNumber) internal returns (uint256) {
    uint256 randomnumber = uint256(
      keccak256(abi.encodePacked(block.timestamp, msg.sender, paramsContract["nonce"]))
    ) % maxNumber;
    paramsContract["nonce"]++;
    return randomnumber;
  }

  /*FUNDS OF CONTRACT*/

  function withdraw() public onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }
}
