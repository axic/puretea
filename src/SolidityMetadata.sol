/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SolidityMetadata {
    /// Offset or CBOR kind is wrong.
    error InvalidMetadata();

    /// Use this function to trim Solidity metadata from the input. It will revert on invalid input.
    ///
    /// NOTE: this function will modify the input!
    function trim(bytes memory input) internal pure returns (bytes memory output) {
        uint256 len = input.length;

        // Does not have metadata.
        if (len <= 3) {
            return input;
        }

        uint256 metadata_size = (uint256(uint8(input[len - 2])) << 8) | uint256(uint8(input[len - 1]));
        if (metadata_size > (len - 2)) {
            revert InvalidMetadata();
        }

        uint256 code_size = len - metadata_size - 2;

        // Check that the metadata is a CBOR mapping
        bytes1 cbor_kind = input[code_size];
        if (cbor_kind < 0xa0 || cbor_kind > 0xb7) {
            revert InvalidMetadata();
        }

        // TODO: validate the data with more strictness

        assembly {
            mstore(input, code_size)
        }

        return input;
    }
}
