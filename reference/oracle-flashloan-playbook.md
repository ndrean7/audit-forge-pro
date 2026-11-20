# Oracle and flash-loan playbook

A price is only as honest as the window in which it can be moved.
This playbook turns every consumed price into a testable question,
and every flash-loan idea into a full chain that must repay.

## The price pass

### What kind of price is it?

- Spot price from a single pool or feed: movable inside one block by
  anyone with enough capital. Ask what it costs to move it vs what
  the protocol pays out on the moved price.
- TWAP over a window: harder to move, but the window is the attack
  surface. Ask how long the window is, whether the first observation
  is attacker-controlled, and what happens before the window fills.
- Signed off-chain price: only as fresh as the signature. Ask for the
  maximum age anywhere in the code — and what happens when the signed
  price is from last week, or from next week.
- A fallback price: ask who controls the fallback, what it returns
  when the primary feed fails, and whether the fallback can be
  triggered on purpose.

### Staleness and bounds

- Is there a maximum age on the price before it is used? If not,
  a stale price is usable forever.
- Is there a sanity bound (a maximum move per update, a floor, a
  ceiling)? If not, one bad observation flows straight into payouts.
- Does the protocol check the price feed is alive (a heartbeat, a
  round ID that increases) or does it trust whatever the call
  returns?

### When the feed itself costs money

- Some price feeds charge a fee per verification (LINK, a verifier
  fee). Ask: who funds the fee, who approved the spending, and what
  happens when the fee is not zero?
- If the adapter cannot approve or fund its own fee, every call that
  needs a price reverts — and the feature the price serves bricks
  with it. Check the adapter for an approval path, a funding
  function, and a constructor approval. A NatSpec comment that says
  "pre-funded" is not a funding function.

### Trigger and attestation paths

- Can anyone record a trigger, a hash, or a self-attested price with
  no check on who they are? Ask what that record unlocks downstream
  — a payout, a mint, a settlement — and whether the downstream step
  re-checks anything.

## The flash-loan chain

A flash-loan attack is four steps in one transaction. Build all four
or the idea is not an attack:

1. **Borrow.** Which pool lends the asset, in what size, for what fee?
   Name the pool and the fee.
2. **Manipulate.** What does the borrowed capital move — a spot price,
   a share price, a vote, a liquidation threshold? Name the function
   and the input the attacker controls.
3. **Extract.** What pays out on the manipulated state — a mint, a
   withdrawal, a liquidation bonus, a settlement? Name the payout and
   its size in real units.
4. **Repay.** Does the extracted value cover the loan plus the fee
   plus the gas plus the slippage? Measure it. A chain that cannot
   repay is a failed transaction, not a finding.

### What to measure

- Attacker profit after all costs (loan fee, gas, slippage), in the
  token the protocol loses.
- Victim or protocol loss in the same units.
- The capital the chain needs, and whether it fits in one block.

### Common dead ends (record them, do not report them)

- The manipulated price is never consumed by a payout in the same
  transaction.
- The payout is capped below the manipulation cost.
- The loan cannot be repaid because the extraction happens after the
  repay step, or on another chain, or in a later block.
