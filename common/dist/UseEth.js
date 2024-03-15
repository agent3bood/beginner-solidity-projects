"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _react = _interopRequireWildcard(require("react"));
var _ethers = require("ethers");
function _getRequireWildcardCache(e) { if ("function" != typeof WeakMap) return null; var r = new WeakMap(), t = new WeakMap(); return (_getRequireWildcardCache = function (e) { return e ? t : r; })(e); }
function _interopRequireWildcard(e, r) { if (!r && e && e.__esModule) return e; if (null === e || "object" != typeof e && "function" != typeof e) return { default: e }; var t = _getRequireWildcardCache(r); if (t && t.has(e)) return t.get(e); var n = { __proto__: null }, a = Object.defineProperty && Object.getOwnPropertyDescriptor; for (var u in e) if ("default" !== u && Object.prototype.hasOwnProperty.call(e, u)) { var i = a ? Object.getOwnPropertyDescriptor(e, u) : null; i && (i.get || i.set) ? Object.defineProperty(n, u, i) : n[u] = e[u]; } return n.default = e, t && t.set(e, n), n; }
const useEthereum = () => {
  const [provider, setProvider] = (0, _react.useState)(null);
  const [signer, setSigner] = (0, _react.useState)(null);
  const [address, setAddress] = (0, _react.useState)(null);
  (0, _react.useEffect)(() => {
    if (window.ethereum) {
      try {
        const provider = new _ethers.ethers.providers.Web3Provider(window.ethereum);
        setProvider(provider);
        const signer = provider.getSigner();
        setSigner(signer);
        setAddress(signer.getAddress());
      } catch (e) {
        console.error(e);
      }
    }
  }, []);
  return {
    provider,
    setProvider,
    signer,
    setSigner,
    address,
    setAddress
  };
};
var _default = exports.default = useEthereum;