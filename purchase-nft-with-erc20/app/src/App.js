import { ethers } from "ethers";
import { useEffect, useState } from "react";
import TokenABI from "./abi/GLDToken.json";
import NFTABI from "./abi/GLDNFT.json";
import Gravatar from "react-gravatar";
import { Header, UseEthereum } from "common/index";

const tokenAddress = process.env.REACT_APP_TOKEN_ADDRESS;
const nftAddress = process.env.REACT_APP_NFT_ADDRESS;

function App() {
  const useEth = UseEthereum();
  const { provider, setProvider, signer, setSigner, address, setAddress } =
    useEth;
  // const [provider, setProvider] = useState(null);
  // const [signer, setSigner] = useState(null);
  // const [address, setAddress] = useState(null);
  const [balance, setBalance] = useState(0);
  const [contractToken, setContractToken] = useState();
  const [contractNFT, setContractNFT] = useState();

  useEffect(() => {
    if (window.ethereum) {
      try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        setProvider(provider);
      } catch (e) {
        console.error(e);
      }
    }
  }, []);

  useEffect(() => {
    if (!signer) {
      setContractToken(null);
      return;
    }
    try {
      const contractInstance = new ethers.Contract(
        tokenAddress,
        TokenABI,
        signer,
      );
      setContractToken(contractInstance);

      const nftInterface = new ethers.Contract(nftAddress, NFTABI, signer);
      setContractNFT(nftInterface);
    } catch (e) {
      console.error(e);
    }
  }, [signer]);

  useEffect(() => {
    if (!signer) {
      setAddress(null);
    } else {
      setAddress(signer.address);
    }
  }, [signer]);

  useEffect(() => {
    getConnectedSigner({ provider, setSigner });
  }, [provider]);

  useEffect(() => {
    if (!window.ethereum) {
      return;
    }
    window.ethereum.on("accountsChanged", (accounts) => {
      if (accounts.length === 0) {
        setSigner(null);
      }
    });
  });

  useEffect(() => {
    checkBalance();
  }, [address]);

  const checkBalance = async () => {
    if (!address || !contractToken) {
      setBalance(0);
      return;
    }
    try {
      const val = await contractToken.balanceOf(address);
      setBalance(val.toString());
    } catch (e) {
      console.error(e);
    }
  };

  const mint = async () => {
    if (!signer || !contractToken) {
      return;
    }
    try {
      const tx = await contractToken.mint();
      await tx.wait();
      await checkBalance();
    } catch (e) {
      console.error(e);
    }
  };

  if (!provider) return <div>You need to install Metamask!</div>;

  return (
    <div>
      <Header
        useEth={useEth}
        // signer={signer}
        // setSigner={setSigner}
        // provider={provider}
        // address={address}
        // setAddress={setAddress}
      />
      <div className={"h-12"}></div>
      <div className={"p-4"}>
        <div className={"p-2 max-w rounded overflow-hidden shadow"}>
          <p className={"text-xl font-bold mb-2"}>
            Balance:
            <span className={"pl-2 text-gray-700 text-base"}>{balance}</span>
          </p>
          <div className={"px-6 pt-4 pb-2"}>
            <button
              className={
                "bg-sky-600 hover:bg-sky-800 font-bold py-2 px-4 text-white rounded"
              }
              onClick={checkBalance}
            >
              Check Balance
            </button>
            <button
              className={
                "ml-2 bg-teal-600 hover:bg-teal-800 font-bold py-2 px-4 text-white rounded"
              }
              onClick={mint}
            >
              MINT
            </button>
          </div>
        </div>
      </div>
      <div className={"p-4"}>
        <div className={"p-2 flex flex-wrap"}>
          {
            <NFTs
              contractNFT={contractNFT}
              contractToken={contractToken}
              userAddress={address}
            />
          }
        </div>
      </div>
    </div>
  );
}

function NFTs(props) {
  const { contractNFT, userAddress, contractToken } = props;
  const tokens = [];
  for (let i = 0; i < 100; i++) {
    tokens.push(
      <NFT
        key={i}
        id={i}
        contractNFT={contractNFT}
        userAddress={userAddress}
        contractToken={contractToken}
      />,
    );
  }
  return <>{tokens}</>;
}

function NFT(props) {
  const { id, contractNFT, userAddress, contractToken } = props;
  const [owner, setOwner] = useState();
  useEffect(() => {
    if (!contractNFT) {
      return;
    }
    fetchOwner();
  }, [contractNFT]);

  const fetchOwner = async () => {
    try {
      const val = await contractNFT.ownerOf(id);
      setOwner(val.toString());
    } catch (e) {}
  };

  const buy = async () => {
    try {
      const tx1 = await contractToken.approve(nftAddress, 10);
      await tx1.wait();

      const tx2 = await contractNFT.mint(tokenAddress, id);
      await tx2.wait();

      await fetchOwner();
    } catch (e) {
      console.error(e);
    }
  };

  const owned = owner === userAddress;

  return (
    <div className="m-2 p-2 max-w rounded overflow-hidden shadow-lg">
      <div className="flex justify-center">
        <Gravatar email={`${props.id}@gld.nft`} />
      </div>
      <div className="px-6 pt-4 pb-2">
        {!owner && (
          <button
            className="bg-sky-600 hover:bg-sky-800 font-bold py-2 px-4 text-white rounded"
            onClick={buy}
          >
            Buy
          </button>
        )}
        {!owner && (
          <span className="ml-1 inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2 mb-2">
            {`${id} GLDToken`}
          </span>
        )}
        {owned && (
          <span className="inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2 mb-2">
            OWNED
          </span>
        )}
        {owner && owner !== userAddress && (
          <span className="inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2 mb-2">
            {formatAddress(owner)}
          </span>
        )}
      </div>
    </div>
  );
}

function formatAddress(address) {
  if (!address || address.length < 7) {
    return address;
  }
  return (
    address.substring(0, 7) + "..." + address.substring(address.length - 5)
  );
}

async function getConnectedSigner({ provider, setSigner }) {
  if (!provider) {
    setSigner(null);
    return;
  }
  try {
    const accounts = await provider.listAccounts();
    if (accounts.length) {
      const signer = await accounts[0].provider.getSigner();
      if (signer) {
        setSigner(signer);
      }
    }
  } catch (e) {
    console.error(e);
  }
}

export default App;
