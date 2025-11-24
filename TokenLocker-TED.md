## TOKEN LOCKER OVERVIEW:
# Current and Future AOC Token and Coin  Versions
# Alpha Omega Coin (AOC) - The Queen of Cryptocurrencies, operates on an interoperable Monetary, Financial and Economic Galaxy (AOC MFEG)  which is composed of AOC Coin (=AOC Mother Coin) and several tokens. 

As of now, two token contract versions have been launched: 
- AOC ERC20 V3
- AOC BEP20 V2.1
The following token standards are yet to be launched: 
- AOC TRC20
- AOC POLY
- AOC Coin or AOC Mother Coin is also yet to be launched…

## Introduction
The AOC Locker(V1.0.0) is a secure, upgradeable Ethereum smart contract designed to lock AOC Coin(= AOC Mother Coin) and AOC Tokens (ERC-20; BEP20 V2.1; TRC20; POLY) for a specific period of time.

 It ensures that AOC Coin(= AOC Mother Coin) and AOC Tokens (ERC-20; BEP20 V2.1; TRC20; POLY) cannot be accessed, transferred, or withdrawn until the lock period expires. 
Only the contract Mutli-Sig Owners have full control over creating, managing, and withdrawing locked tokens after the lock period expires.
All lock details are publicly viewable for transparency.
In this Technical Explanatory Documentation(TED), we are dealing with AOC ERC20 V3 and AOC BEP20 (V2.1) Tokens.
## How It Works
The Muti-Sig Owners create a lock for any AOC ERC20 V3 and AOC BEP20 (V2.1) Tokens.
Tokens are transferred into the TokenLocker(V1.0.0) contract and held securely.
Tokens remain locked until either:
The end time of the lock period is reached.
 The Mutli-Sig Owners can at any time:
Add more tokens to an active lock
Extend the duration of a lock
Pause or unpause all contract operations
Purpose: Multi-sig Owners can pause/unpause transfers for security sake, migration sake or of a community-oriented intervention
Everyone can view lock information publicly, but only the Mutli-Sig Owners can make changes.
## Lock Details
Each token lock stores the following information:
Token address: The ERC20 / BEP20 V2.1 Token being locked
Amount: Total number of tokens locked
Start and end timestamps: The lock’s time period
Title and description: Custom metadata for clarity
Active status: Whether the lock is currently active
Lock percentage: Used for calculation purposes.
## Key Features
# Upgradeable and Ownable:
 Built using OpenZeppelin’s upgradeable contract standards with full owner control.
# Secure and Transparent:
 Uses SafeERC20 for secure token transfers and emits detailed events for all actions.
# Flexible Lock Management:
 The owner can add tokens, extend locks, or withdraw at any time.
# Pausable Functionality:
 The owner can pause and unpause the entire contract for safety or maintenance.
Functions
# Owner-Only (WRITE) Functions
# createLock(...) – Creates a new token lock with custom duration, title, and description.
 Tokens are transferred into the contract and recorded as locked.
# addFundsToLocker(lockId, amount) – Adds additional tokens to an existing active lock.
# withdrawTokens(lockId, amount, recipient) – Withdraws a specified amount of tokens from a lock to any recipient address.
# extendLockPeriod(lockId, additionalTime) – Extends the unlock time of an existing lock.
# pause() / unpause() – Pauses or resumes all operations within the contract.


## Public (READ) Functions
getAllUserLocks() – Returns all existing locks with full details.
getUserTokenBalance(token, user) – Shows any wallet’s ERC20 V3 and BEP20 V2.1 Token balance.
isLockActive(lockId) – Returns whether a specific lock is still active.
getLockPercentage(lockId) – Displays the configured lock percentage value.
In Simple Terms
The AOC Locker(V1.0.0) contract acts as a secure vault for ERC20 V3 and BEP20 V2.1 Tokens, managed entirely by the Mutli-Sig Owners .


It allows you to:
Safely lock tokens for a set period,
Add tokens as needed,
Extend the lock duration, and
Temporarily pause all operations for safety.
All lock details are visible to the public, ensuring trust and transparency while maintaining full owner control over token management.





