# Audit Forge Pro

The deep-coverage companion to [Audit Forge](https://www.agensi.io/skills/audit-forge)
(free). Pro goes where the core checklist stops — the economic layer
where the money actually moves: rounding and share math, oracle and
flash-loan chains, proxy and upgradeability risk, DeFi attack
patterns, and Foundry PoCs that prove impact in numbers.

## What it adds over the free skill

- Economic and business-logic attack pass: share inflation, double
  claims, credits without funding, unbounded parameters, ledger drift
- Oracle and flash-loan playbook: spot vs TWAP, staleness, fee-charging
  feeds, and the full borrow → manipulate → extract → repay chain
- Proxy and upgradeability deep-dive: storage collisions, initializer
  gaps, admin key paths, UUPS and beacon risk
- DeFi attack patterns: AMM, lending, vaults, governance, bridges,
  MEV — each as a testable question with a reachable call path
- PoCs that end in a measured gain or loss — a PoC without a number
  is a lead, not a finding
- Full report format with severity scoring (impact × likelihood +
  CVSS-style vector) and fix verification

## Worked example

`examples/pro-vault/` — a vault whose share price can be inflated by
a direct donation, so the next depositor receives zero shares and the
attacker redeems the victim's deposit. The PoC measures the exact
gain: attacker +100,000 tokens, victim 0.

```sh
cd examples/pro-vault
forge test -vvv
# [PASS] test_ShareInflation() — attacker gain (ether): 100000
```

Full write-up in `reference/example-report-pro.md`.

## Contents

- `SKILL.md` — the skill: methodology, instructions, rules
- `LISTING.md` — copy-paste listing text for Agensi
- `reference/economic-attack-checklist.md` — the economic pass
- `reference/oracle-flashloan-playbook.md` — oracle + flash-loan chains
- `reference/proxy-upgradeability-checklist.md` — proxy deep-dive
- `reference/defi-patterns-pro.md` — DeFi attack patterns
- `reference/severity-scoring.md` — impact × likelihood + CVSS vector
- `reference/poc-template-pro.t.sol` — PoC template (impact in numbers)
- `reference/example-report-pro.md` — worked example report
- `scripts/pro-init.sh` — scaffold a local Pro audit workspace
- `examples/pro-vault/` — vulnerable vault + passing Foundry PoC

## Quick start

```sh
sh scripts/pro-init.sh /path/to/repo-copy <commit>
# work inside the workspace it creates, run PoCs with: forge test
```

## What it does not do

- It never certifies a contract as safe. An audit narrows risk.
- It never promises a bug will be found, or a bounty will be paid.
  Bug bounties pay only for valid, first-reported bugs.

## License

MIT © 2026 ndrean7. Original work: the author's own audit
methodology, written from the author's own audit practice (including
a settlement-protocol audit, Nov 2026) and general security
knowledge. Not copied from any other skill, course, or audit report —
including the free Audit Forge skill.
