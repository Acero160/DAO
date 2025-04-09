//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {Box} from "../src/Box.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {GovToken} from "../src/GovToken.sol";

contract MygovernorTest is Test {

    MyGovernor governor;
    Box box;
    TimeLock timelock;
    GovToken govToken;

    address public USER = makeAddr("user");
    uint256 public constant INITIAL_SUPPLY = 100 ether;
    uint256 public constant MIN_DELAY = 3600; //1 hour - after a vote passes
    uint256 public constant VOTING_DELAY = 1; //how many blocks till a vote is active
    uint256 public constant VOTING_PERIOD = 50400; //how many blocks till a vote is inactive

    address[] proposers;
    address[] executors;
    uint256 [] values;
    bytes [] calldatas;
    address [] targets;
    
    bytes32 public constant TIMELOCK_ADMIN_ROLE = keccak256("TIMELOCK_ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    function setUp() public {
        govToken = new GovToken();
        govToken.mint(USER, INITIAL_SUPPLY);

        vm.startPrank(USER);
        govToken.delegate(USER);
        timelock = new TimeLock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(govToken, timelock);

        
        timelock.grantRole(PROPOSER_ROLE, address(governor));
        timelock.grantRole(EXECUTOR_ROLE, address(0));
        timelock.revokeRole(TIMELOCK_ADMIN_ROLE, USER);
        

        box = new Box(USER);
        box.transferOwnership(address(timelock));

        vm.stopPrank();
    }

    function testCantUpdateWithoutCovernance() public {
        vm.expectRevert();
        box.store(1);
    }

    function testGovernanceUpdatesBox () public {
        uint256 valueToStore = 888;
        string memory description = "Store 888 in the box";
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);

        values.push(0);
        calldatas.push(encodedFunctionCall);
        targets.push(address(box));

        //1. Propose to the DAO
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // View the status of the proposal
        console.log("Proposal State", uint256(governor.state(proposalId)));

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        console.log("Proposal State", uint256(governor.state(proposalId)));

        //2. Vote on the proposal
        string memory reason = "I like it";

        uint8 voteWay = 1; //voting yes
        vm.prank(USER);
        governor.castVoteWithReason(proposalId, voteWay, reason);

        vm.warp (block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        // 3. Queue the proposal
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(targets, values, calldatas, descriptionHash);

        vm.warp (block.timestamp + MIN_DELAY + 1);
        vm.roll(block.number + MIN_DELAY + 1);


        //4. Execute
        governor.execute(targets, values, calldatas, descriptionHash);

        console.log("Box value", box.getNumber());
        assert(box.getNumber() == valueToStore);
    }
}
