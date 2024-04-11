import { Controller } from "@hotwired/stimulus"
import { createConfig, configureChains, watchAccount, connect, disconnect, getWalletClient } from '@wagmi/core'
import { publicProvider } from '@wagmi/core/providers/public'
import { MetaMaskConnector } from '@wagmi/core/connectors/metaMask'
import { mainnet } from '@wagmi/core/chains'

export default class extends Controller {
  static targets = [
    "logInButton",
    "statusElement",
    "signOutButton",
    "signSection",
    "signMessageForm",
    "signMessageButton",
    "signatureStatusElement"
  ]

  connect() {
    this.chains = [mainnet];
    this.chainIdToConnect = mainnet.id
    this.crsfToken = document.querySelector('meta[name="csrf-token"]').content

    this.#setChains()
    this.#initializeMetamaskConnector()
    this.#setConfig()
    watchAccount(this.#updateAccountStatus.bind(this));
  }

  async logIn() {
    await connect({
      chainId: this.chainIdToConnect,
      connector: this.metaMaskConnector
    })
  }

  async signMessage(event) {
    event.preventDefault()
    const signer = await getWalletClient();

    if (signer) {
      this.signatureStatusElementTarget.textContent = 'Requesting signature...';
      this.signMessageButtonTarget.classList.add('hidden');
      try {
        const address = await this.config.connector?.getAccount();
        const nonce = await this.#getAddressNonceRequest(address)
        const signatureMessage = `Sign this message to sign in\n\nNonce=${nonce.value}`
        const signature = await signer.signMessage({
          account: address.toLowerCase(),
          message: signatureMessage,
        });
        this.signatureStatusElementTarget.textContent = `Signed in (signature: ${signature})`;
        this.signMessageButtonTarget.classList.remove('hidden');

        this.#createSessionRequest(address, signatureMessage, signature)
      } catch (e) {
        this.signatureStatusElementTarget.textContent = 'Not signed';
        this.signMessageButtonTarget.classList.remove('hidden');
      }
    }
  }

  async signOut() {
    await disconnect()
    this.#destroySessionRequest()
  }

  #setChains() {
    const { publicClient, webSocketPublicClient } = configureChains(
      this.chains,
      [publicProvider()]
    )

    this.publicClient = publicClient;
    this.webSocketPublicClient = webSocketPublicClient;
  }

  #initializeMetamaskConnector() {
    this.metaMaskConnector = new MetaMaskConnector({
      chains: this.chains
    });
  }

  #setConfig() {
    this.config = createConfig({
      connectors: [
        this.metaMaskConnector,
      ],
      autoConnect: true,
      publicClient: this.publicClient,
      webSocketPublicClient: this.webSocketPublicClient,
    })
  }

  #updateAccountStatus(account) {
    if (account.status == 'connected') {
      this.statusElementTarget.textContent = `Connected to ${account.address}`;
      this.logInButtonTarget.classList.add('hidden');
      this.signOutButtonTarget.classList.remove('hidden');
      this.signSectionTarget.classList.remove('hidden');
      this.signatureStatusElementTarget.textContent = '';
    } else if (account.status == 'connecting') {
      this.statusElementTarget.textContent = `Connecting...`;
      this.logInButtonTarget.classList.add('hidden');
      this.signOutButtonTarget.classList.add('hidden');
      this.signSectionTarget.classList.add('hidden');
      this.signatureStatusElementTarget.textContent = '';
    } else if (account.status == 'disconnected') {
      this.statusElementTarget.textContent = `Not connected`;
      this.logInButtonTarget.classList.remove('hidden');
      this.signOutButtonTarget.classList.add('hidden');
      this.signSectionTarget.classList.add('hidden');
      this.signatureStatusElementTarget.textContent = '';
    }
  }

  async #getAddressNonceRequest(address) {
    return await fetch(`/nonces/${address}`, {
      method: "GET",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": this.crsfToken,
      }
    })
      .then((response) => response.json())
      .then((data) => {
        return data
      });
  }


  #createSessionRequest(address, signatureMessage, signature) {
    fetch(this.signMessageFormTarget.action, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": this.crsfToken,
      },
      body: JSON.stringify(
        {
          session: {
            address: address,
            signature_message: signatureMessage,
            signature: signature
          }
        }
      ),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.status == 'ok') window.location = data.redirect_to_url
      });
  }

  #destroySessionRequest() {
    fetch(this.signMessageFormTarget.action, {
      method: "DELETE",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
        "X-CSRF-Token": this.crsfToken,
      }
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.status == 'ok') window.location = data.redirect_to_url
      });
  }
}
