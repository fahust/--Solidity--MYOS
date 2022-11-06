import MYOSContract from "@abi/MYOS.json";
import ClassContract from "@abi/Class.json";
import DelegateContractMYOS from "@abi/DelegateContractMYOS.json";
import DelegateContract from "@abi/DelegateContract.json";
import HeroContract from "@abi/Hero.json";
import QuestContract from "@abi/Quest.json";
import ItemsContract from "@abi/Items.json";
import GuildContract from "@abi/Guild.json";
import { ethers } from "ethers";
import { ADDRESS_ENUM, CONTRACT_ENUM } from "@enums/enum";

export default class MYOS {
  provider!: ethers.providers.Web3Provider | ethers.providers.BaseProvider;
  signer!: ethers.providers.JsonRpcSigner | any;
  addressContract!: string;

  providerNode!: ethers.providers.BaseProvider;
  walletWithProvider!: ethers.Wallet;

  connectedWeb3 = false;
  testing = false;

  /**
   * Create an instance of contract with them you want interact
   * @param {CONTRACT_ENUM} type
   * @param {string} address
   * @returns {ethers.Contract} contract instance
   */
  contractInstance(type: CONTRACT_ENUM, address: string): ethers.Contract {
    return new ethers.Contract(
      address,
      this.abiContract(type),
      this.walletWithProvider ? this.walletWithProvider : this.signer,
    );
  }

  abiContract(type: CONTRACT_ENUM) {
    switch (type) {
      case CONTRACT_ENUM.CLASS:
        return ClassContract.abi;
      case CONTRACT_ENUM.DELEGATE:
        return DelegateContract.abi;
      case CONTRACT_ENUM.DELEGATEMYOS:
        return DelegateContractMYOS.abi;
      case CONTRACT_ENUM.GUILD:
        return GuildContract.abi;
      case CONTRACT_ENUM.HERO:
        return HeroContract.abi;
      case CONTRACT_ENUM.ITEMS:
        return ItemsContract.abi;
      case CONTRACT_ENUM.MYOS:
        return MYOSContract.abi;
      case CONTRACT_ENUM.QUEST:
        return QuestContract.abi;
      default:
        return MYOSContract.abi;
    }
  }

  /**
   * Return signed public address of current wallet
   * @returns {string} address wallet
   * @category UTILS
   */
  async getMySignedAddress(): Promise<string> {
    if (this.connectedWeb3) {
      return await this.signer.getAddress();
    } else if (this.testing === true) {
      return ADDRESS_ENUM.CONTRACT_CREATOR;
    } else {
      return "Not connected to web3";
    }
  }

  /**
   * Force await a transaction
   * @param tx
   */
  async waitTx(tx: ethers.ContractTransaction) {
    await tx.wait();
  }

  /**
   * Call smart contract DelegateContractMYOS.sol to buy a quantity of myos token
   * @param quantity
   * @param to
   * @param expectedProof
   * @param proofMaxQuantityPerTransaction
   * @returns
   */
  async buyMYOS(
    quantity: number,
    to = this.getMySignedAddress(),
    expectedProof = [],
    proofMaxQuantityPerTransaction = 0,
  ) {
    const contractInstance = this.contractInstance(
      CONTRACT_ENUM.DELEGATEMYOS,
      this.addressContract,
    );
    let price = +((await contractInstance.getCurrentpriceMYOS()) + "");
    if (price === 0) price = +((await contractInstance.getDynamicPriceMYOS()) + "");
    const tx = contractInstance.buyMYOS(
      quantity,
      to,
      expectedProof,
      proofMaxQuantityPerTransaction,
      {
        from: this.getMySignedAddress(),
        value: price * quantity,
      },
    );
    await this.waitTx(tx);
    return tx;
  }
}

///TO DO CONSTANT IMMUTABLE & ERROR REVERT & event
