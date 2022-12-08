pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../UniswapV2CallbackHandler.sol";

contract UniswapV2CallbackHandlerTest is Test {
    OriginalCallbackHandler private original;
    UniversalCallbackHandler private universal;
    uint256 amount0 = 123546763524712457;
    uint256 amount1 = 98747456145;
    bytes private callbackData = abi.encode(214536124, vm.addr(0x12412));
    bytes input =
        abi.encodeWithSignature(
            "uniswapV2Call(address,uint256,uint256,bytes)",
            address(this),
            amount0,
            amount1,
            callbackData
        );

    function setUp() public {
        original = new OriginalCallbackHandler();
        universal = new UniversalCallbackHandler();
    }

    function testOriginal() public {
        address(original).call(input);

        assertEq(original.amount0Decoded(), amount0);
        assertEq(original.amount1Decoded(), amount1);
        assertEq(original.dataDecoded(), callbackData);
    }

    function testUniversal() public {
        address(universal).call(input);

        assertEq(universal.amount0Decoded(), amount0);
        assertEq(universal.amount1Decoded(), amount1);
        assertEq(universal.dataDecoded(), callbackData);
    }

    function testUniversalMalformedInput() public {
        bytes memory input = hex"12aa3caf0000000000000000000000003b17056cc4439c61cea41fe1c9f517af75a978f7000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48000000000000000000000000514910771af9ca656af840dff83e8264ecf986ca0000000000000000000000003b17056cc4439c61cea41fe1c9f517af75a978f7000000000000000000000000";
        address(universal).call(input);

        assertEq(universal.amount0Decoded(), 0);
        assertEq(universal.amount1Decoded(), 0);
        assertEq(universal.dataDecoded(), new bytes(0));
    }

    function testUniversalRandomData(uint256 amount0, uint256 amount1, bytes calldata flashData) public {
        address(universal).call(
            abi.encodeWithSignature(
                "uniswapV2Call(address,uint256,uint256,bytes)",
                address(this),
                amount0,
                amount1,
                flashData
            )
        );

        assertEq(universal.amount0Decoded(), amount0);
        assertEq(universal.amount1Decoded(), amount1);
        assertEq(universal.dataDecoded(), flashData);
    }
}

contract UniversalCallbackHandler is UniswapV2CallbackHandler {
    uint256 public amount0Decoded = 0;
    uint256 public amount1Decoded = 0;
    bytes public dataDecoded = new bytes(0);

    function handleUniswapV2Callback(uint256 amount0, uint256 amount1, bytes calldata data) internal override {
        amount0Decoded = amount0;
        amount1Decoded = amount1;
        dataDecoded = data;
    }
}

contract OriginalCallbackHandler {
    uint256 public amount0Decoded = 0;
    uint256 public amount1Decoded = 0;
    bytes public dataDecoded = new bytes(0);

    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external payable {
        amount0Decoded = amount0;
        amount1Decoded = amount1;
        dataDecoded = data;
    }
}
