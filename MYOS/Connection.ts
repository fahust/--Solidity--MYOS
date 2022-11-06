import { ethers } from "ethers";

import Onboard, { WalletState } from "@web3-onboard/core";
import injectedModule from "@web3-onboard/injected-wallets";
import torusModule from "@web3-onboard/torus";
import walletConnectModule from "@web3-onboard/walletconnect";
import portisModule from "@web3-onboard/portis";
import fortmaticModule from "@web3-onboard/fortmatic";
import ledgerModule from "@web3-onboard/ledger";
import gnosisModule from "@web3-onboard/gnosis";
import Myos from "./Myos";
import {
  CHAIN_HEXA_ENUM,
  CHAIN_ID_ENUM,
  CHAIN_NAME_ENUM,
  RPC_URL_ENUM,
} from "@enums/enum";

const INFURA_ID = "e90c3cf441f04521b898d8ee484ea30f";
const FORTMATIC_KEY = "pk_live_45137B683B703F49";
const PORTIS_ID = "7ad11389-9bf1-429c-ad12-98c28743d2e7";

const injected = injectedModule();

const torus = torusModule();
const portis = portisModule({ apiKey: PORTIS_ID });
const fortmatic = fortmaticModule({ apiKey: FORTMATIC_KEY });

const walletConnect = walletConnectModule({
  qrcodeModalOptions: {
    mobileLinks: ["rainbow", "metamask", "argent", "trust", "imtoken", "pillar"],
  },
});

const ledger = ledgerModule();
const gnosis = gnosisModule();

const onboardConfig = {
  accountCenter: {
    desktop: {
      enabled: false,
    },
    mobile: {
      enabled: false,
    },
  },
  wallets: [
    injected,
    torus as unknown,
    portis as unknown,
    fortmatic as unknown,
    walletConnect as any,
    ledger,
    gnosis,
  ],
  chains: [
    {
      id: CHAIN_HEXA_ENUM.MATIC,
      token: "MATIC",
      label: "Matic Mainnet",
      rpcUrl: RPC_URL_ENUM.MATIC,
    },
    {
      id: CHAIN_HEXA_ENUM.MUMBAI,
      token: "MATIC",
      label: "Matic Mumbai",
      rpcUrl: RPC_URL_ENUM.MUMBAI,
    },
  ],
  appMetadata: {
    name: "Myos",
    icon: "",
    logo: "",
    description: "Make your own story",
    gettingStartedGuide: "",
    explore: "",
    recommendedInjectedWallets: [
      { name: "MetaMask", url: "https://metamask.io" },
      { name: "Coinbase", url: "https://wallet.coinbase.com/" },
    ],
  },
};

/**
 * @category SDK
 */
class Connection extends Myos {
  onboard: any = null;
  wallets: Array<WalletState> = [];

  constructor() {
    super();

    this.onboard = Onboard(onboardConfig);
  }

  /**
   * Reclaim signature web3 to Connect user
   * @category Connection
   */
  async connectWeb3() {
    const wallets = await this.onboard.connectWallet();
    const [primaryWallet] = this.onboard.state.get().wallets;
    this.provider = new ethers.providers.Web3Provider(primaryWallet.provider, "any");
    if (this.provider instanceof ethers.providers.Web3Provider)
      this.signer = this.provider.getSigner();
    this.wallets = wallets;
    this.connectedWeb3 = true;
  }

  /**
   * Discconect user to web3
   * @category Connection
   */
  async disconnectWeb3() {
    this.onboard.state.get().wallets.map(async ({ label }: any) => {
      await this.onboard.disconnectWallet({ label });
    });
    this.connectedWeb3 = false;
  }

  /**
   * Check user is connected
   * @param provider provider web3
   */
  async middleWareConnected(
    provider: ethers.providers.Web3Provider | ethers.providers.BaseProvider | unknown,
  ) {
    try {
      if (!provider) await this.connectWeb3();
    } catch (error) {
      throw new Error("Connection impossible");
    }
  }

  /**
   * Return current connection of user
   * @returns {Wallet, network: {chainId,address,name} } Return all parameter of current connection from API
   * @category Connection
   */
  async currentConnection() {
    if (!this.connectedWeb3) {
      return null;
    }
    const network = await this.provider.getNetwork();
    return {
      wallet: await this.getMySignedAddress(),
      network: {
        chainId: network.chainId,
        address: network.ensAddress as string,
        name: network.name,
      },
    };
  }

  /**
   * get network chain accepted
   * @param {number} chainId chain id
   * @returns {string} name of chain network
   */
  networkChainString(chainId: number): string {
    if (chainId === CHAIN_ID_ENUM.MATIC) {
      return CHAIN_NAME_ENUM.MATIC;
    } else if (chainId === CHAIN_ID_ENUM.MUMBAI) {
      return CHAIN_NAME_ENUM.MUMBAI;
    } else {
      return CHAIN_NAME_ENUM.UNKNOWN;
    }
  }

  /**
   * Return if current network chain ID is accepted in kanji platform
   * @param {number} currentChainId Chain id of current network web3 connected
   * @returns {boolean} Return true if network is accepted, false if it isn't
   * @category Connection
   */
  async networkInChainAccepted(currentChainId: number): Promise<boolean> {
    if (currentChainId === CHAIN_ID_ENUM.MATIC) {
      return true;
    } else if (currentChainId === CHAIN_ID_ENUM.MUMBAI) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * Get Id of current web3 network connected
   * @returns {number} Return current ChainId of network web3 connected
   * @category Connection
   */
  async getIdChainNow(): Promise<number> {
    const network = await this.provider.getNetwork();
    return network.chainId;
  }

  /**
   * get accepted network for project
   * @returns object of network
   */
  async networkAccepted() {
    return {
      "polygon-mainnet": CHAIN_ID_ENUM.MATIC,
      "polygon-mumbai": CHAIN_ID_ENUM.MUMBAI,
    };
  }

  /**
   * check if current chain connected is accepted
   * @returns
   */
  async isCurrentChainAccepted() {
    return this.providerNode
      ? true
      : await this.networkInChainAccepted(await this.getIdChainNow());
  }

  /**
   * force change network
   * @param chainId id of new chain
   */
  async changeNetwork(chainId: string) {
    return await this.onboard.setChain({ chainId: chainId });
  }
}

export default Connection;
