// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    // Initializing the state variable for random # gen
    uint randNonce = 0;

    struct Stats {
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
    }

    Stats[] public stats;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    // Defining a function to generate
    // a random number from 1-99
    function randomNum() internal returns (uint) {
        // increase nonce
        randNonce++;
        return
            uint(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % 100;
    }

    function generateCharacter(
        uint256 tokenId
    ) public view returns (string memory) {
        Stats memory stat = stats[tokenId - 1];
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels: ",
            stat.level.toString(),
            " Speed: ",
            stat.speed.toString(),
            " Strength: ",
            stat.strength.toString(),
            " Life: ",
            stat.life.toString(),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        string memory imageURI = generateCharacter(tokenId);
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            imageURI,
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function getStats(uint256 tokenId) public view returns (Stats memory) {
        Stats memory statss = stats[tokenId - 1];
        return statss;
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        stats.push(Stats(0, randomNum(), randomNum(), 100));
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing token");
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this token to train it"
        );
        Stats storage currentStats = stats[tokenId - 1];
        currentStats.level = currentStats.level + 1;
        currentStats.life = randomNum();
        currentStats.strength = randomNum();
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
