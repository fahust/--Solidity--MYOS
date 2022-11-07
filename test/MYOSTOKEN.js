const { CONTRACT_VALUE_ENUM } = require("../enums/enum");
const truffleAssert = require("truffle-assertions");
const MYOS = artifacts.require("MYOS");
const ProxyMYOS = artifacts.require("ProxyMYOS");

contract("MYOS", async accounts => {
  const firstAccount = accounts[0];
  const secondAccount = accounts[1];
  const defaultPrice = 10;
  const quantity = 10;

  before(async function () {
    this.instanceContract = await MYOS.new(
      CONTRACT_VALUE_ENUM.MAX_SUPPLY,
      CONTRACT_VALUE_ENUM.NAME,
      CONTRACT_VALUE_ENUM.SYMBOL,
    ); // we deploy contract

    this.instanceProxy = await ProxyMYOS.new(); // we deploy contract
  });

  describe("MYOS : BUY, SELL, BALANCE", async function () {
    it("SUCCESS : try to set address proxy contract on MYOS contract", async function () {
      await this.instanceContract.setAddressProxyContract(this.instanceProxy.address, {
        from: firstAccount,
      });
    });

    it("SUCCESS : try to set address MYOS contract on proxy contract", async function () {
      await this.instanceProxy.setAddressMYOSToken(this.instanceContract.address, {
        from: firstAccount,
      });
    });

    it("ERROR : (division by 0), try to get dynamic price", async function () {
      await truffleAssert.reverts(
        this.instanceProxy.getDynamicPriceMYOS({
          from: firstAccount,
        }),
      );
    });

    it("SUCCESS : try to get dynamic price", async function () {
      await this.instanceProxy.setCurrentPriceMYOS(defaultPrice, {
        from: firstAccount,
      });
    });

    it("SUCCESS : try to buy", async function () {
      await this.instanceProxy.buyMYOS(quantity, firstAccount, [], 0, {
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

    it("ERROR : try to sell ten MYOS token with secondAccount", async function () {
      await truffleAssert.reverts(
        this.instanceProxy.sellMYOS(quantity, {
          from: secondAccount,
        }),
      );
    });

    it("ERROR : try to sell eleven MYOS token but not enough", async function () {
      await truffleAssert.reverts(
        this.instanceProxy.sellMYOS(11, {
          from: firstAccount,
        }),
      );
    });

    it("SUCCESS : try to sell one MYOS token", async function () {
      await this.instanceProxy.sellMYOS(1, {
        from: firstAccount,
      });
    });

    it("SUCCESS : try to get balance of firstAccount, expected nine MYOS token", async function () {
      const decimal = await this.instanceContract.decimals({
        from: firstAccount,
      });
      assert.equal(+(decimal + ""), 18);

      const balance = await this.instanceContract.balanceOf(firstAccount, {
        from: firstAccount,
      });
      assert.equal(+(balance + "") / 10 ** decimal, quantity - 1);
    });

    it("SUCCESS : try to set current price MYOS to 5 wei by token", async function () {
      await this.instanceProxy.setCurrentPriceMYOS(defaultPrice - 5, {
        from: firstAccount,
      });
    });

    it("SUCCESS : try to sell nine MYOS token", async function () {
      await this.instanceProxy.sellMYOS(quantity - 1, {
        from: firstAccount,
      });
    });

    it("ERROR : try to sell one MYOS token but not enough", async function () {
      await truffleAssert.reverts(
        this.instanceProxy.sellMYOS(1, {
          from: firstAccount,
        }),
      );
    });

    it("SUCCESS : try to get balance of firstAccount, expected zero MYOS token", async function () {
      const decimal = await this.instanceContract.decimals({
        from: firstAccount,
      });
      assert.equal(+(decimal + ""), 18);

      const balance = await this.instanceContract.balanceOf(firstAccount, {
        from: firstAccount,
      });
      assert.equal(+(balance + "") / 10 ** decimal, 0);
    });

    it("SUCCESS : try to get balance wei of delegate contract, expected fourty five wei", async function () {
      const contractBalance = await web3.eth.getBalance(this.instanceProxy.address);
      assert.equal(contractBalance, 45);
    });
  });
});
