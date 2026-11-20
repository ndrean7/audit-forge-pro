# DeFi attack patterns — Pro edition

Each pattern below is a testable question, not a verdict. For every
pattern you pursue, name the reachable call path from an actor the
attacker controls. No path, no finding.

## AMM

- **Price move inside one transaction.** Can a caller push the spot
  price and have a payout consume it before the price returns? Name
  the pool, the payout function, and the capital needed.
- **First liquidity.** Can the first liquidity provider set the
  initial price or the initial share ratio, then profit from the
  second provider's deposit?
- **Fee and slippage accounting.** Is the fee taken on the way in, on
  the way out, or both — and does the quoted amount match the amount
  that actually moves?

## Lending

- **Liquidation math.** Can price timing, a partial repayment, or a
  bonus calculation leave an undercollateralized remainder that
  nobody can liquidate — or let a liquidator take more than the debt?
- **Interest and index drift.** Is the interest index updated before
  every borrow, repay, and liquidation — or can a stale index be
  used to borrow against value that no longer exists?
- **Collateral that changes.** Does the protocol re-check collateral
  value after a token rebases, charges a fee, or gets paused?

## Vaults

- **Donation and inflation.** Can anyone change the vault's asset
  balance without minting shares, and does the share price move?
  (Worked example in `examples/pro-vault/`.)
- **Deposit and withdrawal asymmetry.** Is the deposit measured by
  what arrived and the withdrawal paid by what the ledger says —
  and can the two disagree?
- **First depositor.** What does the first deposit get, and what does
  the second deposit get after the first one moves the rate?

## Governance

- **Borrowed voting power.** Can voting power be borrowed, flash
  loaned, or moved across the snapshot and the execution boundary?
  Check the snapshot block, the quorum, and the timelock — and
  whether a proposal can execute before the timelock expires.
- **Proposal power.** Who can create a proposal, and can a proposal
  change the rules that govern proposals?

## Bridges and settlement

- **Message binding.** Are source chain, sender, nonce, recipient,
  amount, and finality all bound to the message consumed on the
  destination — or can one field be swapped while the rest still
  verify?
- **Nonce and replay.** Is the nonce bound to the chain and the
  contract that issued it, or can a nonce from one chain or one
  builder be replayed on another?
- **Solver and executor binding.** When a signed request names a
  minimum output, is the executor bound to the solver the request
  intended — or can anyone front-run with their own resolver and keep
  the spread?
- **Credit without funding.** Does every credit check that the
  credited account funded, earned, or was authorized for the credit?
  A credit that checks only "non-zero address" is claimable by
  anyone who names an account.

## MEV and ordering

- **Is the claimed ordering possible** on this chain and within the
  program's rules? Quantify the attacker profit after fees and
  slippage — a ordering advantage that costs more than it earns is
  not an attack.
- **Front-running a payout.** Can anyone see a pending payout and
  insert their own transaction ahead of it to take the value?

## Evidence gate (applies to every pattern)

1. Show a reachable call path from an actor the attacker controls.
2. Reproduce the state transition in a local Foundry test. A
   flash-loan cycle must repay in the same transaction.
3. Measure attacker gain and victim or protocol loss in real units.
4. Check mitigations, prior audits, known issues, and program
   exclusions before rating severity.
