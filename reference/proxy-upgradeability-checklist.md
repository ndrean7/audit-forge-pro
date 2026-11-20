# Proxy and upgradeability checklist

An upgradeable contract is two contracts that share one storage. The
risk is not the upgrade itself — it is everything the two halves
assume about each other.

## Storage layout

- [ ] List every storage slot the implementation uses, in order, and
      every slot the proxy reserves. Do they overlap anywhere? A
      single overlap silently changes what a variable means.
- [ ] Is there a storage gap (a reserved `uint256[50]`) in the
      implementation, and is it shrinking with each upgrade? What
      happens when it runs out?
- [ ] Are new variables appended at the end only — never inserted in
      the middle, never reordered, never retyped?
- [ ] Does any implementation read a slot the proxy also writes
      (admin, implementation address, beacon)?

## Initialization

- [ ] Can the implementation be initialized twice? Can it be
      initialized by the wrong caller? Can it be left uninitialized
      while the proxy already routes calls to it?
- [ ] Is the initializer guarded (a version, a flag, a
      constructor that disables initializers on the implementation
      itself)?
- [ ] Are there state variables set in the constructor that the proxy
      never sees — because the constructor runs on the implementation,
      not on the proxy?
- [ ] Does the upgrade path re-run any initialization, and does it
      reset state it should not?

## Who can upgrade

- [ ] Who holds the upgrade key — one address, a multisig, a DAO,
      a timelock? How many keys, and what happens if one is lost or
      stolen?
- [ ] Is there a timelock or a delay between proposing and executing
      an upgrade? Can it be bypassed?
- [ ] For UUPS: who can call the upgrade function, and is it guarded
      by the same access control as the rest of the admin surface?
- [ ] For beacons: who controls the beacon, and what happens to every
      proxy at once when it changes? Is that blast radius documented?
- [ ] Can an upgrade be front-run, or can a pending upgrade be
      executed by someone other than the proposer?

## Selectors and delegation

- [ ] Does any function selector collide between the proxy and the
      implementation — so a call meant for one lands on the other?
- [ ] Does the fallback forward calldata, value, and return data
      correctly, including reverts with their reason strings?
- [ ] Is `delegatecall` used anywhere outside the proxy pattern, and
      does the caller fully control the target and the data?

## Upgrade consequences

- [ ] Does the new implementation change the meaning of any existing
      function — same name, different behavior — in a way that breaks
      integrations, oracles, or frontends?
- [ ] Are events, errors, and return values stable across the
      upgrade, or do consumers silently get something else?
- [ ] Is there a rollback plan if the new implementation bricks —
      and who can trigger it?

## How to close each item

Clean (with the line that proves it), lead (file, line, one-line
hypothesis), or finding (with a PoC that shows the storage collision
or the unauthorized upgrade happening). "Not checked" is written out
with the reason.
