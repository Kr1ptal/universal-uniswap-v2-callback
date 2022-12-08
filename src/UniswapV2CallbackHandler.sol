pragma solidity ^0.8.0;

import "./UniswapV2CallbackUtils.sol";

abstract contract UniswapV2CallbackHandler {
    fallback() external payable virtual {
        if (msg.data.length <= 4) {
            return;
        }

        (bool valid, uint256 amount0, uint256 amount1, bytes calldata data) = UniswapV2CallbackUtils
            .decodeUniswapV2Callback({dataWithSelector: msg.data});

        if (valid) {
            handleUniswapV2Callback(amount0, amount1, data);
        }
    }

    /// @notice Generalized callback handler.
    /// @dev If holding assets on inheriting contract, and this callback transfers tokens, implement callback
    /// validation logic to make sure msg.sender == legit pool.
    function handleUniswapV2Callback(uint256 amount0, uint256 amount1, bytes calldata data) internal virtual;
}
