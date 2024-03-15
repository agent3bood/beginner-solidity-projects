import React, {useState, useEffect} from "react";
import {ethers} from "ethers"

const useEthereum = () => {
    const [provider, setProvider] = useState(null);
    const [signer, setSigner] = useState(null);
    const [address, setAddress] = useState(null);

    useEffect(() => {
        if (window.ethereum) {
            try {
                const provider = new ethers.providers.Web3Provider(window.ethereum);
                setProvider(provider);
                const signer = provider.getSigner();
                setSigner(signer);
                setAddress(signer.getAddress());
            } catch (e) {
                console.error(e);
            }
        }
    }, []);

    return {provider, setProvider, signer, setSigner, address, setAddress};
}

export default useEthereum;
