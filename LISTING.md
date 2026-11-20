# Listing — Audit Forge Pro (Agensi)

Copy ready for upload to Agensi. Paid v1 — $10. The free Audit Forge
stays the discovery hook; Pro is the deeper version with wider
coverage, better references, and material not in the free skill.

## Title

Audit Forge Pro

## Tagline

Go past the checklist — prove the economic attack, price the impact, write the report.

## Description

Most protocol losses do not come from a missing access check. They
come from math that rounds the wrong way, a price feed an attacker
can push inside its own update window, a credit nobody authorized, a
payment record that does not say who paid, or an upgrade that silently
changes what a storage slot means. That is the layer Audit Forge Pro
audits.

Give Pro a Solidity codebase and it models the protocol as an economy
first and a codebase second: who puts value in, who takes value out,
what each transition is allowed to move, and which numbers an attacker
can bend. Then it hunts in five passes — economic and business-logic
attacks, oracle manipulation and flash-loan chains, proxy and
upgradeability risk, DeFi attack patterns, and cross-function
accounting — and proves each suspected break with a Foundry proof of
concept that ends in a number: how much the attacker gains, how much
the victim or the protocol loses. A PoC that cannot name the gain is
not finished.

Every finding is scored (impact × likelihood, plus a CVSS-style
vector for bounty-ready reports) and written up in a full report
format: attack chain, measured impact, PoC, fix, and fix
verification — the same PoC re-run against patched code must fail,
and the protocol's own tests must still pass. The report states
plainly what was not covered, and it never claims the contracts are
safe. An audit narrows risk; it does not erase it.

Built from real audit practice, including a settlement-protocol audit
(Nov 2026, Foundry only, no chain transactions) whose lessons are
rewritten here as general patterns: credits that check only
"non-zero address", executors that let anyone front-run the spread,
payment records that do not bind the spender, price adapters that
cannot pay their own feed fee, authorizations that never expire.

What it does not do: it never promises a bug will be found, and it
never promises a bounty. Bug bounties pay only for valid,
first-reported bugs — a review may find nothing, and that is a valid
result.

## Category

Security

## Tags

smart-contract-audit, solidity, security, foundry, defi, oracle,
proxy, bug-bounty, poc, economic-attack

## Price

$10

## What buyers get

- A five-pass deep audit: economic/business-logic, oracle + flash-loan
  chains, proxy/upgradeability, DeFi patterns, cross-function accounting
- Foundry PoCs that prove impact in measured numbers — attacker gain
  and victim loss in real units, re-runnable locally (no mainnet
  transactions)
- A full severity-scored report: attack chain, impact, PoC, fix, and
  fix verification — bounty-ready in format
- A worked example: a vault share-inflation attack with a passing PoC
  (attacker +100,000 tokens, victim 0) and the complete report
- Invariant-harness lessons built in: pin the fuzz target, fund the
  paying contract, assert against the contract's own ledger
- Killed leads recorded, so no path is checked twice blindly

## Example session

User: "Deep-audit this vault before launch — I care about the economics, not just the checklist."

The skill freezes the scope (repo + commit + economic surface), maps
the value flow, and finds the share price is computed from the live
token balance with no minimum-share check. It writes a Foundry PoC:
the attacker deposits 1 wei for 1 share, donates 100,000 tokens
directly to the vault, the victim deposits 100,000 tokens and receives
zero shares, and the attacker redeems the single share for the whole
pool. Measured impact: attacker gain exactly 100,000 tokens, victim
balance 0. Finding: High — share inflation by donation, PoC passing,
fix suggested (measure deposits by balance before/after, or add a
minimum-share check). The report scores it with a CVSS-style vector
and closes with fix verification steps. Full example in
`reference/example-report-pro.md`.
