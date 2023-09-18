pragma solidity 0.6.8;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IChildChainManager} from "./IChildChainManager.sol";
import {IChildToken} from "../ChildToken/IChildToken.sol";
import {Initializable} from "../../common/Initializable.sol";
import {AccessControlMixin} from "../../common/AccessControlMixin.sol";
import {IStateReceiver} from "../IStateReceiver.sol";


contract ChildChainManager is
    IChildChainManager,
    Initializable,
    AccessControlMixin,
    IStateReceiver
{
    bytes32 public constant DEPOSIT = keccak256("DEPOSIT");
    bytes32 public constant MAP_TOKEN = keccak256("MAP_TOKEN");
    bytes32 public constant MAPPER_ROLE = keccak256("MAPPER_ROLE");
    bytes32 public constant STATE_SYNCER_ROLE = keccak256("STATE_SYNCER_ROLE");

    mapping(uint256 => address) public rootToChildToken;
    mapping(address => address) public childToRootToken;

    function initialize(address _owner) external initializer {
        _setupContractId("ChildChainManager");
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(MAPPER_ROLE, _owner);
        _setupRole(STATE_SYNCER_ROLE, _owner);
    }

    function getRootToChildToken(uint64 chainId, address rootToken)
        external
        view
        returns (address childToken)
    {
        childToken = rootToChildToken[uint256(rootToken) | (uint256(chainId)<<160)];
    }

    /**
     * @notice Map a token to enable its movement via the PoS Portal, callable only by mappers
     * Normally mapping should happen automatically using state sync
     * This function should be used only while initial deployment when state sync is not registrered or if it fails
     * @param rootToken address of token on root chain
     * @param childToken address of token on child chain
     */
    function mapToken(uint64 chainId, address rootToken, address childToken)
        external
        override
        only(MAPPER_ROLE)
    {
        _mapToken(chainId, rootToken, childToken);
    }

    /**
     * @notice Receive state sync data from root chain, only callable by state syncer
     * @dev state syncing mechanism is used for both depositing tokens and mapping them
     * @param data bytes data from RootChainManager contract
     * `data` is made up of bytes32 `syncType` and bytes `syncData`
     * `syncType` determines if it is deposit or token mapping
     * in case of token mapping, `syncData` is encoded address `rootToken`, address `childToken` and bytes32 `tokenType`
     * in case of deposit, `syncData` is encoded address `user`, address `rootToken` and bytes `depositData`
     * `depositData` is token specific data (amount in case of ERC20). It is passed as is to child token
     */
    function onStateReceive(uint256, bytes calldata data)
        external
        override
        only(STATE_SYNCER_ROLE)
    {
        (bytes32 syncType, bytes memory syncData) = abi.decode(
            data,
            (bytes32, bytes)
        );

        if (syncType == DEPOSIT) {
            _syncDeposit(syncData);
        } else if (syncType == MAP_TOKEN) {
            (address rootToken, address childToken, uint64 chainId, ) = abi.decode(
                syncData,
                (address, address, uint64, bytes32)
            );
            _mapToken(chainId, rootToken, childToken);
        } else {
            revert("ChildChainManager: INVALID_SYNC_TYPE");
        }
    }

    /**
     * @notice Clean polluted token mapping
     * @param rootToken address of token on root chain. Since rename token was introduced later stage,
     * clean method is used to clean pollulated mapping
     */
    function cleanMapToken(
        uint64 chainId,
        address rootToken,
        address childToken
    ) external override only(MAPPER_ROLE) {
        uint256 rootKey = uint256(rootToken) | (uint256(chainId)<<160);
        rootToChildToken[rootKey] = address(0);
        childToRootToken[childToken] = address(0);

        emit TokenMapped(chainId, rootToken, childToken);
    }

    function _mapToken(uint64 chainId, address rootToken, address childToken) private {
        uint256 rootKey = uint256(rootToken) | (uint256(chainId)<<160);
        address oldChildToken = rootToChildToken[rootKey];
        address oldRootToken = childToRootToken[childToken];

        uint256 oldRootKey = uint256(oldRootToken) | (uint256(chainId)<<160);

        if (rootToChildToken[oldRootKey] != address(0)) {
            rootToChildToken[oldRootKey] = address(0);
        }
        if (childToRootToken[oldChildToken] != address(0)) {
            childToRootToken[oldChildToken] = address(0);
        }

        rootToChildToken[rootKey] = childToken;
        childToRootToken[childToken] = rootToken;

        emit TokenMapped(chainId, rootToken, childToken);
    }

    function _syncDeposit(bytes memory syncData) private {
        (address user, address rootToken, uint64 chainId, bytes memory depositData) = abi
            .decode(syncData, (address, address, uint64, bytes));
        uint256 rootKey = uint256(rootToken) | (uint256(chainId)<<160);
        address childTokenAddress = rootToChildToken[rootKey];
        require(
            childTokenAddress != address(0x0),
            "ChildChainManager: TOKEN_NOT_MAPPED"
        );
        IChildToken childTokenContract = IChildToken(childTokenAddress);
        childTokenContract.deposit(user, depositData);
    }
}
