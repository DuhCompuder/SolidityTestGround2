// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SecretMessenger {
    struct Envelope {
        bytes32 key;
        string lockedMessage;
    }
    mapping(address => mapping(address => uint256)) private numMessagesFrom;
    mapping(address => address[]) private inbox;
    mapping(address => mapping(address => mapping(uint256 => Envelope))) private receipient;

    function sendMessage(address to, string calldata message) public {
        bytes32 lock = keccak256(abi.encodePacked(to,msg.sender));
        receipient[to][msg.sender][numMessagesFrom[to][msg.sender]] = Envelope(lock, message);
        numMessagesFrom[to][msg.sender] += 1;
        inbox[to].push(msg.sender);
    }

    function readSecretMessage(address from, uint256 messageId) external view returns (string memory) {
        require(receipient[msg.sender][from][messageId].key == keccak256(abi.encodePacked(msg.sender, from)));
        return receipient[msg.sender][from][messageId].lockedMessage;
    }
    function checkInbox() external view returns (address[] memory) {
        return inbox[msg.sender];
    }
    function checkNumMessagesFrom(address from) external view returns (uint256) {
        return numMessagesFrom[msg.sender][from];
    }
}