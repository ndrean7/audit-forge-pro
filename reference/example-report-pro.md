# Worked example — Pro report: share inflation by donation

A synthetic vault reviewed end to end with Audit Forge Pro. The
contracts are written for teaching (`examples/pro-vault/`); they are
not a real protocol. All numbers below are measured from the PoC run,
not estimated.

## Scope

- Target: `examples/pro-vault/src/InflatableVault.sol` (+
  `MockToken.sol`, teaching-only ERC20), reviewed at the local copy.
- In scope: `deposit`, `withdraw`, `totalAssets`, share accounting.
- Out of scope: the token contract itself, any frontend, any
  deployment.
- Economic surface: one value flow — users deposit tokens, receive
  shares, redeem shares for tokens. Accounting invariant: "shares
  minted are proportional to tokens deposited, measured at the
  deposit-time share price."

## Finding 1 — High: first-depositor share inflation steals the next deposit

**Severity:** High. Scoring rationale: direct loss of user funds
with a realistic path — the attacker needs only to be the first
depositor and to front the donation capital, which the attack itself
returns. CVSS-style vector: `AV:N/AC:L/PR:N/UI:R/S:U/C:N/I:H/A:N`
(network, low complexity, no privileges, victim must deposit,
unchanged scope, high integrity impact).

**Location:** `src/InflatableVault.sol`, `deposit()` — share price
computed from the live token balance; no minimum-share check.

**Attack chain:**

1. Attacker deposits 1 wei and receives 1 share (first depositor).
2. Attacker transfers 100,000 tokens directly to the vault. No shares
   are minted; the live balance — and therefore the share price —
   jumps.
3. Victim deposits 100,000 tokens. Shares = 100,000 × 1 /
   (100,000 + 1) = 0 after integer division. The victim receives zero
   shares; the tokens stay in the vault.
4. Attacker redeems the single share for the entire pool balance.

**Description:** `deposit()` computes shares from
`totalAssets()`, which reads the vault's live token balance. Any
direct transfer changes that balance without minting shares, so the
share price is attacker-controlled. There is no minimum-share check,
so a deposit that mints zero shares succeeds silently instead of
reverting.

**Impact:** Measured by the PoC — attacker gain exactly 100,000
tokens (the victim's full deposit); victim balance 0, victim shares
0. The loss is the victim's entire deposit, in the token's own units.

**Proof of concept:** `test/PoC_ShareInflation.t.sol`,
`test_ShareInflation()`. Run: `forge test -vvv`. Result: 1 passed,
0 failed. Logs: `attacker gain (ether): 100000`, `victim balance
(ether): 0`. Gas: 327,410.

**Recommendation:** The smallest fix that closes the hole: (a)
measure deposits by balance before and after, and mint shares from
the internal accounting variable — not the live balance; or (b) keep
the live balance but add a minimum-share check that reverts a
zero-share deposit and a minimum first-deposit ("dead shares" locked
to the zero address). Either fix must make the victim's deposit
revert or mint a fair share amount.

**Fix verification:** Re-run the PoC against the patched code — it
must fail (the victim receives shares, or the deposit reverts). The
protocol's own tests must still pass.

**Status:** Verified (PoC passes).

## Killed leads

- **Withdrawal rounding.** Checked: `withdraw()` divides by
  `totalSupply` after the burn math; with the inflation fixed, the
  rounding favors the vault by at most 1 wei per withdrawal. Not a
  finding — recorded so it is not re-checked blindly.
- **Direct donation without a first deposit.** If nobody has
  deposited, a donation sits in an empty vault and the first real
  depositor's shares are computed against it. Same root cause as
  Finding 1, not a second finding — scored once, listed once.

## Areas not covered

The token contract (`MockToken.sol`) was not reviewed beyond its use
as a test stand-in. No oracle, proxy, or bridge code exists in this
example. No mainnet fork was used.

## Closing

This audit narrows risk; it does not certify the contracts as safe.
