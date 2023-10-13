// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../34_ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

abstract contract Random is ERC721, VRFConsumerBaseV2 {
    uint256 public totalSupply = 100;
    uint256[100] public ids;
    uint256 public mintCount;

    VRFCoordinatorV2Interface COORDINATOR;

    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint16 requestConfirmations = 3;
    uint32 callbackGasLimit = 1_000_000;
    uint32 numWords = 1;
    uint64 subId;
    uint256 public requestId;

    mapping(uint256 => address) public requestToSender;

    constructor(uint64 s_subId) VRFConsumerBaseV2(vrfCoordinator) ERC721("WTF Random", "WTF") {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        subId = s_subId;
    }

    function pickRandomUniqueId(uint256 random) private returns (uint256 tokenId) {
        uint256 len = totalSupply - mintCount++;
        require(len > 0, "mint close");
        uint256 randomIndex = random % len;

        tokenId = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex;
        ids[randomIndex] = ids[len-1] == 0 ? len - 1 : ids[len-1];
        ids[len-1] = 0;
    }

    function getRandomOnchain() public view returns (uint256) {
        bytes32 randomBytes = keccak256(abi.encodePacked(blockhash(block.number-1), msg.sender, block.timestamp));
    }

    function mintRandomOnchain() public {
        uint256 _tokenId = pickRandomUniqueId(getRandomOnchain());
        _mint(msg.sender, _tokenId);
    }

    function mintRandomVRF() public {
        requestId = COORDINATOR.requestRandomWords(keyHash, subId, requestConfirmations, callbackGasLimit, numWords);
        requestToSender[requestId] = msg.sender;
    }
}