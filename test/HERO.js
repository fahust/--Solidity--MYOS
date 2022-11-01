const { BigNumber, ethers } = require("ethers");
const { CONTRACT_VALUE_ENUM, ADDRESS_ENUM } = require("./enums/enum");
const truffleAssert = require("truffle-assertions");
const timeout = require("./helper/timeout");
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

  const firstQuest = [0, 5, 100, 50, [0, 0, 0, 0, 0, 0], [0, 1, 2, 3]];
  const secondQuest = [1, 10, 100, 50, [0, 0, 2, 0, 0, 0], [0, 1, 2, 3]];
  const thirdQuest = [2, 10, 100, 50, [0, 0, 0, 0, 3, 0], [0, 1, 2, 3]];

  const firstItem = [2, 10, 100, 50, [0, 0, 0, 0, 3, 0], [0, 1, 2, 3]];

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
      await this.instanceDelegateContract.completeQuest(tokenId);
    });

    it("ERROR : try to complete quest already finished", async function () {
      console.log("wait 1 sec");
      await timeout(1000);
      const tokenId = 0;
      await truffleAssert.reverts(this.instanceDelegateContract.completeQuest(tokenId));
    });

    it("SUCCESS : try to get detail token", async function () {
      const tokenId = 0;
      const hero = await this.instanceHeroContract.getTokenDetails(tokenId);
      assert.ok(hero.params8.length === 20, "Array length params 8 not expected");
      assert.ok(hero.params256.length === 10, "Array length params 256 not expected");
      assert.ok(+hero.params256[1] === 100000000000000000, "Price is not good");
      assert.ok(+hero.params256[0] < Math.floor(Date.now() / 1000), "Time not expected");
      assert.ok(+hero.params256[2] < Math.floor(Date.now() / 1000), "Time not expected");
    });
  });

  describe("Items", async function () {});

  describe("Level up", async function () {});

  //X test : level up
  //X test : create item
  //X test : gain item in quest
  //X test : create guild
  //V change : item, one contract for one item => erc1155 item, one id for one item
  //X change : passé en uint8 tout ce qui peut l'être
  //V change : retirer les boolean du hero et mêttre des uint256
  //X change : pour vente et achat, utiliser myos token sinon on devra approve matic et ça c pas coool
});
