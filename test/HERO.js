const { BigNumber, ethers } = require("ethers");
const { CONTRACT_VALUE_ENUM, ADDRESS_ENUM } = require("./enums/enum");
const truffleAssert = require("truffle-assertions");
const Hero = artifacts.require("Hero");
const Class = artifacts.require("Class");
const DelegateContract = artifacts.require("DelegateContract");

contract("MYOS", async accounts => {
  const firstAccount = accounts[0];
  const secondAccount = accounts[1];
  const defaultPrice = 10;
  const quantity = 10;

  before(async function () {
    this.instanceContract = await Hero.new(
      CONTRACT_VALUE_ENUM.NAME,
      CONTRACT_VALUE_ENUM.SYMBOL,
      CONTRACT_VALUE_ENUM.FIRST_IPFS_HASH,
    ); // we deploy contract

    this.instanceClassContract = await Class.new(); // we deploy contract

    this.instanceDelegateContract = await DelegateContract.new(
      this.instanceContract.address,
      ADDRESS_ENUM.ADDRESS_ZERO,
      this.instanceClassContract.address,
    ); // we deploy contract
  });

  describe("HERO", async function () {
    it("SUCCESS : try to set address delegate contract on MYOS contract", async function () {
      await this.instanceContract.setAddressDelegateContract(
        this.instanceDelegateContract.address,
        { from: firstAccount },
      );
    });
    it("SUCCESS : try to set class", async function () {
      const id = 0;
      const rarity = 100;
      await this.instanceClassContract.setClass(
        id,
        rarity,
        [1, 2, 1, 3, 2, 1],
        "Guerrier",
        {
          from: firstAccount,
        },
      );
    });

    it("SUCCESS : try to mint a hero erc721 by delegate contract", async function () {
      const priceHero = await this.instanceDelegateContract.getParamsContract("price", {
        from: firstAccount,
      });
      console.log(+(priceHero + ""));

      const classe = await this.instanceClassContract.getClassDetails(0);
      console.log(classe);

      await this.instanceDelegateContract.mintDelegate(
        1,
        1,
        CONTRACT_VALUE_ENUM.FIRST_IPFS_HASH,
        { from: firstAccount, value: priceHero + "" },
      );
    });
  });
});
