# puretea

Puretea (pronounced *purity*) is an EVM purity checker implemented in Solidity/Yul.

It is a configurable library for checking code only containing a specific set of allowed instructions.

**Warning:** This is experimental software.

It comes with a few caveats:
1) In contrast to the EVM, it rejects malformed `PUSH` instructions
(those which are incomplete and rely on the zero-extension of bytecode)
2) It does not perform `JUMPDEST`-analysis (see [this talk](https://www.youtube.com/watch?v=8Cp8IsmIJl4)
for an explainer), but relies on EVM execution for it.
3) It does not handle the [Solidity metadata](https://docs.soliditylang.org/en/latest/metadata.html#contract-metadata),
but (soon) contains a helper function for removing it.

## Usage

The library provides high level helpers:
```solidity
    /// Check if the submitted EVM code is well formed. Allows state modification.
    function isMutating(bytes memory code) internal pure returns (bool);

    /// Check if the submitted EVM code is well formed. Allows state reading.
    function isView(bytes memory code) internal pure returns (bool);

    /// Check if the submitted EVM code is well formed. Disallows state access beyond the current contract.
    function isPureGlobal(bytes memory code) internal pure returns (bool);

    /// Check if the submitted EVM code is well formed. Disallows any state access.
    function isPureLocal(bytes memory code) internal pure returns (bool);
```

And also a low-level helper:
```solidity
    /// Check if submitted EVM code is well formed, and only contains opcodes permitted
    /// by the mask. The mask is a bitmask where the lowest bit corresponds to opcode 0x00.
    function check(bytes memory code, uint256 mask) private pure returns (bool satisfied);
```

Additionally in the test suite the [`generateMask`](./test/Puretea.t.sol) helper can be used to create custom masks.

## Background

The need for purity checkers is not something new. There have been two bigger efforts on the topic.

### EIP-1011

First for [EIP-1011](https://eips.ethereum.org/EIPS/eip-1011) implementations in [Serpent](https://github.com/ethereum/research/blob/master/impurity/check_for_impurity.se)
and [LLL](https://github.com/ethereum/casper/pull/143/files) were written, as well as a similar
[Solidity](https://gist.github.com/chriseth/9c3c4cbf6d3debddc6b14a8863d92719) version existed at the time. Their aim was to restrict code which modifies the state.

Since these were created before the [Byzantium](https://eips.ethereum.org/EIPS/eip-609) release, the
[`STATICCALL`](https://eips.ethereum.org/EIPS/eip-214) instruction was not supported yet, and compilers
relied on `CALL` to reach precompiled contracts. Therefore the checkers had a few special cases:
- Allow calls to precompiles (addresses 0 to 256)
- Allow calls to self (Serpent (and early Vyper as well) did not support `JUMP`s and performed in-contract control flow via `CALL`s)
- Allow calls to approved addresses

There is a lenghty write up about this by [Sigma Prime](https://blog.sigmaprime.io/evm-purity.html).

### OVM

The second example was Optimism's OVM 1.0, which had a [`SafetyChecker`](https://github.com/ethereum-optimism/contracts/blob/606577457191973b46034602f46ddcc130a5c0ac/contracts/optimistic-ethereum/OVM/execution/OVM_SafetyChecker.sol).

The rule set of this is slightly more complicated:
- Disallow `REVERT`
- Detect unreachable code
- Disallow state access opcodes
- Certain patterns to the caller are allowed (state access is proxied through the caller)

A lengthy write up was published by [Consensys Diligence](https://consensys.net/diligence/audits/2021/03/optimism-safetychecker/) about it.

### EOF

None of the above checkers are able to fully deal with arbitrary data (such as [Solidity metadata](https://docs.soliditylang.org/en/latest/metadata.html#contract-metadata)), nor perform complete `JUMPDEST`-analysis. Though the latter is possible and may not be too memory heavy on the average case.

The EVM Object Format described in [EIP-3540](https://eips.ethereum.org/EIPS/eip-3540) gives a structure and makes safety/purity checking easier, by separating data. [EIP-3670](https://eips.ethereum.org/EIPS/eip-3670) introduces some rules to remove certain "edge cases" from EVM code. While EOF is not supported in Puretea yet, it does follow EIP-3670's recommendation.

## License

MIT
