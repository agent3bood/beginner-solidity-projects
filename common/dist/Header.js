"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _react = _interopRequireDefault(require("react"));
function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
const Header = props => {
  const {
    signer,
    setSigner,
    provider,
    address,
    setAddress
  } = props.useEth;
  const connectWallet = async _ref => {
    let {
      provider,
      setSigner
    } = _ref;
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
  };
  return /*#__PURE__*/_react.default.createElement("header", {
    className: "bg-sky-400 sticky top-0 p-2"
  }, !signer && /*#__PURE__*/_react.default.createElement("button", {
    className: "bg-sky-600 hover:bg-sky-800  font-bold py-2 px-4 text-white rounded",
    onClick: () => connectWallet({
      provider,
      setSigner
    })
  }, "Connect"), signer && /*#__PURE__*/_react.default.createElement("div", {
    className: "flex flex-row"
  }, /*#__PURE__*/_react.default.createElement("button", {
    className: "bg-rose-600 hover:bg-rose-800 font-bold py-2 px-4 text-white rounded",
    onClick: () => disconnectWallet()
  }, "Disconnect"), /*#__PURE__*/_react.default.createElement("div", {
    className: "grow"
  }), /*#__PURE__*/_react.default.createElement("p", {
    className: "bg-sky-600 font-bold text-white py-2 px-4 rounded"
  }, formatAddress(address))));
};
function formatAddress(address) {
  if (!address || address.length < 7) {
    return address;
  }
  return address.substring(0, 7) + "..." + address.substring(address.length - 5);
}
function disconnectWallet() {
  alert("Use Your Wallet To Disconnect!");
}
var _default = exports.default = Header;