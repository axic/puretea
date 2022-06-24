// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../src/SolidityMetadata.sol";

contract SolidityMetadataTest is Test {
    function testEmpty() public {
        assertEq(SolidityMetadata.trim(hex""), hex"");
    }

    function testShort() public {
        assertEq(SolidityMetadata.trim(hex"11"), hex"11");
        assertEq(SolidityMetadata.trim(hex"1122"), hex"1122");
        assertEq(SolidityMetadata.trim(hex"112233"), hex"112233");
    }

    function testSmoke() public {
        bytes memory code = hex"6080604052348015600f57600080fd5b50604580601d6000396000f3fe608060405236600a57005b600080fdfea2646970667358221220288b334155bacd5c3649e47cd3c9c34b4a66c8f84ff0372e4fbddccd1ed95d6b64736f6c634300080d0033";
        bytes memory trimmed = hex"6080604052348015600f57600080fd5b50604580601d6000396000f3fe608060405236600a57005b600080fdfe";
        assertEq(SolidityMetadata.trim(code), trimmed);
    }
}
