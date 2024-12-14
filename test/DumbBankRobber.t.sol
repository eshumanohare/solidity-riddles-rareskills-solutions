// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {DumbBank, IDumbBank, BankRobber} from "../src/DumbBankRobber.sol";

contract DumbBankRobberPWN is Test {
    DumbBank bank;
    BankRobber robber;

    function setUp() public {
        bank = new DumbBank();
        bank.deposit{value: 1 ether}();
        robber = new BankRobber{value: 1 ether}(address(bank));
    }

    function testPWN() public {
        robber.pwn();
        assertEq(address(robber).balance, 2 ether);
    }
}