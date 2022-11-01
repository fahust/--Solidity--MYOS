const { BigNumber, ethers } = require("ethers");
const { CONTRACT_VALUE_ENUM, ADDRESS_ENUM } = require("./enums/enum");
const truffleAssert = require("truffle-assertions");
const timeout = require("./helper/timeout");
const mineBlock = require("./helper/mineBlock");
const Hero = artifacts.require("Hero");
const Class = artifacts.require("Class");
const Quest = artifacts.require("Quest");
const Items = artifacts.require("Items");
const DelegateContract = artifacts.require("DelegateContract");

contract("HERO", async accounts => {
  const firstAccount = accounts[0];
  const secondAccount = accounts[1];
  const defaultPrice = 10;
  const quantity = 10;
  const warrior = [0, 100, [1, 2, 1, 3, 2, 1], "Guerrier"];

  const firstQuest = [0, 5, 100, 0, [0, 0, 0, 0, 0, 0], [0, 1, 2]];
  const secondQuest = [1, 10, 100, 50, [0, 0, 2, 0, 0, 0], [0, 1, 3]];
  const thirdQuest = [2, 3, 100, 101, [0, 0, 0, 0, 3, 0], [0, 2, 3]]; //impossible

  const firstItem = ["Wood", 5000, 10, 0];
  const secondItem = ["Iron", 3000, 30, 1];
  const thirdItem = ["Food", 8888, 2, 2];
  const fourthItem = ["Fish", 7500, 3, 3];

  before(async function () {
    this.instanceHeroContract = await Hero.new(
      CONTRACT_VALUE_ENUM.NAME,
      CONTRACT_VALUE_ENUM.SYMBOL,
      CONTRACT_VALUE_ENUM.FIRST_IPFS_HASH,
    ); // we deploy contract

    this.instanceClassContract = await Class.new(); // we deploy contract
    this.instanceQuestContract = await Quest.new();
    this.instanceItemsContract = await Items.new(CONTRACT_VALUE_ENUM.FIRST_IPFS_HASH);

    this.instanceDelegateContract = await DelegateContract.new(
      this.instanceHeroContract.address,
      this.instanceQuestContract.address,
      this.instanceClassContract.address,
      this.instanceItemsContract.address,
    ); // we deploy contract
  });

  describe("Create class and hero", async function () {
    it("SUCCESS : try to set address delegate contract on MYOS contract", async function () {
      await this.instanceHeroContract.setAddressDelegateContract(
        this.instanceDelegateContract.address,
        { from: firstAccount },
      );
    });

    it("SUCCESS : try to set class", async function () {
      await this.instanceClassContract.setClass(...warrior, {
        from: firstAccount,
      });
    });

    it("SUCCESS : try to set address delegate contract on MYOS contract", async function () {
      const classe = await this.instanceClassContract.getClassDetails(0);
      assert.equal(+classe.id, +warrior[0]);
      assert.equal(+classe.rarity, +warrior[1]);
      assert.equal(classe.name, warrior[3]);
    });

    it("SUCCESS : try to mint a hero erc721 by delegate contract", async function () {
      const priceHero = await this.instanceDelegateContract.getParamsContract("price", {
        from: firstAccount,
      });

      await this.instanceDelegateContract.mintHero(
        0,
        0,
        CONTRACT_VALUE_ENUM.FIRST_IPFS_HASH,
        { from: firstAccount, value: priceHero + "" },
      );
    });

    it("SUCCESS : try to get balance wei of delegate contract, expected fourty five wei", async function () {
      const balance = await this.instanceHeroContract.balanceOf(firstAccount, {
        from: firstAccount,
      });
      assert.equal(balance, 1);
    });
  });

  describe("Quest", async function () {
    it("SUCCESS : try to set three quest", async function () {
      await this.instanceQuestContract.setQuest(...firstQuest);
      await this.instanceQuestContract.setQuest(...secondQuest);
      await this.instanceQuestContract.setQuest(...thirdQuest);
    });

    it("SUCCESS : try to start quest", async function () {
      const tokenId = 0;
      const questId = 0;
      await this.instanceDelegateContract.startQuest(tokenId, questId);
    });

    it("ERROR : try to start quest again", async function () {
      const tokenId = 0;
      const questId = 0;
      await truffleAssert.reverts(
        this.instanceDelegateContract.startQuest(tokenId, questId),
      );
    });

    it("SUCCESS : try to complete quest", async function () {
      console.log("wait 6 sec");
      await timeout(6000);
      const tokenId = 0;
      const completedQuest = await this.instanceDelegateContract.completeQuest(tokenId);
      mineBlock();
      const hero = await this.instanceHeroContract.getTokenDetails(tokenId);
      assert.equal(+hero.params256[3], 0); //questId
      assert.equal(+hero.params256[6], 1); //success
    });

    it("ERROR : try to complete quest already finished", async function () {
      console.log("wait 1 sec");
      await timeout(1000);
      const tokenId = 0;
      await truffleAssert.reverts(this.instanceDelegateContract.completeQuest(tokenId));
    });

    it("SUCCESS : try to start quest impossible", async function () {
      const tokenId = 0;
      const questId = 2;
      await this.instanceDelegateContract.startQuest(tokenId, questId);
    });

    it("SUCCESS : try to complete quest impossible", async function () {
      console.log("wait 5 sec");
      await timeout(5000);
      const tokenId = 0;
      const completedQuest = await this.instanceDelegateContract.completeQuest(tokenId);
      mineBlock();
      const hero = await this.instanceHeroContract.getTokenDetails(tokenId);
      assert.equal(+hero.params256[3], 2); //questId
      assert.equal(+hero.params256[6], 0); //success
    });

    it("SUCCESS : try to get detail token", async function () {
      const tokenId = 0;
      const hero = await this.instanceHeroContract.getTokenDetails(tokenId);
      assert.ok(hero.params8.length === 20, "Array length params 8 not expected");
      assert.ok(hero.params256.length === 20, "Array length params 256 not expected");
      assert.ok(+hero.params256[1] === 100000000000000000, "Price is not good");
      //assert.ok(+hero.params256[0] < Math.floor(Date.now() / 1000), "Time not expected");
      //assert.ok(+hero.params256[2] < Math.floor(Date.now() / 1000), "Time not expected");
    });
  });

  describe("Items", async function () {
    it("SUCCESS : try to set items", async function () {
      await this.instanceItemsContract.setItem(...firstItem);
      await this.instanceItemsContract.setItem(...secondItem);
      await this.instanceItemsContract.setItem(...thirdItem);
      await this.instanceItemsContract.setItem(...fourthItem);
    });

    it("SUCCESS : try to get items", async function () {
      const firstItemReturn = await this.instanceItemsContract.getItemDetails(0);
      const secondItemReturn = await this.instanceItemsContract.getItemDetails(1);
      const thirdItemReturn = await this.instanceItemsContract.getItemDetails(2);
      const fourthItemReturn = await this.instanceItemsContract.getItemDetails(3);
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
      const contract = this.instanceItemsContract;
      const balanceItemIdOne = await contract.balanceOf(firstAccount, 0);
      assert.equal(balanceItemIdOne, 1);

      const balanceItemIdTwo = await contract.balanceOf(firstAccount, 1);
      assert.equal(balanceItemIdTwo, 1);

      const balanceItemIdThree = await contract.balanceOf(firstAccount, 2);
      assert.equal(balanceItemIdThree, 1);

      const balanceItemIdFour = await contract.balanceOf(firstAccount, 3);
      assert.equal(balanceItemIdFour, 0);
    });
  });

  describe("Level up", async function () {});

  //X test : level up
  //V test : create item
  //X test : gain item in quest
  //X test : create guild
  //V change : item, one contract for one item => erc1155 item, one id for one item
  //X change : passé en uint8 tout ce qui peut l'être
  //V change : retirer les boolean du hero et mêttre des uint256
  //X change : pour vente et achat, utiliser myos token sinon on devra approve matic et ça c pas coool
});
