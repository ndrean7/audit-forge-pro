---
name: audit-forge-pro
description: The deep-coverage companion to Audit Forge — economic and business-logic attacks, oracle and flash-loan chains, proxy and upgradeability risk, DeFi attack patterns, Foundry PoCs that prove impact in numbers, and a full severity-scored audit report. Built from real settlement-protocol audit work.
summary: Go past the checklist — prove the economic attack, price the impact, write the report.
version: 1.0.0
tags:
  - security
  - solidity
  - audit
  - foundry
  - defi
  - oracle
  - proxy
  - bug-bounty
keywords:
  - smart contract audit pro
  - economic attack
  - oracle manipulation
  - flash loan
  - proxy upgradeability
  - defi audit
  - foundry poc
use_cases:
  - Deep audit of a DeFi protocol before mainnet launch
  - Price the impact of a suspected economic bug with a PoC
  - Review oracle, bridge, and settlement logic for manipulation paths
  - Audit an upgradeable proxy system for storage and admin risk
  - Write a bounty-ready report with severity scoring and fix verification
hosts: []
docs_url: https://github.com/ndrean7/audit-forge-pro
---

# Audit Forge Pro

## Name

audit-forge-pro

## Description

The free Audit Forge runs the core review: scope the code, work the
checklist, prove each finding with a PoC. Pro goes where the checklist
stops — the layer where the money actually moves. Most protocol losses
do not come from a missing access check. They come from math that
rounds the wrong way, a price feed an attacker can push inside its
own update window, a credit that nobody authorized, a payment record
that does not say who paid, or an upgrade that silently changes what a
storage slot means.

Pro audits that layer. It models the protocol as an economy first and
a codebase second: who puts value in, who takes value out, what each
transition is allowed to move, and which numbers an attacker can bend.
Then it hunts in five passes — economic and business-logic attacks,
oracle manipulation and flash-loan chains, proxy and upgradeability
risk, DeFi attack patterns, and cross-function accounting — and it
proves each suspected break with a Foundry PoC that ends in a number:
how much the attacker gains, how much the victim or the protocol
loses. A PoC that cannot name the gain is not finished.

Every finding is scored, written up in a full report format, and
closed with a fix and a fix-verification run: the same PoC against the
patched code must fail, and the protocol's own tests must still pass.
The report states plainly what was not covered, and it never claims
the contracts are safe — an audit narrows the risk, it does not erase
it. A review may find nothing at all, and that is a valid result.

