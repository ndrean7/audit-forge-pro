# Severity scoring

Score impact first, then likelihood. A dramatic bug with an
impossible precondition is Medium at most. A bug whose impact cannot
be measured in numbers is not scored High.

## Severity table

| Severity | Meaning |
| --- | --- |
| Critical | Direct loss of user funds, or full protocol compromise, reachable by an unprivileged caller, with a measured gain |
| High | Loss of funds or a broken core invariant, with a realistic path to reach it, and a measured gain or loss |
| Medium | Loss under a precondition (a role, a config, a second bug) or a partial loss |
| Low | Minor loss, griefing, or a broken assumption with limited impact |
| Informational | No direct loss, but worth fixing (stale data, missing expiry, unclear code) |

## Impact — what is lost

- **Direct funds.** Tokens leave a victim or the protocol and arrive
  with the attacker. Measure the amount in the token's own units.
- **Broken invariant.** A rule the protocol promises no longer holds
  (solvency, one-claim-only, price freshness). Name the invariant and
  show the state that breaks it.
- **Privilege gained.** The attacker can do something only a role was
  meant to do (upgrade, mint, sweep). Name the role and the action.
- **Availability.** A feature bricks (a price path that always
  reverts, a payout that can never execute). Name the feature and who
  it blocks.

## Likelihood — how reachable is it

- **Unprivileged.** Any caller, no role, no deposit, no prior state.
  Highest.
- **Small cost.** Needs capital, a fee, or a first deposit — but the
  cost is below the profit. State the cost and the profit.
- **Precondition.** Needs a role, a config, a second bug, or a
  specific state. Name the precondition exactly.
- **Theoretical.** Needs a condition nobody has shown to exist
  (two allowlisted parties sharing a key, a currency credited under
  the wrong chain). Mark it unverified and write the precondition.

## CVSS-style vector (for bounty-ready reports)

Record the vector alongside the severity so a bounty program can
triage without re-reading the whole finding:

- **Attack vector:** network (any caller) / adjacent (needs a role
  or a position) / local (needs a prior state).
- **Attack complexity:** low (deterministic steps) / high (needs
  timing, ordering, or a race).
- **Privileges required:** none / low (a small deposit or a minor
  role) / high (admin or a trusted key).
- **User interaction:** none / required (a victim must act).
- **Scope:** unchanged (the loss stays in the vulnerable contract) /
  changed (the loss spreads to other contracts or chains).
- **Impact:** confidentiality / integrity / availability — which of
  the three actually breaks, and how much.

Example vector text: `AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:H/A:N` — network,
low complexity, no privileges, no user interaction, unchanged scope,
high integrity impact. Write the vector in words too, so a reader who
does not know CVSS can still follow it.

## Scoring discipline

- Never score from the description alone. The PoC's measured gain or
  loss is the impact; the PoC's setup is the likelihood.
- If two findings share one root cause, score the root cause once and
  list the instances — do not inflate the report with duplicates.
- If the impact is real but the path needs a precondition, say so in
  the finding and cap the severity. The precondition is part of the
  score, not a footnote.
- Re-score after the fix is verified: a fix that only raises the cost
  without closing the path changes the likelihood, not the impact.
