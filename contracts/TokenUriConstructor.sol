// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import 'base64-sol/base64.sol';
import './common/DateTime.sol';
import './interfaces/ITokenUriConstructor.sol';

contract TokenUriConstructor is DateTime, ITokenUriConstructor {

    function _uint2str(uint256 _i) private pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }

        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }

    function generateSVGImage(string memory amount, uint256 unlockTime) internal pure returns (string memory) {
        _DateTime memory dt = parseTimestamp(unlockTime);
        
        return string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1068.44 1566.12">',
            '<defs>',
                '<style>.cls-1{fill:#838bc5;}.cls-1,.cls-2{stroke:#000;stroke-miterlimit:10;}.cls-2{fill:#6d8bc5;}.cls-3{font-size:80px;fill:#ccc;}.cls-3,.cls-5,.cls-6{font-family:MyriadPro-Regular, Myriad Pro;}.cls-4{letter-spacing:0em;}.cls-5{font-size:128px;}.cls-5,.cls-6{fill:#fff;}.cls-6{font-size:60px;}</style>',
            '</defs>',
            '<title>IceStone.Cash</title><g id="s1"><rect class="cls-1" x="0.5" y="0.5" width="1067.44" height="1565.12"/></g><g id="s2"><rect class="cls-2" x="28.73" y="75.35" width="1013.95" height="1467.01"/></g><g id="s3"><text class="cls-3" transform="translate(177.22 819.1)">Unlock <tspan class="cls-4" x="249.28" y="0">a</tspan><tspan x="287.52" y="0">t ',
            _uint2str(dt.day), '.', _uint2str(dt.month), '.', _uint2str(dt.year),
            '</tspan></text><text class="cls-5" transform="translate(46.44 686.55)">',
            amount,
            '</text><text class="cls-6" transform="translate(348.3 53.99)">IceStone.Cash</text></g></svg>'
        ));
    }

    function construct(uint256 amount, string memory symbol, uint256 unlockTime) public pure returns (string memory) {
        string memory amountWithSymbol = string(abi.encodePacked(_uint2str(amount), " ", symbol));
        string memory image = Base64.encode(bytes(generateSVGImage(amountWithSymbol, unlockTime)));

        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            "Stone ", symbol,
                            '", "description":"',
                            '", "image": "',
                            'data:image/svg+xml;base64,',
                            image,
                            '"}'
                        )
                    )
                )
            )
        );
    }
}