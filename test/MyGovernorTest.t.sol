// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {Box} from "../src/Box.sol";
import {GovToken} from "../src/GovToken.sol";
import {Timelock} from "../src/TimeLock.sol";

contract MyGovernorTest is Test {
    MyGovernor public governor;
    Box public box;
    GovToken public govToken;
    Timelock public timelock;

    uint256 public  constant STARTING_BAL = 1000 ether;
    uint256 public constant MIN_DELAY = 3600;
    uint256 public constant VOTING_DELAY = 1;
    uint256 public constant VOTING_PERIOD = 50400;

    address public USER = makeAddr("user");
    address[] public proposers;
    address[] public executors;
    uint256[] public values;
    bytes[] public calldatas;
    address[] public targets;


    function setUp() public {
        govToken = new GovToken();
        govToken.mint(USER, STARTING_BAL);

        vm.prank(USER);
        govToken.delegate(USER);
        timelock = new Timelock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(govToken, timelock);

        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, msg.sender);

        box = new Box();
        box.transferOwnership(address(timelock));
    }

    function testBalance() public {
        uint256 bal = govToken.balanceOf(USER);
        assertEq(bal, STARTING_BAL);
    }

    function testCantUpdateBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(1);       
    }

    function testGovernanceUpdateBox() public {
        uint256 valueToStore = 777;
        string memory description = "store 777 in box";
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);
        
        values.push(0);
        calldatas.push(encodedFunctionCall);
        targets.push(address(box));

        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        console.log("proposal state: ", uint256(governor.state(proposalId)));

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        console.log("proposal state: ", uint256(governor.state(proposalId)));

        string memory reason = "testing";
        uint8 vote = 1; //* meaning support the proposal.

        vm.prank(USER);
        governor.castVoteWithReason(proposalId, vote, reason);

        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(targets, values, calldatas, descriptionHash);

        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.roll(block.number + MIN_DELAY + 1);

        governor.execute(targets, values, calldatas, descriptionHash);

        assertEq(box.getNumber(), valueToStore);
    }
}