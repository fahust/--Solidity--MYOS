const { BigNumber, ethers } = require("ethers");
const { CONTRACT_VALUE_ENUM, ADDRESS_ENUM } = require("./enums/enum");
const truffleAssert = require("truffle-assertions");
const timeout = require("./helper/timeout");
const Hero = artifacts.require("Hero");
const Class = artifacts.require("Class");
const Quest = artifacts.require("Quest");
const DelegateContract = artifacts.require("DelegateContract");

contract("HERO", async accounts => {
  const firstAccount = accounts[0];
  const secondAccount = accounts[1];
  const defaultPrice = 10;
  const quantity = 10;
  const warrior = [0, 100, [1, 2, 1, 3, 2, 1], "Guerrier"];

  const firstQuest = [0, 5, 100, 50, [0, 0, 0, 0, 0, 0],[0,1,2,3]];
  const secondQuest = [1, 10, 100, 50, [0, 0, 2, 0, 0, 0],[0,1,2,3]];
  const thirdQuest = [2, 10, 100, 50, [0, 0, 0, 0, 3, 0],[0,1,2,3]];

  before(async function () {
    this.instanceContract = await Hero.new(
      CONTRACT_VALUE_ENUM.NAME,
      CONTRACT_VALUE_ENUM.SYMBOL,
      CONTRACT_VALUE_ENUM.FIRST_IPFS_HASH,
    ); // we deploy contract

    this.instanceClassContract = await Class.new(); // we deploy contract
    this.instanceQuestContract = await Quest.new();

    this.instanceDelegateContract = await DelegateContract.new(
      this.instanceContract.address,
      this.instanceQuestContract.address,
      this.instanceClassContract.address,
    ); // we deploy contract
  });

  describe("Create class and hero", async function () {
    it("SUCCESS : try to set address delegate contract on MYOS contract", async function () {
      await this.instanceContract.setAddressDelegateContract(
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

      await this.instanceDelegateContract.mintDelegate(
        0,
        0,
        CONTRACT_VALUE_ENUM.FIRST_IPFS_HASH,
        { from: firstAccount, value: priceHero + "" },
      );
    });

    it("SUCCESS : try to get balance wei of delegate contract, expected fourty five wei", async function () {
      const balance = await this.instanceContract.balanceOf(firstAccount, {
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
  });

  describe("Level up", async function () {});

  //level up
  //create item
  //gain item in quest
  //create guild
  //item, one contract for one item => erc1155 item, one id for one item
  //passé en uint8 tout ce qui peut l'être
  //retirer les boolean du hero et mêttre des uint256
  //pour vente et achat, utiliser myos token sinon on devra approve matic et ça c pas coool
});
