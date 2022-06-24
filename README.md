# puretea

Puretea (pronounced *purity*) is an EVM purity checker implemented in Solidity/Yul.

It is a configurable library for checking code only containing a specific set of allowed instructions.

It comes with a few caveats:
1) In contrast to the EVM, it rejects malformed `PUSH` instructions
(those which are incomplete and rely on the zero-extension of bytecode)
2) It does not perform `JUMPDEST`-analysis (see [this talk](https://www.youtube.com/watch?v=8Cp8IsmIJl4)
for an explainer), but relies on EVM execution for it.
3) It does not handle the [Solidity metadata](https://docs.soliditylang.org/en/latest/metadata.html#contract-metadata),
but (soon) contains a helper function for removing it.

## Usage



## License

MIT
