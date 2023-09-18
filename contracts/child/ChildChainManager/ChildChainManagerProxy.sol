pragma solidity 0.6.8;

import {UpgradableProxy} from "../../common/Proxy/UpgradableProxy.sol";


contract ChildChainManagerProxy is UpgradableProxy {
    constructor(address _proxyTo)
        public
        UpgradableProxy(_proxyTo)
    {}
}
