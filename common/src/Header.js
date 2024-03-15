import React from "react"

const Header = (props) => {
    const {signer, setSigner, provider, address, setAddress} = props.useEth;

    const connectWallet = async ({provider, setSigner}) => {
        if (window.ethereum) {
            try {
                const signer = await provider.getSigner();
                setSigner(signer);
            } catch (e) {
                alert("Could not connect");
            }
        } else {
            alert("Ethereum object not found, install MetaMask.");
        }
    }

    return <header className={"bg-sky-400 sticky top-0 p-2"}>
        {!signer && (
            <button
                className={
                    "bg-sky-600 hover:bg-sky-800  font-bold py-2 px-4 text-white rounded"
                }
                onClick={() => connectWallet({provider, setSigner})}
            >
                Connect
            </button>
        )}
        {signer && (
            <div className={"flex flex-row"}>
                <button
                    className={
                        "bg-rose-600 hover:bg-rose-800 font-bold py-2 px-4 text-white rounded"
                    }
                    onClick={() => disconnectWallet()}
                >
                    Disconnect
                </button>
                <div className={"grow"}></div>
                <p className={"bg-sky-600 font-bold text-white py-2 px-4 rounded"}>
                    {formatAddress(address)}
                </p>
            </div>
        )}
    </header>
}

function formatAddress(address) {
    if (!address || address.length < 7) {
        return address;
    }
    return (
        address.substring(0, 7) + "..." + address.substring(address.length - 5)
    );
}

function disconnectWallet() {
    alert("Use Your Wallet To Disconnect!");
}

export default Header;
