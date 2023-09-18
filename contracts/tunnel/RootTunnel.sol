pragma solidity 0.6.8;

import {BaseRootTunnel} from "./BaseRootTunnel.sol";


contract RootTunnel is BaseRootTunnel {
    function _processMessageFromChild(bytes memory message) internal override {
      // implement your core logic here
    }
}
