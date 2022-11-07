const { CONTRACT_VALUE_ENUM } = require("../enums/enum");
const truffleAssert = require("truffle-assertions");
const MYOS = artifacts.require("MYOS");
const ProxyMYOS = artifacts.require("ProxyMYOS");
const IProxyMYOS = require("../abi/IProxyMyos.json");
const IMYOS = require("../abi/IMYOS.json");

contract("MYOS", async accounts => {
  const firstAccount = accounts[0];
  const secondAccount = accounts[1];
  const defaultPrice = 10;
  const quantity = 10;

  before(async function () {
    this.instanceMyos = await MYOS.new(
      CONTRACT_VALUE_ENUM.MAX_SUPPLY,
      CONTRACT_VALUE_ENUM.NAME,
      CONTRACT_VALUE_ENUM.SYMBOL,
    ); // we deploy contract

    this.instanceProxy = await ProxyMYOS.new(); // we deploy contract

    this.iMyos = new web3.eth.Contract(IMYOS.abi, this.instanceMyos.address);
    this.iProxyMyos = new web3.eth.Contract(IProxyMYOS.abi, this.instanceProxy.address);
  });

  describe("MYOS : BUY, SELL, BALANCE", async function () {
    it("SUCCESS : try to set address proxy contract on MYOS contract", async function () {
      await this.iMyos.methods
        .setAddressProxyContract(this.instanceProxy.address)
        .send({ from: firstAccount });
    });

    it("SUCCESS : try to set address MYOS contract on proxy contract", async function () {
      await this.iProxyMyos.methods
        .setAddressMYOSToken(this.instanceMyos.address)
        .send({ from: firstAccount });
    });

    it("ERROR : (division by 0), try to get dynamic price", async function () {
      await truffleAssert.reverts(
        this.iProxyMyos.methods.getDynamicPriceMYOS().call({ from: firstAccount }),
      );
    });

    it("SUCCESS : try to get dynamic price", async function () {
      await this.iProxyMyos.methods
        .setCurrentPriceMYOS(defaultPrice)
        .send({ from: firstAccount });
    });

    it("SUCCESS : try to buy", async function () {
      await this.iProxyMyos.methods
        .buyMYOS(quantity, firstAccount, [], 0)
        .send({ from: firstAccount, value: defaultPrice * quantity });
    });

    it("SUCCESS : try to get balance of firstAccount", async function () {
      const decimal = await this.instanceMyos.decimals();
      assert.equal(+(decimal + ""), 18);

      const balance = await this.instanceMyos.balanceOf(firstAccount);
      assert.equal(+(balance + "") / 10 ** decimal, quantity);
    });

    it("ERROR : try to sell ten MYOS token with secondAccount", async function () {
      await truffleAssert.reverts(
        this.iProxyMyos.methods.sellMYOS(quantity).send({ from: secondAccount }),
      );
    });

    it("ERROR : try to sell eleven MYOS token but not enough", async function () {
      await truffleAssert.reverts(
        this.iProxyMyos.methods.sellMYOS(11).send({ from: firstAccount }),
      );
    });

    it("SUCCESS : try to sell one MYOS token", async function () {
      await this.iProxyMyos.methods.sellMYOS(1).send({ from: firstAccount });
    });

    it("SUCCESS : try to get balance of firstAccount, expected nine MYOS token", async function () {
      const decimal = await this.instanceMyos.decimals();
      assert.equal(+(decimal + ""), 18);

      const balance = await this.instanceMyos.balanceOf(firstAccount);
      assert.equal(+(balance + "") / 10 ** decimal, quantity - 1);
    });

    it("SUCCESS : try to set current price MYOS to 5 wei by token", async function () {
      await this.iProxyMyos.methods
        .setCurrentPriceMYOS(defaultPrice - 5)
        .send({ from: firstAccount });
    });

    it("SUCCESS : try to sell nine MYOS token", async function () {
      await this.iProxyMyos.methods.sellMYOS(quantity - 1).send({ from: firstAccount });
    });

    it("ERROR : try to sell one MYOS token but not enough", async function () {
      await truffleAssert.reverts(
        this.iProxyMyos.methods.sellMYOS(1).send({ from: firstAccount }),
      );
    });

    it("SUCCESS : try to get balance of firstAccount, expected zero MYOS token", async function () {
      const decimal = await this.instanceMyos.decimals();
      assert.equal(+(decimal + ""), 18);

      const balance = await this.instanceMyos.balanceOf(firstAccount);
      assert.equal(+(balance + "") / 10 ** decimal, 0);
    });

    it("SUCCESS : try to get balance wei of delegate contract, expected fourty five wei", async function () {
      const contractBalance = await web3.eth.getBalance(this.instanceProxy.address);
      assert.equal(contractBalance, 45);
    });
  });
});
