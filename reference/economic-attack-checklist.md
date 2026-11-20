# Economic and business-logic attack checklist

Use this pass after the value flows are mapped and the accounting
invariant for each flow is written in one sentence. Each item is a
question to answer with a file, a line, and a number — not a feeling.

## Rounding and precision

- [ ] For every division, who gains when it rounds down, and who gains
      when it rounds up? Who chooses the direction — the caller, the
      first actor, or the protocol?
- [ ] Does any mint, share, or payout computation divide before it
      multiplies, losing precision on small amounts?
- [ ] Can a tiny first deposit set the exchange rate for everyone who
      follows (share price set by the first actor, then inflated)?
- [ ] Is there a minimum deposit, minimum share, or dust threshold —
      and what happens below it: zero shares, a revert, or silent loss?
- [ ] Do fees round in the protocol's favor on deposit and against the
      user on withdrawal (or the reverse), and is the asymmetry
      documented?

## Share and vault accounting

- [ ] Can anyone change the vault's asset balance without minting
      shares — a direct token transfer, a donation, a reward drop?
      What does the share price do then?
- [ ] Is the share price computed from the live token balance or from
      an internal accounting variable — and can the two disagree?
- [ ] Does a deposit measure what actually arrived (balance before and
      after) or what the caller claimed to send? Fee-on-transfer,
      rebasing, and hook-bearing tokens break the second kind.
- [ ] On withdrawal, is the payout computed from the same balance the
      deposit measured? An asymmetry strands value or creates it.
- [ ] Can a user deposit, inflate, withdraw, and repeat in a loop for
      a growing gain?

## Credits, claims, and one-time rights

- [ ] Does every credit check that the credited account earned it —
      funded it, was assigned it, or was authorized for it? A credit
      that checks only "non-zero address" is claimable by anyone.
- [ ] Does every claim, refund, withdrawal, and gas-payment record
      bind WHO used it — or only THAT it was used? A record without a
      spender lets a second spender ride on the first payment.
- [ ] Can a right be used twice because the record is written after
      the external call, or because a retry replays the same inputs?
- [ ] Is there an idempotency key, and does it bind all of the inputs
      that matter (chain, contract, token, amount, receiver, nonce,
      spender)?

## Fees, parameters, and unbounded inputs

- [ ] Is every fee, discount, bonus, and penalty bounded — minimum,
      maximum, or both? Who can change the bound?
- [ ] Can a caller supply their own fee, discount, or bonus value with
      no floor and no gas gate?
- [ ] Can a parameter be set to zero (or to an extreme) in a way that
      disables a check, a fee, or a payout entirely?
- [ ] Are there two ledgers for the same value (a credit ledger and a
      token balance, a nonce store and an authorization store) that can
      disagree — and which one wins when they do?

## State and timing

- [ ] Can a transition be skipped, repeated, reversed, or resumed after
      expiry or cancellation — and does the accounting survive each?
- [ ] Does any authorization, signature, price, or approval never
      expire? What is the cost of it being used a year later?
- [ ] Can an old state be reused after the protocol moved on — an old
      order address, an old nonce, an old trigger hash?
- [ ] Does a revert in one step of a multi-step flow roll back all of
      it, or does a partial effect survive (a burned nonce, a recorded
      payment, a moved balance)?

## How to close each item

For each checked item, record one of: clean (with the line that
proves it), lead (file, line, one-line hypothesis of who gains what),
or finding (with a PoC that measures the gain or loss). An item left
blank is not an item reviewed — write "not checked" and say why.
