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
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

//enum Numbers {strong,endurance,concentration,agility,charisma,stealth,exp,level,peuple,classe}

contract DelegateContract is Ownable, IDelegateContract {
  using SafeMath for uint;
  error AlreadyHaveGuild(address from, address addressGuild);
  error GuildNotExist(address from, address addressGuild);
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
  error NoMoreSupplyToken(uint256 supply, uint256 quantity, uint256 tokenId);
  error NoMoreBalanceToken(
    uint256 balance,
    address sender,
    uint256 quantity,
    uint256 tokenId
  );
  error ZeroQuantityConvertAvailable(
    uint256 balance,
    address sender,
    uint256 quantity,
    uint256 tokenId
  );
  error SellItemSendEth(address to, uint value);

  address private addressHero;
  address private addressQuest;
  address private addressClass;
  address private addressItem;
  mapping(string => uint256) public paramsContract;
  mapping(address => Guild) private guilds; //address = creator
  mapping(uint256 => address) private addressGuilds; //address = creator
  uint8 private countGuilds;

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

  modifier notYourToken(uint256 tokenId) {
    Hero contrat = Hero(addressHero);
    if (contrat.ownerOf(tokenId) != _msgSender())
      revert NotYourToken({
        sender: _msgSender(),
        ownerOfToken: contrat.ownerOf(tokenId),
        tokenId: tokenId
      });
    _;
  }

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

  ///@notice purchase of a resource for eth/MATIC
  ///@param quantity count of item you want purchase
  ///@param receiver receiver address of token
  ///@param tokenId id of item
  function buyItem(uint256 quantity, address receiver, uint256 tokenId) external payable {
    Items itemContrat = Items(addressItem);
    ItemsLib.Item memory item = itemContrat.getItemDetails(tokenId);
    if (msg.value < item.price * quantity)
      revert NotEnoughEth({
        price: item.price * quantity,
        weiSended: msg.value,
        tokenId: tokenId,
        quantity: quantity
      });
    itemContrat.mint(receiver, tokenId, quantity);
    //setCurrentPrice();
  }

  ///@notice sell of a resource for eth/MATIC
  ///@param quantity count of item you want purchase
  ///@param tokenId id of item
  function sellItem(uint256 quantity, uint256 tokenId) external {
    Items itemContrat = Items(addressItem);
    ItemsLib.Item memory item = itemContrat.getItemDetails(tokenId);
    if (itemContrat.getSupply(tokenId) < quantity)
      revert NoMoreSupplyToken({
        supply: itemContrat.getSupply(tokenId),
        quantity: quantity,
        tokenId: tokenId
      });
    if (itemContrat.balanceOf(_msgSender(), tokenId) < quantity)
      revert NoMoreBalanceToken({
        balance: itemContrat.balanceOf(_msgSender(), tokenId),
        sender: _msgSender(),
        quantity: quantity,
        tokenId: tokenId
      });

    itemContrat.burn(_msgSender(), tokenId, quantity);
    (bool sent, ) = _msgSender().call{ value: item.price * quantity }("");
    if (sent == false)
      revert SellItemSendEth({ to: _msgSender(), value: item.price * quantity });
    //payable(_msgSender()).transfer(item.price * quantity);
    //setCurrentPrice();
  }

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
  ) external {
    Items itemContrat = Items(addressItem);
    ItemsLib.Item memory fromItem = itemContrat.getItemDetails(fromTokenId);
    ItemsLib.Item memory toItem = itemContrat.getItemDetails(toTokenId);

    if (itemContrat.getSupply(fromTokenId) < quantity)
      revert NoMoreSupplyToken({
        supply: itemContrat.getSupply(fromTokenId),
        quantity: quantity,
        tokenId: fromTokenId
      });

    if (itemContrat.balanceOf(_msgSender(), fromTokenId) < quantity)
      revert NoMoreBalanceToken({
        balance: itemContrat.balanceOf(_msgSender(), fromTokenId),
        sender: _msgSender(),
        quantity: quantity,
        tokenId: fromTokenId
      });

    uint256 toQuantityAvailable = calculConversionQuantity(
      fromItem.price,
      toItem.price,
      quantity
    );

    if (toQuantityAvailable <= 0)
      revert ZeroQuantityConvertAvailable({
        balance: itemContrat.balanceOf(_msgSender(), fromTokenId),
        sender: _msgSender(),
        quantity: quantity,
        tokenId: toTokenId
      });

    itemContrat.burn(_msgSender(), fromTokenId, quantity);
    itemContrat.mint(receiver, toTokenId, toQuantityAvailable);
    //currentprice = setCurrentPrice();
  }

  ///@notice mint a hero for a value price and generate stats and parameterr
  ///@param generation generation of creation hero
  ///@param peuple peuple with class and stat linked
  ///@param _tokenUri uri of metadata token hero
  function mintHero(
    uint8 generation,
    uint8 peuple,
    string calldata _tokenUri
  ) external payable {
    require(msg.value >= paramsContract["price"], "More ETH required");
    if (msg.value < paramsContract["price"])
      revert NotEnoughEthHero({ price: paramsContract["price"], weiSended: msg.value });
    if (paramsContract["tokenLimit"] <= paramsContract["nextTokenIdToMint"])
      revert NotRemainingHero({
        tokenLimit: paramsContract["tokenLimit"],
        nextTokenIdToMint: paramsContract["nextTokenIdToMint"]
      });
    uint8[] memory randomParts = randomStats(peuple);
    uint256[] memory randomParams = randomParameters(msg.value, generation);
    paramsContract["nextTokenIdToMint"]++;

    Hero contrat = Hero(addressHero);
    contrat.mint(_msgSender(), randomParts, randomParams, _tokenUri);
  }

  ///@notice generate stats for your hero in uint8
  ///@param peuple peuple of hero generated
  ///@return randomParts array of stats uint8 for hero
  function randomStats(uint8 peuple) internal virtual returns (uint8[] memory) {
    uint8[] memory randomParts = new uint8[](20);

    Class classContrat = Class(addressClass);
    ClassLib.Classes memory class;
    class = classContrat.getClassDetails(0);
    for (uint8 index = 0; index < classContrat.getClassCount(); index++) {
      if (random(100) < classContrat.getClassDetails(index).rarity)
        class = classContrat.getClassDetails(index);
    }
    uint8[] memory stats = class.stats;

    randomParts[0] = stats[0]; //strong
    randomParts[1] = stats[1]; //endurance
    randomParts[2] = stats[2]; //concentration
    randomParts[3] = stats[3]; //agility
    randomParts[4] = stats[4]; //charisma
    randomParts[5] = stats[5]; //stealth

    randomParts[8] = peuple; //peuple
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
    return randomParams;
  }

  ///@notice start a quest by id for one hero token
  ///@param tokenId id of token you want to launch in quest
  ///@param questId id of quest you want to start
  function startQuest(uint256 tokenId, uint256 questId) external notYourToken(tokenId) {
    Hero contrat = Hero(addressHero);
    Quest questContrat = Quest(addressQuest);
    QuestLib.QuestStruct memory questTemp = questContrat.getQuestDetails(questId);
    HeroLib.Token memory tokenTemp = contrat.getTokenDetails(tokenId);
    if (tokenTemp.params256[4] != 0)
      revert AlreadyInQuest({
        sender: _msgSender(),
        questId: questId,
        currentQuestId: tokenTemp.params256[4],
        tokenId: tokenId
      });
    tokenTemp.params256[2] = block.timestamp;
    tokenTemp.params256[3] = questId;
    tokenTemp.params256[4] = questTemp.time;
    contrat.updateToken(tokenTemp, tokenId, _msgSender());
  }

  ///@notice Validation of the quest at the end of a quest
  ///@param tokenId id of token you want to complete quest
  function completeQuest(uint256 tokenId) external notYourToken(tokenId) {
    Hero contrat = Hero(addressHero);
    HeroLib.Token memory tokenTemp = contrat.getTokenDetails(tokenId);

    Quest questContrat = Quest(addressQuest);
    QuestLib.QuestStruct memory questTemp = questContrat.getQuestDetails(
      tokenTemp.params256[3]
    );
    if (block.timestamp - tokenTemp.params256[2] <= (questTemp.time))
      revert QuestNotFinished({
        blockTimestamp: block.timestamp,
        heroQuestTime: tokenTemp.params256[2],
        currentQuestTime: questTemp.time,
        tokenId: tokenId
      });
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
      //recuperer les items dans la quest !IMPORTANT
      /*for (uint256 index = 0; index < countItems; index++) {
        Items itemtemp = Items(items[index]);
        if (random256(100000) > itemtemp.getRarity()) {
          itemtemp.mint(1, _msgSender());
        }
      }*/
    } else {
      tokenTemp.params256[6] = 0;
    }
    tokenTemp.params256[2] = block.timestamp;
    tokenTemp.params256[4] = 0;

    contrat.updateToken(tokenTemp, tokenId, _msgSender());
  }

  ///@notice level up hero and increment one stat
  ///@param statToLvlUp id of stat you wan increment
  ///@param tokenId id of token you want level up
  function levelUp(uint8 statToLvlUp, uint256 tokenId) external notYourToken(tokenId) {
    Hero contrat = Hero(addressHero);
    HeroLib.Token memory tokenTemp = contrat.getTokenDetails(tokenId);
    if (
      tokenTemp.params256[8] <=
      (100 + (paramsContract["expForLevelUp"] ** tokenTemp.params256[9]))
    )
      revert NotEnoughExperience({
        experienceHero: tokenTemp.params256[8],
        experienceNeeded: (100 +
          (paramsContract["expForLevelUp"] ** tokenTemp.params256[9])),
        tokenId: tokenId
      });
    if (statToLvlUp < 0 || statToLvlUp > 5)
      revert NotAStat({ statToLvlUp: statToLvlUp, tokenId: tokenId });
    tokenTemp.params8[statToLvlUp]++;
    tokenTemp.params256[8] = 0;
    tokenTemp.params256[9]++;

    contrat.updateToken(tokenTemp, tokenId, _msgSender());
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
    paramsContract["nonce"]++;
    return randomNumber;
  }

  /*FUNDS OF CONTRACT*/

  function withdraw() external onlyOwner {
    payable(_msgSender()).transfer(address(this).balance);
  }

  function calculConversionQuantity(
    uint firstTokenPrice,
    uint twoTokenPrice,
    uint quantity
  ) public view returns (uint256) {
    return
      firstTokenPrice.mul(utilMathMultiply).div(twoTokenPrice).mul(quantity).div(
        utilMathMultiply
      );
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

  ///@notice Deleted a guild by also deleting its contract
  ///@dev ATTENTION, the totality of the ether contained above atters to the creator of the contract
  ///@param from user for found addresses of your contract by creator mapping
  //function deleteGuild(address from) external {
  //  require(address(guilds[from]) != address(0), "Guild not exist");
  //  require(guilds[from].isOwner(_msgSender()), "Is not your guild");
  //  guilds[from].kill();
  //  addressGuilds[guilds[from].getId()] = address(0);
  //}

  // function giveHero(
  //   address to,
  //   uint8 generation,
  //   string memory _tokenUri
  // ) external onlyOwner {
  //require(paramsContract["tokenLimit"] > 0, "No remaining");
  //bool[] memory booleans = new bool[](20);
  //uint8[] memory randomParts = randomStats(0);
  //uint256[] memory randomParams = randomParams(paramsContract["price"], generation);
  //paramsContract["nextTokenIdToMint"]++;

  //Hero contrat = Hero(addressHero);
  //contrat.mint(to, booleans, randomParts, randomParams, _tokenUri);
  //}
}
