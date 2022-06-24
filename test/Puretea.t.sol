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
        assertEq(Puretea.isPureGlobal(hex""), true); // empty
        assertEq(Puretea.isPureGlobal(hex"00"), true); // STOP
        assertEq(Puretea.isPureGlobal(hex"6000"), true); // PUSH1 00
        assertEq(Puretea.isPureGlobal(hex"60"), false); // truncated PUSH1
        assertEq(Puretea.isPureGlobal(hex"fe"), true); // REVERT
        assertEq(Puretea.isPureGlobal(hex"ff"), false); // SELFDESTRUCT
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

    function testMutating() public {
        uint256 mask = generateMask(hex"000102030405060708090a0b_101112131415161718191a1b1c1d_20_303132333435363738393a3b3c3d3e3f_404142434445464748_505152535455565758595a5b_606162636465666768696a6b6c6d6e6f_707172737475767778797a7b7c7d7e7f_808182838485868788898a8b8c8d8e8f_909192939495969798999a9b9c9d9e9f_a0a1a2a3a4_f0f1f2f3f4f5fafdfeff");
        assertEq(mask, 0xe43f0000000000000000001fffffffffffffffff0fff01ffffff00013fff0fff);
        assertTrue(Puretea.isMutating(hex""));
        assertTrue(Puretea.isMutating(hex"611234f0"));
        assertFalse(Puretea.isMutating(hex"21"));
    }

    function testView() public {
        uint256 mask = generateMask(hex"000102030405060708090a0b_101112131415161718191a1b1c1d_20_303132333435363738393a3b3c3d3e3f_404142434445464748_5051525354565758595a5b_606162636465666768696a6b6c6d6e6f_707172737475767778797a7b7c7d7e7f_808182838485868788898a8b8c8d8e8f_909192939495969798999a9b9c9d9e9f_f3fafdfe");
        assertEq(mask, 0x640800000000000000000000ffffffffffffffff0fdf01ffffff00013fff0fff);
        assertTrue(Puretea.isView(hex""));
        assertTrue(Puretea.isView(hex"611234fe"));
        assertFalse(Puretea.isView(hex"f0"));
    }

    function testPureGlobal() public {
        uint256 mask = generateMask(hex"000102030405060708090a0b_101112131415161718191a1b1c1d_20_303132333435363738393a3d3e_404142434445464748_5051525354565758595a5b_606162636465666768696a6b6c6d6e6f_707172737475767778797a7b7c7d7e7f_808182838485868788898a8b8c8d8e8f_909192939495969798999a9b9c9d9e9f_f3fdfe");
        assertEq(mask, 0x600800000000000000000000ffffffffffffffff0fdf01ff67ff00013fff0fff);
        assertTrue(Puretea.isPureGlobal(hex""));
        assertTrue(Puretea.isPureGlobal(hex"61123400"));
        assertFalse(Puretea.isPureGlobal(hex"fa"));
    }

    function testPureLocal() public {
        uint256 mask = generateMask(hex"000102030405060708090a0b_101112131415161718191a1b1c1d_20_303132333435363738393a3b3c3d3e3f_404142434445464748_50515253565758595a5b_606162636465666768696a6b6c6d6e6f_707172737475767778797a7b7c7d7e7f_808182838485868788898a8b8c8d8e8f_909192939495969798999a9b9c9d9e9f_f3fdfe");
        assertEq(mask, 0x600800000000000000000000ffffffffffffffff0fcf01ffffff00013fff0fff);
        assertTrue(Puretea.isPureLocal(hex""));
        assertTrue(Puretea.isPureLocal(hex"61123400"));
        assertFalse(Puretea.isPureLocal(hex"fa"));
    }
}
