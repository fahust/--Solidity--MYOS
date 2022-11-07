const { CONTRACT_VALUE_ENUM } = require("../enums/enum");
const truffleAssert = require("truffle-assertions");
const timeout = require("../helper/timeout");
const mineBlock = require("../helper/mineBlock");
const getRandomInt = require("../helper/random");
const { catchRevert } = require("../helper/exceptions");
const Hero = artifacts.require("Hero");
const Class = artifacts.require("Class");
const Quest = artifacts.require("Quest");
const Items = artifacts.require("Items");
const ProxyHero = artifacts.require("ProxyHero");
const ProxyItems = artifacts.require("ProxyItems");

contract("HERO", async accounts => {
  const firstAccount = accounts[0];
  const secondAccount = accounts[1];
  const defaultPrice = 10;
  const quantity = 10;
  const Splitter = [0, 25, [1, 2, 1, 3, 2, 1], "Splitter"];
  const Guardian = [0, 100, [1, 2, 1, 3, 2, 1], "Guardian"];
  const Wise = [0, 15, [1, 2, 1, 3, 2, 1], "Wise"];
  const Phantom = [0, 9, [1, 2, 1, 3, 2, 1], "Phantom"];

  const firstQuest = [0, 5, 100, 0, [0, 0, 0, 0, 0, 0], [0, 1, 2]];
  const secondQuest = [1, 5, 1000, 0, [0, 0, 2, 0, 0, 0], [0]];
  const thirdQuest = [2, 3, 1000, 101, [0, 0, 0, 0, 3, 0], [0, 2, 3]]; //impossible

  const firstItem = ["Wood", 5000, 10, 0];
  const secondItem = ["Iron", 3000, 20, 1];
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

    this.instanceProxyHero = await ProxyHero.new(
      this.instanceHeroContract.address,
      this.instanceQuestContract.address,
      this.instanceClassContract.address,
      this.instanceItemsContract.address,
    ); // we deploy contract

    this.instanceProxyItems = await ProxyItems.new(this.instanceItemsContract.address);
  });

  describe("Create class and hero", async function () {
    it("SUCCESS : try test", async function () {
      for (let index = 0; index < 20; index++) {
        const firstPrice = getRandomInt(1, 30000000000);
        const secondPrice = getRandomInt(1, 30000000000);
        const quantity = getRandomInt(1, 30000000000);
        await this.instanceProxyItems.calculConversionQuantity(
          firstPrice,
          secondPrice,
          quantity,
          {
            from: firstAccount,
          },
        );
      }
    });

    it("SUCCESS : try to set address proxy contract on MYOS contract", async function () {
      await this.instanceHeroContract.setAddressProxyContract(
        this.instanceProxyHero.address,
        { from: firstAccount },
      );
    });

    it("SUCCESS : try to set class", async function () {
      await this.instanceClassContract.setClass(...Splitter, {
        from: firstAccount,
      });
    });

    it("SUCCESS : try to set address proxy contract on MYOS contract", async function () {
      const classe = await this.instanceClassContract.getClassDetails(0);
      assert.equal(+classe.id, +Splitter[0]);
      assert.equal(+classe.rarity, +Splitter[1]);
      assert.equal(classe.name, Splitter[3]);
    });

    it("SUCCESS : try to mint a hero erc721 by proxy contract", async function () {
      const priceHero = await this.instanceProxyHero.getParamsContract("price", {
        from: firstAccount,
      });

      await this.instanceProxyHero.mintHero(0, 0, CONTRACT_VALUE_ENUM.FIRST_IPFS_HASH, {
        from: firstAccount,
        value: priceHero + "",
      });
    });

    it("SUCCESS : try to get balance wei of proxy contract, expected fourty five wei", async function () {
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
      await this.instanceProxyHero.startQuest(tokenId, questId);
    });

    it("ERROR : try to start quest again", async function () {
      const tokenId = 0;
      const questId = 0;
      await truffleAssert.reverts(this.instanceProxyHero.startQuest(tokenId, questId));
    });

    it("SUCCESS : try to complete quest", async function () {
      console.log("wait 6 sec");
      await timeout(6000);
      const tokenId = 0;
      await this.instanceProxyHero.completeQuest(tokenId);
      mineBlock();
      const hero = await this.instanceHeroContract.getTokenDetails(tokenId);
      assert.equal(+hero.params256[3], 0); //questId
      assert.equal(+hero.params256[6], 1); //success
    });

    it("ERROR : try to complete quest already finished", async function () {
      console.log("wait 1 sec");
      await timeout(1000);
      const tokenId = 0;
      await truffleAssert.reverts(this.instanceProxyHero.completeQuest(tokenId));
    });

    it("SUCCESS : try to start quest impossible", async function () {
      const tokenId = 0;
      const questId = 2;
      await this.instanceProxyHero.startQuest(tokenId, questId);
    });

    it("SUCCESS : try to complete quest impossible", async function () {
      console.log("wait 5 sec");
      await timeout(5000);
      const tokenId = 0;
      await this.instanceProxyHero.completeQuest(tokenId);
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

    it("SUCCESS : try to buy item", async function () {
      const quantity = 2;
      const tokenId = 0;

      const firstItemReturn = await this.instanceItemsContract.getItemDetails(tokenId);

      await this.instanceProxyItems.buyItem(quantity, firstAccount, tokenId, {
        from: firstAccount,
        value: +firstItemReturn.price * quantity + "",
      });

      const balanceItemIdOne = await this.instanceItemsContract.balanceOf(
        firstAccount,
        tokenId,
      );
      assert.equal(balanceItemIdOne, 3);
    });

    it("ERROR : try to sell item but not enough", async function () {
      const quantity = 5;
      const tokenId = 0;

      await truffleAssert.reverts(this.instanceProxyItems.sellItem(quantity, tokenId));
    });

    it("SUCCESS : try to sell item", async function () {
      const quantity = 2;
      const tokenId = 0;

      // const accountBalanceBeforeSell = await web3.eth.getBalance(firstAccount);

      // const firstItemReturn = await this.instanceItemsContract.getItemDetails(tokenId);

      const tx = await this.instanceProxyItems.sellItem(quantity, tokenId);

      const balanceItemIdOne = await this.instanceItemsContract.balanceOf(
        firstAccount,
        tokenId,
      );
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

      await this.instanceItemsContract.setApprovalForAll(
        this.instanceProxyItems.address,
        {
          from: firstAccount,
        },
      );

      const firstItemReturn = await this.instanceItemsContract.getItemDetails(
        fromTokenId,
      );

      const secondItemReturn = await this.instanceItemsContract.getItemDetails(toTokenId);

      const firstItemPriceByQuantity = +firstItemReturn.price * quantity;
      const secondItemPriceByQuantity = +secondItemReturn.price * quantity;

      await this.instanceProxyItems.buyItem(quantity, firstAccount, fromTokenId, {
        from: firstAccount,
        value: +firstItemReturn.price * quantity + "",
      });

      const tx = //await catchRevert(
        await this.instanceProxyItems.convertToAnotherToken(
          firstAccount,
          quantity,
          fromTokenId,
          toTokenId,
        );
      //);

      const balanceItemIdOne = await this.instanceItemsContract.balanceOf(
        firstAccount,
        fromTokenId,
      );
      const balanceItemIdTwo = await this.instanceItemsContract.balanceOf(
        firstAccount,
        toTokenId,
      );

      assert.equal(+(balanceItemIdOne + ""), 1);
      assert.equal(+(balanceItemIdTwo + ""), 6);
    });
  });

  describe("Level up", async function () {
    it("ERROR : try to level up", async function () {
      const statToLvlUp = 1;
      const tokenId = 0;
      await truffleAssert.reverts(this.instanceProxyHero.levelUp(statToLvlUp, tokenId));
    });

    it("SUCCESS : try to start quest", async function () {
      const tokenId = 0;
      const questId = 1;
      await this.instanceProxyHero.startQuest(tokenId, questId);
    });

    it("SUCCESS : try to complete quest", async function () {
      console.log("wait 6 sec");
      await timeout(6000);
      const tokenId = 0;
      await this.instanceProxyHero.completeQuest(tokenId);
      mineBlock();
      const hero = await this.instanceHeroContract.getTokenDetails(tokenId);
      assert.equal(+hero.params256[3], 1); //questId
      assert.equal(+hero.params256[6], 1); //success
    });

    it("SUCCESS : try to level up", async function () {
      const tokenId = 0;
      const statToLvlUp = 1;

      const heroBeforeLevelUp = await this.instanceHeroContract.getTokenDetails(tokenId);
      await this.instanceProxyHero.levelUp(statToLvlUp, tokenId);
      mineBlock();
      const heroAfterLevelUp = await this.instanceHeroContract.getTokenDetails(tokenId);
      assert.equal(
        +heroAfterLevelUp.params8[statToLvlUp],
        +heroBeforeLevelUp.params8[statToLvlUp] + 1,
      );
    });
  });
});
