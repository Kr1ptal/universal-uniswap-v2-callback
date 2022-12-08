# Universal Uniswap V2 Callback

Universal handler for any Uniswap-V2-like callback.

Every fork of Uniswap V2 protocol usually implements their own callback function,
which generally follows the same format. Since there are hundreds of forks deployed
across different chains, it becomes unfeasible to manually track and implement
callback function for each of them. Besides, doing so would increase deployed contract
size for each new supported fork.

`UniswapV2CallbackHandler` solves this problem by using a `fallback` function, and
manually decoding `msg.data`. Decoded result is validated to make sure it conforms
to the expected callback structure.

Using the universal callback with validation is more expensive by `1 gas`.

## Install
```bash
forge install kr1ptal/universal-uniswap-v2-callback
```

## Usage

```solidity
import "universal-uniswap-v2-callback/UniswapV2CallbackHandler.sol";

contract UniversalCallbackHandler is UniswapV2CallbackHandler {
    function handleUniswapV2Callback(uint256 amount0, uint256 amount1, bytes calldata data) internal override {
        // callback code
    }
}
```