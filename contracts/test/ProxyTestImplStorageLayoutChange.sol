pragma solidity 0.6.8;

import {Initializable} from "../common/Initializable.sol";

contract ProxyTestImplStorageLayoutChange is Initializable {
    uint256 public b;
    uint256 public a;
}
