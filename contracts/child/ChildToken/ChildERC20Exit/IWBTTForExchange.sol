pragma solidity 0.6.8;

import {IChildToken} from "./IChildToken.sol";

interface IWBTTForExchange is IChildToken {
    function swapIn() payable external;

    function swapOut(uint256 amount) external;

}
