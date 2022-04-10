// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import 'base64-sol/base64.sol';
import './common/DateTime.sol';
import './interfaces/ITokenUriConstructor.sol';

contract TokenUriConstructor is DateTime {    

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function generateAddtionalInfo(uint256 daysCount, uint256 reward) internal pure returns (string memory ret) {
        string memory unlockAfterString = daysCount > 0 ? string(abi.encodePacked("Unlock after ", toString(daysCount), " days")) : "Can be unlock now";

        ret = string(abi.encodePacked(
            '<text class="cls-6" transform="translate(31 144.32)">', unlockAfterString,
            '</text></g><g class="cls-4"><text class="cls-7" transform="translate(31 155.91)">+', toString(reward) ,' IST when unlocked</text></g>'
        ));
    }

    function generateMark(uint8 mark) internal pure returns (string memory ret) {
        ret = mark == 1 ? '<text class="cls-11" transform="translate(69 181)">This is verified token address</text>' :
                mark == 2 ? '<text class="cls-9" transform="translate(46 181)">This is token address marked as a scam!</text>':
                '<text class="cls-10" transform="translate(80 180)">Any token can be placed in stone</text>';
    }

    function generateAmount(uint256 amount, uint256 decimals) internal pure returns (string memory ret) {
        if(amount == 0) {
            return "0";
        }

        uint256 units = amount / 10 ** decimals;
        if(units > 0) {
            string memory ks = "";
            uint unitToView = 0;
            if(units >= 1000000000000) {
                ks = "KKKK";
                unitToView = units / 1000000000000;
            } else if (units >= 1000000000) {
                ks = "KKK";
                unitToView = units / 1000000000;
            }
            else if (units >= 1000000) {
                ks = "KK";
                unitToView = units / 1000000;
            } else if (units >= 1000) {
                ks = "K";
                unitToView = units / 1000;
            } else {
                unitToView = units;
            }
            ret = string(abi.encodePacked(
                toString(unitToView), ks
            ));
        } else {
            uint256 temp = amount;
            uint256 digits;
            while (temp != 0) {
                digits++;
                temp /= 10;
            }
            bytes memory buffer = new bytes(digits);
            while (amount != 0) {
                digits -= 1;
                buffer[digits] = bytes1(uint8(48 + uint256(amount % 10)));
                amount /= 10;
            }

            uint decsToAdd = decimals - buffer.length;
            bytes memory decsBuff = new bytes(decsToAdd);
            for (uint256 i = 0; i < decsBuff.length; i++) {
                decsBuff[i] = "0";
            }
            
            uint256 firstChar = decsBuff.length;
            
            if(firstChar >= 4) {    
                ret = string("&lt;0.0001");
            } else {
                uint256 lastChar;
                for (uint256 i = 0; i < buffer.length; i++) {
                    if(buffer[i] != "0") {
                        lastChar = i;
                    }
                }

                bytes memory shortBuffer = new bytes(lastChar+1);
                for (uint256 i = 0; i < shortBuffer.length; i++) {
                    shortBuffer[i] = buffer[i];
                }

                ret = string(abi.encodePacked(
                    "0.",
                    string(decsBuff),
                    string(shortBuffer)
                ));
            }
        }
    }

    function generateSVGImage(
        string memory amount, 
        uint256 daysCount, 
        address contractAddress, 
        uint256 reward, 
        uint8 mark
    ) internal pure returns (string memory ret) {
        
        ret = string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 278 214"><defs><style>.cls-1{fill:#090b18;}.cls-2{fill:none;stroke:#5f5f5f;}.cls-13,.cls-3,.cls-5,.cls-6,.cls-7{fill:#01ffff;}.cls-10,.cls-11,.cls-13,.cls-14,.cls-4,.cls-5,.cls-6,.cls-7,.cls-9{isolation:isolate;}.cls-5{font-size:32px;}.cls-10,.cls-11,.cls-14,.cls-5,.cls-6,.cls-7,.cls-9{font-family:CourierNewPSMT, Courier New;}.cls-6{font-size:16px;}.cls-11,.cls-14,.cls-7,.cls-9{font-size:8px;}.cls-8{fill:#fff;fill-opacity:0.2;}.cls-9{fill:#ff0101;}.cls-10{font-size:6px;fill:#e1e1e1;}.cls-11,.cls-12{fill:#01ff39;}.cls-13{opacity:0.8;}.cls-14{fill:#565656;}</style></defs><title>!</title><rect class="cls-1" width="278" height="214" rx="30"/><rect class="cls-2" x="6.5" y="6.5" width="263" height="200" rx="29.5"/><path class="cls-3" d="M138.11,46.75a4.57,4.57,0,0,1-4.22-.3l-11.11-6.78c-1.26-.78-1.43-1.92-.36-2.53l13.11-7.53a4.65,4.65,0,0,1,4.25.29l11.07,6.79c1.27.77,1.44,1.9.37,2.51Z"/><path class="cls-3" d="M153.84,42.91V54.54A4.41,4.41,0,0,1,152,58l-12.37,7.11c-1,.58-1.82,0-1.82-1.37V52.13a4.28,4.28,0,0,1,1.82-3.46L152,41.55C153,41,153.84,41.57,153.84,42.91Z"/><path class="cls-3" d="M160.19,31l-19.82-11.4a6.38,6.38,0,0,0-6.3,0L114.26,31a6.28,6.28,0,0,0-3.15,5.45V59.2a6.28,6.28,0,0,0,3.15,5.45L134.06,76a6.28,6.28,0,0,0,6.3,0l19.82-11.38a6.29,6.29,0,0,0,3.14-5.45V36.43A6.29,6.29,0,0,0,160.19,31Zm-3.73,23.89a6.9,6.9,0,0,1-3.49,6L140.7,67.94a6.93,6.93,0,0,1-7,0l-12.27-7.06a6.93,6.93,0,0,1-3.49-6V40.75a7,7,0,0,1,3.49-6l12.27-7.06a6.93,6.93,0,0,1,7,0L153,34.74a6.9,6.9,0,0,1,3.49,6V54.87Z"/><g class="cls-4"><text class="cls-5" transform="translate(16 124.14)">',
            amount,
            '</text></g><g class="cls-4">',
            generateAddtionalInfo(daysCount, reward),
            '<rect class="cls-8" x="34" y="168" width="211" height="21" rx="10"/><g class="cls-4">',
            generateMark(mark),
            '</g><path class="cls-12" d="M24.9,137.81H20.26V134.9a1.74,1.74,0,1,1,3.48,0v1.4a.69.69,0,0,0,.58.73.66.66,0,0,0,.58-.73v-1.4a2.9,2.9,0,1,0-5.8,0v2.91A1.14,1.14,0,0,0,17.94,139v3.87A1.14,1.14,0,0,0,19.1,144h5.8a1.14,1.14,0,0,0,1.16-1.16V139A1.16,1.16,0,0,0,24.9,137.81Zm-2.71,3.06v1a.19.19,0,1,1-.38,0v-1a.58.58,0,1,1,.77-.55A.55.55,0,0,1,22.19,140.87Z"/><path class="cls-3" d="M22.71,152.3a.79.79,0,0,1-.74-.05L20,151.07c-.22-.14-.25-.33-.06-.44l2.29-1.32a.82.82,0,0,1,.74.06l1.94,1.18c.22.13.25.33.07.44Z"/><path class="cls-3" d="M25.46,151.63v2a.78.78,0,0,1-.31.61L23,155.51c-.18.1-.32,0-.32-.24v-2a.74.74,0,0,1,.32-.6l2.17-1.24C25.32,151.29,25.46,151.4,25.46,151.63Z"/><path class="cls-3" d="M26.57,149.55l-3.46-2a1.15,1.15,0,0,0-1.11,0l-3.46,2a1.1,1.1,0,0,0-.55.95v4a1.1,1.1,0,0,0,.55,1l3.46,2a1.1,1.1,0,0,0,1.11,0l3.46-2a1.1,1.1,0,0,0,.55-1v-4A1.1,1.1,0,0,0,26.57,149.55Zm-.65,4.17a1.21,1.21,0,0,1-.61,1.05L23.16,156a1.21,1.21,0,0,1-1.22,0l-2.14-1.23a1.21,1.21,0,0,1-.61-1.05v-2.46a1.19,1.19,0,0,1,.61-1L21.94,149a1.21,1.21,0,0,1,1.22,0l2.15,1.23a1.19,1.19,0,0,1,.61,1v2.46Z"/><path class="cls-3" d="M22.71,152.3a.79.79,0,0,1-.74-.05L20,151.07c-.22-.14-.25-.33-.06-.44l2.29-1.32a.82.82,0,0,1,.74.06l1.94,1.18c.22.13.25.33.07.44Z"/><path class="cls-3" d="M25.46,151.63v2a.78.78,0,0,1-.31.61L23,155.51c-.18.1-.32,0-.32-.24v-2a.74.74,0,0,1,.32-.6l2.17-1.24C25.32,151.29,25.46,151.4,25.46,151.63Z"/><path class="cls-13" d="M25,151l-2.3,1.31a.82.82,0,0,1-.74-.05L20,151.07c-.22-.14-.25-.34-.06-.44l2.29-1.32a.82.82,0,0,1,.74.05l1.94,1.19C25.16,150.68,25.19,150.88,25,151Z"/><path class="cls-3" d="M25.46,151.63v2a.78.78,0,0,1-.31.61L23,155.51c-.18.1-.32,0-.32-.24v-2a.74.74,0,0,1,.32-.6l2.17-1.24C25.32,151.29,25.46,151.4,25.46,151.63Z"/><g class="cls-4"><text class="cls-14" transform="translate(38 201.91)">',
            "0x", toAsciiString(contractAddress),
            '</text></g></svg>'
        ));
    }

    function generateDescription(uint256 amount, string memory symbol, uint256 unlockTime, address contractAddress) internal pure returns (string memory ret) {
        _DateTime memory dt = parseTimestamp(unlockTime);
        
        ret = string(abi.encodePacked(
            'This NFT holds ', toString(amount), symbol,
            ' and can be unlocked on ', toString(dt.month) ,'/', toString(dt.day) ,'/', toString(dt.year),
            '. Locked token address: 0x', toAsciiString(contractAddress)
        ));
    }

    function construct(
        uint256 amount, 
        uint256 decimals, 
        string memory symbol, 
        uint256 unlockTime, 
        address contractAddress, 
        uint256 reward, 
        uint8 mark
    ) public view returns (string memory) {
        string memory amountWithSymbol = string(abi.encodePacked(generateAmount(amount, decimals), " ", symbol));
        
        uint256 daysCount = 0;
        if(block.timestamp < unlockTime) {
            uint256 secs = unlockTime - block.timestamp;
            daysCount = (secs / 86400);
        }
        string memory image = Base64.encode(bytes(generateSVGImage(amountWithSymbol, daysCount, contractAddress, reward, mark)));

        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            "Stone ", symbol,
                            '", "description":"', generateDescription(amount, symbol, unlockTime, contractAddress),
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