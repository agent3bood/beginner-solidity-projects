import {Header, UseEthereum} from "common/index";
import React, {useState} from "react";

function App() {
    const useEth = UseEthereum();

    return (
        <div>
            <Header useEth={useEth}/>

        </div>
    );
}

export default App;
