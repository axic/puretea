// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../src/Puretea.sol";

// Could use uint8[], but array literals can't be passed to dynamic arrays yet.
function generateMask(bytes memory allowedOpcodes) pure returns (uint256 mask) {
    for (uint256 i = 0; i < allowedOpcodes.length; i++) {
        mask |= 1 << uint8(allowedOpcodes[i]);
    }
}

contract PureteaTest is Test {
    function testSmoke() public {
        assertEq(Puretea.isPureStrict(hex""), true); // empty
        assertEq(Puretea.isPureStrict(hex"00"), true); // STOP
        assertEq(Puretea.isPureStrict(hex"6000"), true); // PUSH1 00
        assertEq(Puretea.isPureStrict(hex"60"), false); // truncated PUSH1
        assertEq(Puretea.isPureStrict(hex"fe"), true); // REVERT
        assertEq(Puretea.isPureStrict(hex"ff"), false); // SELFDESTRUCT
    }

    function testCustomMask() public {
        uint256 mask = generateMask(hex"00_20_fe");
        assertEq(mask, 0x4000000000000000000000000000000000000000000000000000000100000001);
        assertTrue(Puretea.check(hex"", mask));
        assertTrue(Puretea.check(hex"00", mask));
        assertTrue(Puretea.check(hex"20", mask));
        assertTrue(Puretea.check(hex"20fe0020fefe", mask));
        assertFalse(Puretea.check(hex"ff", mask));
    }
}