Pro is the paid companion to the free Audit Forge
(https://www.agensi.io/skills/audit-forge). The free skill covers the
core vulnerability checklist; Pro adds the economic layer, the attack
chains, the proxy deep-dive, the DeFi patterns, and the full reporting
format. Nothing in Pro is copied from the free skill — the checklists,
the example contracts, and the report template here are new.

## How it works

1. **Freeze the scope.** Same discipline as the free skill: repo,
   commit, in-scope and out-of-scope files, recorded before any review.
   Pro adds one more line to the scope record: the economic surface —
   which functions move value, in which token, and to whom.
2. **Map the economy.** Before reading code line by line, draw the
   value flows: deposits, withdrawals, borrowing, rewards, fees,
   cross-chain settlement. For each flow, write the accounting
   invariant in one sentence (for example: "total shares minted never
   exceed deposits minus withdrawals, measured in the underlying
   token"). If the invariant cannot be written in one sentence, the
   flow is not understood yet.
3. **Run the five passes.** Each pass has its own checklist in
   `reference/`:
   - Economic and business-logic attacks
     (`economic-attack-checklist.md`): rounding direction, fee math,
     share inflation, double claims, stale-state reuse, unbounded
     parameters, accounting drift between two ledgers.
   - Oracle and flash-loan chains (`oracle-flashloan-playbook.md`):
     spot vs TWAP, staleness, fallback paths, fee-charging price
     feeds, and the full flash-loan cycle — borrow, manipulate,
     extract, repay in one transaction.
   - Proxy and upgradeability (`proxy-upgradeability-checklist.md`):
     storage collisions, initializer gaps, admin key paths, function
     selector clashes, beacon and UUPS specifics.
   - DeFi attack patterns (`defi-patterns-pro.md`): AMM, lending,
     vaults, governance, bridges, MEV — each as a testable question
     with the reachable call path it needs.
   - Cross-function accounting: the same value tracked in two places
     (a credit ledger and a token balance, a nonce store and an
     authorization store) that can disagree.
4. **Write invariants.** State the protocol's invariants as Foundry
   invariant tests where they can be stated precisely — and include
   the hard-won harness lessons: pin the fuzz target, fund the paying
   contract, never sum a non-additive view, assert against the
   contract's own ledger after the action, not against a recomputed
   expectation.
5. **Prove the impact.** For each suspected break, write a Foundry
   PoC in a local workspace (see `scripts/pro-init.sh`) that ends
   with a measured gain or loss in real units. A PoC that only shows a
   revert or a strange return value is a lead, not a finding.
6. **Score and report.** Score each finding (see
   `reference/severity-scoring.md`), write it in the full report
   format, and close with scope, uncovered areas, killed leads, and
   fix verification.

## Instructions

### Start a Pro audit

```sh
# From the skill directory. Creates a local workspace (no network, no chain):
sh scripts/pro-init.sh /path/to/repo-copy <commit>
```

Work inside the workspace it creates. Read the code there — never edit
the original repository. PoCs live in the workspace's `test/`
directory and run with `forge test`.

### Scoping questions to answer first

- Which repository and commit? Which files are in scope, which are out?
- What does the protocol do, in one paragraph, in the user's own words?
- Who are the actors (user, keeper, admin, oracle, solver, liquidator)
  and what can each one do?
- Where does value enter and leave? Which functions move funds, in
  which token, to which address?
- What is the accounting invariant, in one sentence, for each
  value flow?
- What is explicitly trusted (multisig, oracle, backend, bridge
  relayer) — and what breaks if that trust is abused?

If any answer is missing, ask before reviewing — do not guess.

### The economic pass

For every money-moving function, ask:

- Who gains if this arithmetic rounds down, and who gains if it rounds
  up? Who chooses the direction?
- Can the first actor in a fresh pool set the exchange rate? What
  happens when the second actor arrives?
- Is the same value recorded in two places, and can the two records
  disagree (a credit ledger vs a token balance, a payment record vs
  the spender who uses it)?
- Can a right be used twice — a claim, a refund, a withdrawal, a gas
  payment — because the record of use does not bind who used it?
- Is any parameter unbounded (a fee, a discount, a bonus) with no
  minimum, no maximum, and no gas gate?
- Does a fee-on-transfer, rebasing, or hook-bearing token break the
  assumption that "amount sent equals amount received"?

Work the full list in `reference/economic-attack-checklist.md`.
Record every suspicion as a lead with file, line, and a one-line
hypothesis of who gains what.

### The oracle and flash-loan pass

For every price the protocol consumes, ask:

- Spot or TWAP — and can a caller move the spot price inside the
  update window for less than the profit?
- How stale can the price be before it is used, and is there a
  maximum age anywhere?
- What happens when the price feed itself costs money (a LINK fee, a
  verification fee) — can the adapter even pay it, or does the whole
  path brick?
- Is there a fallback price path, and who controls what it returns?

For every flash-loan hypothesis, build the full chain: borrow,
manipulate, extract, repay — all in one transaction, with the profit
measured after fees and slippage. A chain that cannot repay is not an
attack, it is a failed transaction. Work the playbook in
`reference/oracle-flashloan-playbook.md`.

### The proxy pass

For every upgradeable contract, ask:

- Which storage slots does the implementation use, and which does the
  proxy reserve? Do they overlap anywhere?
- Can the implementation be initialized twice, or initialized by the
  wrong caller, or never initialized at all?
- Who can upgrade, through how many keys, and what stops a single
  compromised key from swapping the logic?
- Do any function selectors collide between proxy and implementation?
- For UUPS: who can call the upgrade function, and is it guarded?
  For beacons: who controls the beacon, and what happens to every
  proxy at once if it changes?

Work the list in `reference/proxy-upgradeability-checklist.md`.

### The DeFi pattern pass

Use `reference/defi-patterns-pro.md`. Each pattern is a testable
question, not a verdict: AMM share and price games, lending
liquidation math, vault donation and inflation, governance power that
can be borrowed across a snapshot, bridge messages that do not bind
chain, sender, nonce, recipient and amount together, and MEV where
the claimed ordering is priced after fees. For each pattern, name the
reachable call path from an actor the attacker controls — no path, no
finding.

### Writing a PoC that proves impact

Use the template in `reference/poc-template-pro.t.sol`. A Pro PoC
must:

- Set up the vulnerable state from a clean deploy (no mainnet fork
  unless the user explicitly provides an RPC URL and the finding needs
  deployed state).
- Execute the attack from an unprivileged address where the finding
  claims an unprivileged attacker.
- End with a measured number: attacker balance before and after,
  victim balance before and after, or protocol balance before and
  after. Assert the gain or loss in real units.
- Run green with `forge test` in the local workspace.

If the PoC cannot produce a number, the lead stays a lead. If the PoC
fails, the lead is dead or its precondition is missing: record it as a
killed lead with the reason, and move on.

### Severity scoring

Score with `reference/severity-scoring.md`: impact first, then
likelihood, then a CVSS-style vector for bounty-ready reports. A
dramatic bug that needs an impossible precondition scores Medium at
most — and its precondition is written in the finding. A bug whose
impact cannot be measured in numbers is not scored High.

### Report format

One finding per section, in this order:

1. **Title** — what breaks, in one line.
2. **Severity** — Critical / High / Medium / Low / Informational,
   with the scoring rationale and the CVSS vector where it applies.
3. **Location** — file and function, with the commit hash.
4. **Attack chain** — the reachable path, step by step, from an
   actor the attacker controls.
5. **Description** — what the code does and why it is wrong.
6. **Impact** — who loses what, with measured numbers from the PoC
   (attacker gain, victim loss, protocol loss).
7. **Proof of concept** — the PoC test file, the key assertion, and
   the measured result.
8. **Recommendation** — the smallest fix that closes the hole.
9. **Fix verification** — the PoC re-run against patched code (must
   fail) and the protocol's own tests (must still pass).
10. **Status** — verified (PoC passes) or unverified (precondition
    noted).

Close the report with: scope (repo, commit, in/out, economic surface),
areas not covered, the killed leads, and the sentence: "This audit
narrows risk; it does not certify the contracts as safe."

### Worked example

See `reference/example-report-pro.md` and `examples/pro-vault/`: a
vault whose share price can be inflated by a direct donation, so the
next depositor receives zero shares and the attacker redeems the
victim's deposit. The PoC measures the exact gain. The example
contracts are written for teaching; they are not a real protocol.

### Lessons from real audit work

These patterns come from the author's own settlement-protocol audit
(November 2026, Foundry only, no chain transactions), rewritten here
as general lessons — not as copied findings:

- A credit that is granted without checking who funded it can be
  claimed by anyone who names an account. Always ask: does this
  credit check that the credited account earned it?
- A permissionless executor that lets the caller choose the resolver
  lets a front-runner keep the spread. Always ask: is the executor
  bound to the party the signed request intended?
- A payment record that does not bind the spender lets a second
  spender ride on the first payment. Always ask: does the record say
  who paid, or only that something was paid?
- A price adapter that cannot pay its own feed fee bricks the whole
  path it serves. Always ask: who funds the fee, and what happens
  when the fee is not zero?
- An authorization that never expires is an authorization forever.
  Always ask: where is the expiry, and who can revoke it?

### Answering questions

- **"Audit this protocol, deep."** — Freeze the scope first (repo +
  commit + in/out + economic surface), then run the five passes in
  order. Do not skip the economy map.
- **"Is this an economic bug?"** — Answer only after a PoC with a
  measured gain or loss. Before that it is a lead, and say so.
- **"How bad is it?"** — Score by the table in
  `reference/severity-scoring.md`, with the precondition written out.
  Never inflate a severity to make the report look better.
- **"Can you check this fix?"** — Re-run the PoC against the fixed
  code: it must fail (the attack no longer works), and the repo's own
  tests must still pass.
- **"Will this win a bounty?"** — Say plainly: bounties pay only for
  valid, first-reported bugs, and a review may find nothing. No
  promise. A Pro report is bounty-ready in format; the finding still
  has to be real and first.

## Rules — do not break these

- **No PoC with a measured impact, no confirmed finding.** A
  suspicion stays a lead until the PoC names the gain or loss in
  numbers.
- **No mainnet or testnet transactions.** All PoCs run locally in
  Foundry. Never ask for a private key, seed phrase, or wallet
  connection, and never sign or send a transaction.
- **Never guarantee safety or a bounty.** An audit narrows risk; it
  never certifies a contract as safe. A review may find nothing, and
  that is a valid result.
- **No copied findings.** Findings come from reading this codebase,
  not from another audit, another entry, or a public report. Prior
  audits of the same code are read to avoid duplicates, and any
  overlap is disclosed as a known issue, not reported as new.
- **Scope is frozen.** Do not report files outside the frozen scope,
  and do not silently move the commit.
- **Original work.** This skill is the author's own methodology (MIT,
  © 2026 ndrean7), written from the author's own audit practice and
  general security knowledge. It is not copied from any other skill,
  course, or audit report — including the free Audit Forge skill,
  whose checklists, examples, and report template were not reused
  here.

## Requirements

- Foundry (`forge`, `cast`) for PoCs and invariant tests.
- Slither and Aderyn for static analysis (optional but recommended).
- A local copy of the target repository at a pinned commit.
- No network access is required for the review itself; a mainnet fork
  is used only when the user explicitly provides an RPC URL.
