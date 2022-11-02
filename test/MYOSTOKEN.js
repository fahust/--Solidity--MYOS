const { BigNumber, ethers } = require("ethers");
const { CONTRACT_VALUE_ENUM } = require("./enums/enum");
const truffleAssert = require("truffle-assertions");
const MYOS = artifacts.require("MYOS");
const DelegateContractMYOS = artifacts.require("DelegateContractMYOS");

contract("MYOS", async accounts => {
  const firstAccount = accounts[0];
  const defaultPrice = 10;
  const quantity = 10;

  before(async function () {
    this.instanceContract = await MYOS.new(
      CONTRACT_VALUE_ENUM.MAX_SUPPLY,
      CONTRACT_VALUE_ENUM.NAME,
      CONTRACT_VALUE_ENUM.SYMBOL,
    ); // we deploy contract

    this.instanceDelegateContract = await DelegateContractMYOS.new(); // we deploy contract
  });

  describe("", async function () {
    it("SUCCESS : try to set address delegate contract on MYOS contract", async function () {
      await this.instanceContract.setAddressDelegateContract(
        this.instanceDelegateContract.address,
        { from: firstAccount },
      );
    });

    it("SUCCESS : try to set address MYOS contract on delegate contract", async function () {
      await this.instanceDelegateContract.setAddressMYOSToken(
        this.instanceContract.address,
        {
          from: firstAccount,
        },
      );
    });

    it("ERROR : (division by 0), try to get dynamic price", async function () {
      await truffleAssert.reverts(
        this.instanceDelegateContract.getDynamicPriceMYOS({
          from: firstAccount,
        }),
      );
    });

    it("SUCCESS : try to get dynamic price", async function () {
      await this.instanceDelegateContract.setCurrentPriceMYOS(defaultPrice, {
        from: firstAccount,
      });
    });

    it("SUCCESS : try to mint", async function () {
      await this.instanceDelegateContract.buyMYOS(quantity, firstAccount, [], 0, {
        from: firstAccount,
        value: defaultPrice * quantity,
      });
    });

    it("SUCCESS : try to get balance of firstAccount", async function () {
      const decimal = await this.instanceContract.decimals({
        from: firstAccount,
      });
      assert.equal(+(decimal + ""), 18);

      const balance = await this.instanceContract.balanceOf(firstAccount, {
        from: firstAccount,
      });
      assert.equal(+(balance + "") / 10 ** decimal, quantity);
    });
  });
});
