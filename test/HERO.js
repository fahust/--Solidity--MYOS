const truffleAssert = require("truffle-assertions");
const { catchRevert } = require("../helper/exceptions");

const { CONTRACT_VALUE_ENUM } = require("../enums/enum");

const timeout = require("../helper/timeout");
const mineBlock = require("../helper/mineBlock");
const getRandomInt = require("../helper/random");

const Hero = artifacts.require("Hero");
const Class = artifacts.require("Class");
const Quest = artifacts.require("Quest");
const Items = artifacts.require("Items");
const Equipments = artifacts.require("Equipments");
const ProxyHero = artifacts.require("ProxyHero");
const ProxyItems = artifacts.require("ProxyItems");
const ProxyEquipments = artifacts.require("ProxyEquipments");

const IProxyItems = require("../build/contracts/IProxyItems.json");
const IProxyEquipments = require("../build/contracts/IProxyEquipments.json");
const IProxyHero = require("../build/contracts/IProxyHero.json");
const IHero = require("../build/contracts/IHero.json");
const IItems = require("../build/contracts/IItems.json");
const IEquipments = require("../build/contracts/IEquipments.json");
const IQuest = require("../build/contracts/IQuest.json");

contract("HERO", async accounts => {
  const firstAccount = accounts[0];
  const secondAccount = accounts[1];

  const Splitter = [
    0, //id
    25, //rarity
    [1, 2, 1, 3, 2, 1], //stats
    "Splitter", //name
  ];
  const Guardian = [1, 100, [1, 2, 1, 3, 2, 1], "Guardian"];
  const Wise = [2, 15, [1, 2, 1, 3, 2, 1], "Wise"];
  const Phantom = [3, 9, [1, 2, 1, 3, 2, 1], "Phantom"];

  const firstQuest = [
    0, //id
    5, //time
    100, //exp
    0, //difficulty
    [0, 0, 0, 0, 0, 0], //stats needed
    [0, 1, 2], //items win
  ];
  const secondQuest = [1, 5, 1000, 0, [0, 0, 2, 0, 0, 0], [0]];
  const thirdQuest = [2, 3, 1000, 101, [0, 0, 0, 0, 3, 0], [0, 2, 3]]; //impossible

  const firstItem = ["Wood", 5000, 10, 0];
  const secondItem = ["Iron", 3000, 20, 1];
  const thirdItem = ["Food", 8888, 2, 2];
  const fourthItem = ["Fish", 7500, 3, 3];

  const firstEquipment = ["Iron Helmet", 5000, 85, [0], [1], 0];
  const secondEquipment = ["Iron Gloves", 5000, 46, [0], [1], 1];
  const thirdEquipment = ["Iron Armor", 5000, 22, [0], [1], 2];
  const fourthEquipment = ["Iron Legs", 5000, 45, [0], [1], 3];

  const pricePurchase = "555555555555";

  const optionsSend = { from: firstAccount, gas: 4500000, gasPrice: 1 };

  before(async function () {
    this.HeroContract = await Hero.new(
      CONTRACT_VALUE_ENUM.NAME,
      CONTRACT_VALUE_ENUM.SYMBOL,
      CONTRACT_VALUE_ENUM.FIRST_IPFS_HASH,
    ); // we deploy contract

    this.ClassContract = await Class.new(); // we deploy contract
    this.QuestContract = await Quest.new();
    this.ItemsContract = await Items.new(CONTRACT_VALUE_ENUM.FIRST_IPFS_HASH);
    this.EquipmentsContract = await Equipments.new(CONTRACT_VALUE_ENUM.FIRST_IPFS_HASH);

    this.ProxyHero = await ProxyHero.new(
      this.HeroContract.address,
      this.QuestContract.address,
      this.ClassContract.address,
      this.ItemsContract.address,
    ); // we deploy contract

    this.ProxyItems = await ProxyItems.new(this.ItemsContract.address);

    this.ProxyEquipments = await ProxyEquipments.new(
      this.EquipmentsContract.address,
      this.ItemsContract.address,
    );

    this.iProxyItems = new web3.eth.Contract(IProxyItems.abi, this.ProxyItems.address);
    this.iProxyEquipments = new web3.eth.Contract(
      IProxyEquipments.abi,
      this.ProxyEquipments.address,
    );
    this.iProxyHero = new web3.eth.Contract(IProxyHero.abi, this.ProxyHero.address);
    this.iHero = new web3.eth.Contract(IHero.abi, this.HeroContract.address);
    this.iItems = new web3.eth.Contract(IItems.abi, this.ItemsContract.address);
    this.iEquipments = new web3.eth.Contract(
      IEquipments.abi,
      this.EquipmentsContract.address,
    );
    this.iQuest = new web3.eth.Contract(IQuest.abi, this.QuestContract.address);
  });

  
  describe("Create class and hero", async function () {
    it("SUCCESS : try to get random price conversion from one token to another token multiple time", async function () {
      for (let index = 0; index < 20; index++) {
        const firstPrice = getRandomInt(1, 30000000000);
        const secondPrice = getRandomInt(1, 30000000000);
        const quantity = getRandomInt(1, 30000000000);
        await this.iProxyItems.methods
          .calculConversionQuantity(firstPrice, secondPrice, quantity)
          .call({ from: firstAccount });
      }
    });

    it("SUCCESS : try to set address proxy contract on HERO contract", async function () {
      await this.iHero.methods.setAddressProxyContract(this.ProxyHero.address).send({
        from: firstAccount,
      });
    });

    it("SUCCESS : try to set class", async function () {
      await this.ClassContract.setClass(...Splitter, {
        from: firstAccount,
      });
    });

    it("SUCCESS : try to set address proxy contract on MYOS contract", async function () {
      const classe = await this.ClassContract.getClassDetails(0);
      assert.equal(+classe.id, +Splitter[0]);
      assert.equal(+classe.rarity, +Splitter[1]);
      assert.equal(classe.name, Splitter[3]);
    });

    it("SUCCESS : try to mint a hero erc721 by proxy contract", async function () {
      const priceHero = await this.iProxyHero.methods.getParamsContract("price").call({
        from: firstAccount,
      });

      await this.iProxyHero.methods
        .mintHero(0, 0, CONTRACT_VALUE_ENUM.FIRST_IPFS_HASH)
        .send({
          ...optionsSend,
          value: priceHero + "",
        });
    });

    it("SUCCESS : try to get all heroes", async function () {
      const heroes = await this.iHero.methods.getAllTokens().call({
        ...optionsSend,
      });
      assert.equal(heroes.length, 1);
    });

    it("SUCCESS : try to get heros in sell", async function () {
      const heroesInSell = await this.iProxyHero.methods.getHerosInSell().call({
        ...optionsSend,
      });
      assert.ok(heroesInSell[0][0].length === 0);
    });

    it("ERROR : try to purchase hero in sell before it", async function () {
      const tokenId = 0;
      price = "999999999999999";
      const hero = await this.iHero.methods
        .getTokenDetails(tokenId)
        .call({ from: firstAccount });

      await truffleAssert.reverts(
        this.iProxyHero.methods.purchase(tokenId).send({
          ...optionsSend,
          value: hero.params256[11] + "",
        }),
      );
    });

    it("SUCCESS : try to put hero in sell", async function () {
      const tokenId = 0;
      await this.iProxyHero.methods.putHeroInSell(tokenId, pricePurchase).send({
        ...optionsSend,
      });
    });

    it("SUCCESS : try to get heros in sell", async function () {
      const heroesInSell = await this.iProxyHero.methods.getHerosInSell().call({
        ...optionsSend,
      });
      assert.equal(heroesInSell.length, 1);
      assert.ok(heroesInSell[0].params8.length == 20);
    });

    it("ERROR : try to purchase hero for low price", async function () {
      const tokenId = 0;
      price = "999999999999998";

      await truffleAssert.reverts(
        this.iProxyHero.methods.purchase(tokenId).send({
          ...optionsSend,
          value: price,
        }),
      );
    });

    it("SUCCESS : try to purchase hero for good price", async function () {
      const tokenId = 0;
      const heroBefore = await this.iHero.methods
        .getTokenDetails(tokenId)
        .call({ from: firstAccount });
      assert.ok(heroBefore.params256[11] === pricePurchase);

      const ownerOfBefore = await this.HeroContract.ownerOf(tokenId);
      assert.ok(ownerOfBefore === firstAccount);

      const secondAccountPriceBeforePurchase = await web3.eth.getBalance(secondAccount);
      const firstAccountPriceBeforePurchase = await web3.eth.getBalance(firstAccount);

      await this.iProxyHero.methods.purchase(tokenId).send({
        ...optionsSend,
        from: secondAccount,
        value: heroBefore.params256[11],
      });

      const heroAfter = await this.iHero.methods
        .getTokenDetails(tokenId)
        .call({ from: firstAccount });
      assert.ok(heroAfter.params256[11] === "0");

      const ownerOfAfter = await this.HeroContract.ownerOf(tokenId);
      assert.ok(ownerOfAfter === secondAccount);

      const secondAccountPriceAfterPurchase = await web3.eth.getBalance(secondAccount);
      const firstAccountPriceAfterPurchase = await web3.eth.getBalance(firstAccount);

      assert.ok(
        secondAccountPriceBeforePurchase - secondAccountPriceAfterPurchase >
          pricePurchase,
      );
      assert.ok(
        firstAccountPriceAfterPurchase - firstAccountPriceBeforePurchase >
          pricePurchase - 100000,
      );
    });

    it("SUCCESS : try to get heros in sell", async function () {
      const heroesInSell = await this.iProxyHero.methods.getHerosInSell().call({
        ...optionsSend,
      });
      assert.ok(heroesInSell[0].params8.length === 0);
    });

    it("SUCCESS : try to resell to first account ", async function () {
      const tokenId = 0;
      price = "1000";
      await this.iProxyHero.methods.putHeroInSell(tokenId, price).send({
        ...optionsSend,
        from: secondAccount,
      });

      const hero = await this.iHero.methods
        .getTokenDetails(tokenId)
        .call({ from: firstAccount });

      await this.iProxyHero.methods.purchase(tokenId).send({
        ...optionsSend,
        value: hero.params256[11] + "",
      });
    });

    it("SUCCESS : try to get balance wei of proxy contract, expected fourty five wei", async function () {
      const balance = await this.HeroContract.balanceOf(firstAccount, {
        from: firstAccount,
      });
      assert.equal(balance, 1);
    });
  });

  describe("Quest", async function () {
    it("SUCCESS : try to set three quest", async function () {
      await this.iQuest.methods.setQuest(...firstQuest).send(optionsSend);
      await this.iQuest.methods.setQuest(...secondQuest).send(optionsSend);
      await this.iQuest.methods.setQuest(...thirdQuest).send(optionsSend);
    });

    it("SUCCESS : try to start quest", async function () {
      const tokenId = 0;
      const questId = 0;
      await this.iProxyHero.methods.startQuest(tokenId, questId).send(optionsSend);
    });

    it("ERROR : try to start quest again", async function () {
      const tokenId = 0;
      const questId = 0;
      await truffleAssert.reverts(
        this.iProxyHero.methods.startQuest(tokenId, questId).send(optionsSend),
      );
    });

    it("SUCCESS : try to cancel quest", async function () {
      const tokenId = 0;
      await this.iProxyHero.methods.cancelQuest(tokenId).send(optionsSend);
    });

    it("SUCCESS : try to start quest", async function () {
      const tokenId = 0;
      const questId = 0;
      await this.iProxyHero.methods.startQuest(tokenId, questId).send(optionsSend);
    });

    it("SUCCESS : try to complete quest", async function () {
      console.log("wait 6 sec");
      await timeout(6000);
      const tokenId = 0;
      await this.iProxyHero.methods.completeQuest(tokenId).send(optionsSend);
      mineBlock();
      const hero = await this.iHero.methods
        .getTokenDetails(tokenId)
        .call({ from: firstAccount });
      assert.equal(+hero.params256[3], 0); //questId
      assert.equal(+hero.params256[6], 1); //success
    });

    it("ERROR : try to complete quest already finished", async function () {
      console.log("wait 1 sec");
      await timeout(1000);
      const tokenId = 0;
      await truffleAssert.reverts(
        this.iProxyHero.methods.completeQuest(tokenId).send(optionsSend),
      );
    });

    it("SUCCESS : try to start quest impossible", async function () {
      await timeout(6000);
      const tokenId = 0;
      const questId = 2;
      await this.iProxyHero.methods.startQuest(tokenId, questId).send(optionsSend);
    });

    it("SUCCESS : try to complete quest impossible", async function () {
      console.log("wait 5 sec");
      await timeout(5000);
      const tokenId = 0;
      await this.iProxyHero.methods.completeQuest(tokenId).send(optionsSend);
      mineBlock();
      const hero = await this.iHero.methods
        .getTokenDetails(tokenId)
        .call({ from: firstAccount });
      assert.equal(+hero.params256[3], 2); //questId
      assert.equal(+hero.params256[6], 0); //success
    });

    it("SUCCESS : try to get detail token", async function () {
      const tokenId = 0;
      const hero = await this.iHero.methods
        .getTokenDetails(tokenId)
        .call({ from: firstAccount });
      assert.ok(hero.params8.length === 20, "Array length params 8 not expected");
      assert.ok(hero.params256.length === 20, "Array length params 256 not expected");
      assert.ok(+hero.params256[1] === 100000000000000000, "Price is not good");
      //assert.ok(+hero.params256[0] < Math.floor(Date.now() / 1000), "Time not expected");
      //assert.ok(+hero.params256[2] < Math.floor(Date.now() / 1000), "Time not expected");
    });
  });

  

  describe("Items", async function () {
    it("SUCCESS : try to set items", async function () {
      await this.iItems.methods.setItem(...firstItem).send(optionsSend);
      await this.iItems.methods.setItem(...secondItem).send(optionsSend);
      await this.iItems.methods.setItem(...thirdItem).send(optionsSend);
      await this.iItems.methods.setItem(...fourthItem).send(optionsSend);
    });

    it("SUCCESS : try to get items", async function () {
      const firstItemReturn = await this.iItems.methods
        .getItemDetails(0)
        .call({ from: firstAccount });
      const secondItemReturn = await this.iItems.methods
        .getItemDetails(1)
        .call({ from: firstAccount });
      const thirdItemReturn = await this.iItems.methods
        .getItemDetails(2)
        .call({ from: firstAccount });
      const fourthItemReturn = await this.iItems.methods
        .getItemDetails(3)
        .call({ from: firstAccount });
      assert.equal(firstItemReturn.name, firstItem[0]);
      assert.equal(firstItemReturn.rarity, firstItem[1]);
      assert.equal(firstItemReturn.price, firstItem[2]);
      assert.equal(firstItemReturn.valid, true);

      assert.equal(secondItemReturn.name, secondItem[0]);
      assert.equal(secondItemReturn.rarity, secondItem[1]);
      assert.equal(secondItemReturn.price, secondItem[2]);
      assert.equal(secondItemReturn.valid, true);

      assert.equal(thirdItemReturn.name, thirdItem[0]);
      assert.equal(thirdItemReturn.rarity, thirdItem[1]);
      assert.equal(thirdItemReturn.price, thirdItem[2]);
      assert.equal(thirdItemReturn.valid, true);

      assert.equal(fourthItemReturn.name, fourthItem[0]);
      assert.equal(fourthItemReturn.rarity, fourthItem[1]);
      assert.equal(fourthItemReturn.price, fourthItem[2]);
      assert.equal(fourthItemReturn.valid, true);
    });

    it("SUCCESS : try to get balance items", async function () {
      const contract = this.ItemsContract;
      const balanceItemIdOne = await contract.balanceOf(firstAccount, 0);
      assert.equal(balanceItemIdOne, 1);

      const balanceItemIdTwo = await contract.balanceOf(firstAccount, 1);
      assert.equal(balanceItemIdTwo, 1);

      const balanceItemIdThree = await contract.balanceOf(firstAccount, 2);
      assert.equal(balanceItemIdThree, 1);

      const balanceItemIdFour = await contract.balanceOf(firstAccount, 3);
      assert.equal(balanceItemIdFour, 0);
    });

    it("SUCCESS : try to buy item", async function () {
      const quantity = 2;
      const tokenId = 0;

      const firstItemReturn = await this.iItems.methods
        .getItemDetails(tokenId)
        .call({ from: firstAccount });

      await this.iProxyItems.methods.buyItem(quantity, firstAccount, tokenId).send({
        from: firstAccount,
        value: +firstItemReturn.price * quantity + "",
      });

      const balanceItemIdOne = await this.ItemsContract.balanceOf(firstAccount, tokenId);
      assert.equal(balanceItemIdOne, 3);
    });

    it("ERROR : try to sell item but not enough", async function () {
      const quantity = 5;
      const tokenId = 0;

      await truffleAssert.reverts(
        this.iProxyItems.methods.sellItem(quantity, tokenId).send({ from: firstAccount }),
      );
    });

    it("SUCCESS : try to sell item", async function () {
      const quantity = 2;
      const tokenId = 0;

      // const accountBalanceBeforeSell = await web3.eth.getBalance(firstAccount);

      // const firstItemReturn = await this.ItemsContract.getItemDetails(tokenId);

      const tx = await this.iProxyItems.methods
        .sellItem(quantity, tokenId)
        .send({ from: firstAccount });

      const balanceItemIdOne = await this.ItemsContract.balanceOf(firstAccount, tokenId);
      assert.equal(+(balanceItemIdOne + ""), 1);

      // const accountBalanceAfterSell = await web3.eth.getBalance(firstAccount);

      // assert.equal(
      //   +accountBalanceBeforeSell + "",
      //   +accountBalanceAfterSell +
      //     tx.receipt.gasUsed +
      //     +firstItemReturn.price * quantity +
      //     "",
      // );
    });

    it("SUCCESS : try to convert item", async function () {
      const quantity = 10;
      const fromTokenId = 0;
      const toTokenId = 1;

      await this.ItemsContract.setApprovalForAll(this.ProxyItems.address, {
        from: firstAccount,
      });

      const firstItemReturn = await this.iItems.methods
        .getItemDetails(fromTokenId)
        .call({ from: firstAccount });

      const secondItemReturn = await this.iItems.methods
        .getItemDetails(toTokenId)
        .call({ from: firstAccount });

      const firstItemPriceByQuantity = +firstItemReturn.price * quantity;
      const secondItemPriceByQuantity = +secondItemReturn.price * quantity;

      await this.iProxyItems.methods
        .buyItem(quantity, firstAccount, fromTokenId)
        .send({ ...optionsSend, value: +firstItemReturn.price * quantity + "" });

      const tx = //await catchRevert(
        await this.iProxyItems.methods
          .convertToAnotherToken(firstAccount, quantity, fromTokenId, toTokenId)
          .send(optionsSend);
      //);

      const balanceItemIdOne = await this.ItemsContract.balanceOf(
        firstAccount,
        fromTokenId,
      );
      const balanceItemIdTwo = await this.ItemsContract.balanceOf(
        firstAccount,
        toTokenId,
      );

      assert.equal(+(balanceItemIdOne + ""), 1);
      assert.equal(+(balanceItemIdTwo + ""), 6);
    });
  });

  
  describe("Equipments", async function () {
    it("SUCCESS : try to set equipments", async function () {
      await this.iEquipments.methods.setEquipment(...firstEquipment).send(optionsSend);
      await this.iEquipments.methods.setEquipment(...secondEquipment).send(optionsSend);
      await this.iEquipments.methods.setEquipment(...thirdEquipment).send(optionsSend);
      await this.iEquipments.methods.setEquipment(...fourthEquipment).send(optionsSend);
    });

    it("SUCCESS : try to set address proxy contract on EQUIPMENT contract", async function () {
      await this.iEquipments.methods
        .setaddressProxyContract(this.ProxyEquipments.address)
        .send({
          from: firstAccount,
        });
    });

    it("SUCCESS : try to get equipments", async function () {
      const firstEquipmentReturn = await this.iEquipments.methods
        .getEquipmentDetails(0)
        .call({ from: firstAccount });
      const secondEquipmentReturn = await this.iEquipments.methods
        .getEquipmentDetails(1)
        .call({ from: firstAccount });
      const thirdEquipmentReturn = await this.iEquipments.methods
        .getEquipmentDetails(2)
        .call({ from: firstAccount });
      const fourthEquipmentReturn = await this.iEquipments.methods
        .getEquipmentDetails(3)
        .call({ from: firstAccount });
      assert.equal(firstEquipmentReturn.name, firstEquipment[0]);
      assert.equal(firstEquipmentReturn.rarity, firstEquipment[1]);
      assert.equal(firstEquipmentReturn.price, firstEquipment[2]);
      assert.equal(firstEquipmentReturn.valid, true);

      assert.equal(secondEquipmentReturn.name, secondEquipment[0]);
      assert.equal(secondEquipmentReturn.rarity, secondEquipment[1]);
      assert.equal(secondEquipmentReturn.price, secondEquipment[2]);
      assert.equal(secondEquipmentReturn.valid, true);

      assert.equal(thirdEquipmentReturn.name, thirdEquipment[0]);
      assert.equal(thirdEquipmentReturn.rarity, thirdEquipment[1]);
      assert.equal(thirdEquipmentReturn.price, thirdEquipment[2]);
      assert.equal(thirdEquipmentReturn.valid, true);

      assert.equal(fourthEquipmentReturn.name, fourthEquipment[0]);
      assert.equal(fourthEquipmentReturn.rarity, fourthEquipment[1]);
      assert.equal(fourthEquipmentReturn.price, fourthEquipment[2]);
      assert.equal(fourthEquipmentReturn.valid, true);
    });

    it("SUCCESS : try to get balance equipments", async function () {
      const contract = this.EquipmentsContract;
      const balanceEquipmentIdOne = await contract.balanceOf(firstAccount, 0);
      assert.equal(balanceEquipmentIdOne, 0);

      const balanceEquipmentIdTwo = await contract.balanceOf(firstAccount, 1);
      assert.equal(balanceEquipmentIdTwo, 0);

      const balanceEquipmentIdThree = await contract.balanceOf(firstAccount, 2);
      assert.equal(balanceEquipmentIdThree, 0);

      const balanceEquipmentIdFour = await contract.balanceOf(firstAccount, 3);
      assert.equal(balanceEquipmentIdFour, 0);
    });

    it("SUCCESS : try to buy equipment", async function () {
      const quantity = 2;
      const tokenId = 0;

      const firstEquipmentReturn = await this.iEquipments.methods
        .getEquipmentDetails(tokenId)
        .call({ from: firstAccount });

      await this.iProxyEquipments.methods
        .buyEquipment(quantity, firstAccount, tokenId)
        .send({
          from: firstAccount,
          value: +firstEquipmentReturn.price * quantity + "",
        });

      const balanceEquipmentIdOne = await this.EquipmentsContract.balanceOf(
        firstAccount,
        tokenId,
      );
      assert.equal(+(balanceEquipmentIdOne + ""), 2);
    });

    it("ERROR : try to sell equipment but not enough", async function () {
      const quantity = 5;
      const tokenId = 0;

      await truffleAssert.reverts(
        this.iProxyEquipments.methods
          .sellEquipment(quantity, tokenId)
          .send({ from: firstAccount }),
      );
    });

    it("SUCCESS : try to sell equipment", async function () {
      const quantity = 1;
      const tokenId = 0;

      // const accountBalanceBeforeSell = await web3.eth.getBalance(firstAccount);

      // const firstEquipmentReturn = await this.EquipmentsContract.getEquipmentDetails(tokenId);

      const tx = await this.iProxyEquipments.methods
        .sellEquipment(quantity, tokenId)
        .send({ from: firstAccount });

      const balanceEquipmentIdOne = await this.EquipmentsContract.balanceOf(
        firstAccount,
        tokenId,
      );
      assert.equal(+(balanceEquipmentIdOne + ""), 1);

      // const accountBalanceAfterSell = await web3.eth.getBalance(firstAccount);

      // assert.equal(
      //   +accountBalanceBeforeSell + "",
      //   +accountBalanceAfterSell +
      //     tx.receipt.gasUsed +
      //     +firstEquipmentReturn.price * quantity +
      //     "",
      // );
    });

    it("SUCCESS : try to convert equipment", async function () {
      const quantity = 10;
      const fromTokenId = 0;
      const toTokenId = 1;

      await this.EquipmentsContract.setApprovalForAll(this.ProxyEquipments.address, {
        from: firstAccount,
      });

      const firstEquipmentReturn = await this.iEquipments.methods
        .getEquipmentDetails(fromTokenId)
        .call({ from: firstAccount });

      await this.iProxyEquipments.methods
        .buyEquipment(quantity, firstAccount, fromTokenId)
        .send({ ...optionsSend, value: +firstEquipmentReturn.price * quantity + "" });

      await this.iProxyEquipments.methods
        .convertToAnotherToken(firstAccount, quantity, fromTokenId, toTokenId)
        .send(optionsSend);

      const balanceEquipmentIdOne = await this.EquipmentsContract.balanceOf(
        firstAccount,
        fromTokenId,
      );
      const balanceEquipmentIdTwo = await this.EquipmentsContract.balanceOf(
        firstAccount,
        toTokenId,
      );

      assert.equal(+(balanceEquipmentIdOne + ""), 1);
      assert.equal(+(balanceEquipmentIdTwo + ""), 18);
    });

    it("SUCCESS : try to craft equipment", async function () {
      const tokenId = 0;
      await this.iProxyEquipments.methods.craft(tokenId, firstAccount).send(optionsSend);


      const balanceEquipmentIdOne = await this.EquipmentsContract.balanceOf(
        firstAccount,
        tokenId,
      );

      const balanceItemIdOne = await this.ItemsContract.balanceOf(
        firstAccount,
        fromTokenId,
      );

      assert.equal(+(balanceItemIdOne + ""), 0);
      assert.equal(+(balanceEquipmentIdOne + ""), 2);
    });
  });

  describe("Level up", async function () {
    it("ERROR : try to level up", async function () {
      const statToLvlUp = 1;
      const tokenId = 0;
      await truffleAssert.reverts(
        this.iProxyHero.methods
          .levelUp(statToLvlUp, tokenId)
          .send({ from: firstAccount }),
      );
    });

    it("SUCCESS : try to start quest", async function () {
      const tokenId = 0;
      const questId = 1;
      await this.iProxyHero.methods.startQuest(tokenId, questId).send(optionsSend);
    });

    it("SUCCESS : try to complete quest", async function () {
      console.log("wait 6 sec");
      await timeout(6000);
      const tokenId = 0;
      await this.iProxyHero.methods.completeQuest(tokenId).send(optionsSend);
      mineBlock();
      const hero = await this.iHero.methods
        .getTokenDetails(tokenId)
        .call({ from: firstAccount });
      assert.equal(+hero.params256[3], 1); //questId
      assert.equal(+hero.params256[6], 1); //success
    });

    it("SUCCESS : try to level up", async function () {
      const tokenId = 0;
      const statToLvlUp = 1;

      const heroBeforeLevelUp = await this.iHero.methods
        .getTokenDetails(tokenId)
        .call({ from: firstAccount });

      await this.iProxyHero.methods.levelUp(statToLvlUp, tokenId).send(optionsSend);

      mineBlock();

      const heroAfterLevelUp = await this.iHero.methods
        .getTokenDetails(tokenId)
        .call({ from: firstAccount });
      assert.equal(
        +heroAfterLevelUp.params8[statToLvlUp],
        +heroBeforeLevelUp.params8[statToLvlUp] + 1,
      );
    });
  });
});
