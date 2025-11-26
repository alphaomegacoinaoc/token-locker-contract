# Alpha Omega Coin (AOC), The Queen of cryptocurrencies
<br>

# Technical Explanatory Documentation (TED)
## About

# AOC LOCKER (V1.0.0)
<br> 

## OVERVIEW:
## Current and Future AOC Tokens and Coin  Versions
**Alpha Omega Coin (AOC)** - The **Queen of Cryptocurrencies**, operates on an **interoperable** **Monetary, Financial and Economic Galaxy (AOC MFEG)**  which is composed of **AOC Coin (=AOC M**other **C**oin) and **several tokens.** 

As of now, two token contract versions have been launched: 
- AOC ERC20 V3
- AOC BEP20 V2.1

**_The following token standards are yet to be launched_:** 
- AOC TRC20
- AOC POLY

_**AOC Coin**_ or _**AOC Mother Coin**_ is also yet to be launched…

## Introduction
The **AOC Locker(V1.0.0)** is a secure, upgradeable Ethereum smart contract designed to l**ock AOC Coin(= AOC Mother Coin) and AOC Tokens (ERC-20; BEP20 V2.1; TRC20; POLY)** for a specific period of time.

 It ensures that **AOC Coin(= AOC Mother Coin) and AOC Tokens (ERC-20; BEP20 V2.1; TRC20; POLY)** cannot be accessed, transferred, or withdrawn until the lock period expires.
 
Only the **contract Mutli-Sig Owners** have full control over creating, managing, and withdrawing locked tokens after the lock period expires.

All lock details are publicly viewable for **transparency**.

In this _**Technical Explanatory Documentation(TED),**_ we are dealing with **AOC ERC20 V3 and AOC BEP20 (V2.1)** Tokens.

## How It Works
1. The **Muti-Sig Owners create a lock** for any **AOC ERC20 V3** and **AOC BEP20 (V2.1) Tokens.**
2. Tokens are **transferred into the TokenLocker(V1.0.0) contract** and held securely.
3. Tokens remain locked until either:
       - The **end time** of the lock period is reached.
   
The **Mutli-Sig Owners** can at any time:

- Add more tokens to an active lock
- Extend the duration of a lock
- Pause or unpause all contract operations
  
_**Purpose:**_ Multi-sig Owners can pause/unpause transfers for security sake, migration sake or of a community-oriented intervention

Everyone can view lock information publicly, but only the **Mutli-Sig Owners** can make changes.

## Lock Details

Each token lock stores the following information:

- **Token address:** The **ERC20 V3 / BEP20 V2.1** Token being locked
- **Amount:** Total number of tokens locked
- **Start and end timestamps:** The lock’s time period
- **Title and description:** Custom metadata for clarity
- **Active status:** Whether the lock is currently active
- **Lock percentage:** Used for calculation purposes.
  
## Key Features
- **Upgradeable and Ownable:**
 Built using _**OpenZeppelin’s upgradeable contract standards**_ with full owner control.
- **Secure and Transparent:**
 Uses _**SafeERC20**_ for secure token transfers and emits detailed events for all actions.
- **Flexible Lock Management:**
 The _owner can **add tokens, extend locks, or withdraw** at any time._
- **Pausable Functionality:**
 The owner can _**pause and unpause** the entire contract_ for safety or maintenance.

## Functions

## Owner-Only (WRITE) Functions

- **createLock(...) –** Creates a **new token lock** with _**custom duration,**_ **title, and description.**
Tokens are transferred into the contract and recorded as locked.
- **addFundsToLocker(lockId, amount) –** Adds _additional tokens to an existing active lock._
- **withdrawTokens(lockId, amount, recipient) –** **Withdraws a specified amount of tokens** from a **lock** to any recipient address.
- **extendLockPeriod(lockId, additionalTime) –** _**Extends the unlock time**_ of an existing lock.
- **pause() / unpause() –** _**Pauses or resumes all operations**_ within the contract.


## Public (READ) Functions

- **getAllUserLocks() –** **Returns all existing locks** with full details.
- **getUserTokenBalance(token, user) –** Shows any _wallet’s ERC20 V3 and BEP20 V2.1 Token balance._
- **isLockActive(lockId) –** Returns whether a **specific lock is still active.**
- **getLockPercentage(lockId) –** Displays the **configured lock percentage value.**

## In Simple Terms
The **AOC Locker(V1.0.0) contract acts as a secure vault for ERC20 V3 and BEP20 V2.1 Tokens,** managed entirely by the **Mutli-Sig Owners.**

**It allows you to:**
- **Safely lock tokens** for a _set period_,
- **Add tokens** as needed,
- **Extend the lock duration**, and
- **Temporarily pause all operations** for safety.
  
All lock details are visible to the public, ensuring **trust and transparency** while maintaining **full owner control** over token management.





