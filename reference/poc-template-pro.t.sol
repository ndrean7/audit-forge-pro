// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

/// @title Pro PoC template
/// @notice A Pro PoC ends with a MEASURED gain or loss in real units.
/// A PoC that only shows a revert or a strange return value is a lead,
/// not a finding. Fill in every section; delete nothing until the PoC
/// runs green with the numbers asserted.
///
/// HOW TO USE:
///  1. Deploy the target and fund the actors from a clean state.
///  2. Run the attack from an UNPRIVILEGED address.
///  3. Record balances before and after. Assert the gain/loss.
///  4. `forge test --match-contract PoC_Template -vvv`
contract PoC_Template is Test {
    // --- Actors -------------------------------------------------------
    address internal attacker = makeAddr("attacker");
    address internal victim = makeAddr("victim");

    // --- Balances recorded before the attack -------------------------
    uint256 internal attackerBefore;
    uint256 internal victimBefore;

    function setUp() public {
        // Deploy the target here from a clean state.
        // Fund the actors here. Fund the PAYING contract, not just
        // the users, if the payout comes from a second contract.
        //
        // Example:
        //   target = new Target();
        //   deal(address(token), attacker, 200_000 ether);
        //   deal(address(token), victim, 100_000 ether);
    }

    function test_Attack() public {
        // --- Record "before" -----------------------------------------
        // attackerBefore = token.balanceOf(attacker);
        // victimBefore = token.balanceOf(victim);

        // --- Step 1: set up the vulnerable state --------------------
        // e.g. attacker deposits 1 wei, becoming the first depositor.

        // --- Step 2: bend the number the protocol trusts ------------
        // e.g. attacker donates directly to the vault, inflating the
        // share price without minting shares.

        // --- Step 3: the victim acts on the bent number --------------
        // e.g. victim deposits and receives zero shares.

        // --- Step 4: the attacker extracts ---------------------------
        // e.g. attacker redeems the single share for the whole pool.

        // --- Record "after" and assert the measured impact -----------
        // uint256 attackerAfter = token.balanceOf(attacker);
        // uint256 victimAfter = token.balanceOf(victim);
        // assertEq(victimShares, 0, "victim must receive zero shares");
        // assertGt(attackerAfter, attackerBefore, "attacker must gain");
        // console.log("attacker gain:", attackerAfter - attackerBefore);
    }
}
