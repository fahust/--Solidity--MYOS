const { BigNumber, ethers } = require("ethers");
const { CONTRACT_VALUE_ENUM } = require("./enums/enum");
const MYOS = artifacts.require("MYOS");
const DelegateContractMYOS = artifacts.require("DelegateContractMYOS");

contract("MYOS", async accounts => {
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
      this.instanceContract.setAddressDelegateContract(
        this.instanceDelegateContract.address,
        { from: accounts[0] },
      );
    });

    it("SUCCESS : try to set address MYOS contract on delegate contract", async function () {
      this.instanceDelegateContract.setAddressMYOSToken(this.instanceContract.address, {
        from: accounts[0],
      });
    });
    
  });
});
