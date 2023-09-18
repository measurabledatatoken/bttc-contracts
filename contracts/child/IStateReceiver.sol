pragma solidity 0.6.8;

interface IStateReceiver {
    function onStateReceive(uint256 id, bytes calldata data) external;
}
