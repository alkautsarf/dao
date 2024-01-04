// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {Box} from "../src/Box.sol";
import {GovToken} from "../src/GovToken.sol";
import {Timelock} from "../src/TimeLock.sol";

contract MyGovernorTest is Test {
    MyGovernor public governor;
    Box public box;
    GovToken public govToken;
    Timelock public timelock;

    address public USER = makeAddr("user");

    function setUp() public {
        vm.startPrank(USER);
        govToken = new GovToken();
        govToken.mint(msg.sender, 1e18);
        vm.stopPrank();
    }
}