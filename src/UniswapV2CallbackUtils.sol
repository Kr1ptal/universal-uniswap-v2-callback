pragma solidity ^0.8.0;

library UniswapV2CallbackUtils {
    /// @notice Try to decode provided "dataWithSelector" as Uniswap V2 callback.
    /// @return Flag indicating whether decoding succeeded, followed by decoded amount0, amount1, and data.
    function decodeUniswapV2Callback(
        bytes calldata dataWithSelector
    ) internal returns (bool, uint256, uint256, bytes calldata) {
        uint256 sender;
        assembly {
            sender := calldataload(add(dataWithSelector.offset, 4))
        }

        // address must not have more than 160 bits
        if (sender >> 160 != 0) {
            return (false, 0, 0, emptyBytesCalldata());
        }

        // amounts can occupy whole words
        uint256 amount0;
        uint256 amount1;
        bytes calldata data;
        assembly {
            amount0 := calldataload(add(dataWithSelector.offset, 36))
            amount1 := calldataload(add(dataWithSelector.offset, 68))

            // get offset of bytes length: selector + (sender | amount0 | amount1 | data length offset | data length | data).
            // "length offset" is relative to start of first parameter in data.
            let dataLenOffset := add(add(dataWithSelector.offset, 4), calldataload(add(dataWithSelector.offset, 100)))
            data.length := calldataload(dataLenOffset)
            data.offset := add(dataLenOffset, 32)
        }

        // validate that what we got matches what we expect
        unchecked {
            // account for padding in 32-byte word unaligned data
            uint256 paddedDataLen = data.length;
            uint256 remainder = data.length % 32;
            if (remainder > 0) {
                paddedDataLen = paddedDataLen + (32 - remainder);
            }

            // 164 = 4 (selector) + 96 ("sender", "amount0", "amount1" offsets) + 64 ("length offset" + "length" offsets)
            if (dataWithSelector.length != (paddedDataLen + 164)) {
                return (false, 0, 0, emptyBytesCalldata());
            }
        }

        return (true, amount0, amount1, data);
    }

    function emptyBytesCalldata() private pure returns (bytes calldata) {
        bytes calldata empty;
        assembly {
            empty.length := 0
            empty.offset := 0
        }
        return empty;
    }
}
