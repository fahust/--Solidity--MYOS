
import { ethers } from 'ethers';


import Onboard, { WalletState } from '@web3-onboard/core';
import injectedModule from '@web3-onboard/injected-wallets';
import torusModule from '@web3-onboard/torus';
import walletConnectModule from '@web3-onboard/walletconnect';
import portisModule from '@web3-onboard/portis';
import fortmaticModule from '@web3-onboard/fortmatic';
import ledgerModule from '@web3-onboard/ledger';
import gnosisModule from '@web3-onboard/gnosis';
import Myos from './Myos';

const INFURA_ID = 'e90c3cf441f04521b898d8ee484ea30f';
const FORTMATIC_KEY = 'pk_live_45137B683B703F49';
const PORTIS_ID = '7ad11389-9bf1-429c-ad12-98c28743d2e7';

const injected = injectedModule();

const torus = torusModule();
const portis = portisModule({ apiKey: PORTIS_ID });
const fortmatic = fortmaticModule({ apiKey: FORTMATIC_KEY });

const walletConnect = walletConnectModule({
  qrcodeModalOptions: {
    mobileLinks: [
      'rainbow',
      'metamask',
      'argent',
      'trust',
      'imtoken',
      'pillar',
    ],
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
      id: '0x1', // chain ID must be in hexadecimal
      token: 'ETH', // main chain token
      label: 'Ethereum Mainnet',
      rpcUrl: `https://mainnet.infura.io/v3/${INFURA_ID}`, // rpcURL required for wallet balances
    },
    {
      id: '0x5',
      token: 'tGRL',
      label: 'Ethereum goerli Testnet',
      rpcUrl: `https://goerli.infura.io/v3/${INFURA_ID}`,
    },
    {
      id: '0x89',
      token: 'MATIC',
      label: 'Matic Mainnet',
      rpcUrl: 'https://matic-mainnet.chainstacklabs.com',
    },
    {
      id: '0x13881',
      token: 'MATIC',
      label: 'Matic Mumbai',
      rpcUrl: 'https://matic-mumbai.chainstacklabs.com',
    },
  ],
  appMetadata: {
    name: 'Myos',
    icon: '',
    logo: '',
    description: 'Make your own story',
    gettingStartedGuide: '',
    explore: '',
    recommendedInjectedWallets: [
      { name: 'MetaMask', url: 'https://metamask.io' },
      { name: 'Coinbase', url: 'https://wallet.coinbase.com/' },
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
    this.provider = new ethers.providers.Web3Provider(
      primaryWallet.provider,
      'any'
    );
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

  async middleWareConnected(
    provider:
      | ethers.providers.Web3Provider
      | ethers.providers.BaseProvider
      | unknown
  ) {
    try {
      if (!provider) await this.connectWeb3();
    } catch (error) {
      throw new Error('Connection impossible');
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
   * Get Id of current web3 network connected
   * @returns {number} Return current ChainId of network web3 connected
   * @category Connection
   */
  async getIdChainNow(): Promise<number> {
    const network = await this.provider.getNetwork();
    return network.chainId;
  }

  /**
   * Return if current network chain ID is accepted in kanji platform
   * @param {number} currentChainId Chain id of current network web3 connected
   * @returns {boolean} Return true if network is accepted, false if it isn't
   * @category Connection
   */
  async networkInChainAccepted(currentChainId: number): Promise<boolean> {
    if (currentChainId === 4) {
      return true;
    } else if (currentChainId === 8001) {
      return true;
    } else if (currentChainId === 1) {
      return true;
    } else if (currentChainId === 137) {
      return true;
    } else if (currentChainId === 80001) {
      return true;
    } else {
      return false;
    }
  }

  /**
   *
   * @param currentChainId
   * @returns
   */
  networkChainString(currentChainId: number): string {
    if (currentChainId === 5) {
      return 'ethereum-goerli';
    } else if (currentChainId === 1) {
      return 'ethereum-mainnet';
    } else if (currentChainId === 137) {
      return 'polygon-mainnet';
    } else if (currentChainId === 80001) {
      return 'polygon-mumbai';
    } else {
      return 'unknown';
    }
  }

  /**
   *
   * @returns
   */
  async networkAccepted() {
    return {
      'ethereum-goerli': 5,
      'ethereum-mainnet': 1,
      'polygon-mainnet': 137,
      'polygon-mumbai': 1337,
    };
  }

  /**
   *
   * @returns
   */
  /*async onChangeNetwork() {
    return this.provider.on('network', (newNetwork, oldNetwork) => {
      return { newNetwork, oldNetwork };
    });
  }*/

  /**
   *
   * @param chainId
   */
  async changeNetwork(chainId: string) {
    return await this.onboard.setChain({ chainId: chainId });
  }

  /**
   *
   * @returns
   */
  async currentChainIsAccepted() {
    return this.providerNode
      ? true
      : await this.networkInChainAccepted(await this.getIdChainNow());
  }
}

export default Connection;
