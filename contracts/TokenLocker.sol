// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


    /**
     * @title TokenLocker
     * @dev A contract to lock ERC20 tokens with features for adding funds, withdrawing tokens, and extending lock periods.
     * Implements upgradeable patterns and includes access control mechanisms.
    */
    contract TokenLocker is ReentrancyGuardUpgradeable, OwnableUpgradeable,UUPSUpgradeable, PausableUpgradeable{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /// @dev Struct representing a lock
    struct Lock{
        address tokenAddress;       // Address of the ERC20 token
        uint256 amount;             // Amount of the tokens locked
        uint256 startTime;          // Lock start timestamp
        uint256 endTime;            // Lock end timestamp
        string title;               // Title of the lock
        string description;         // Description of the lock
        bool isActive;              // Whether the lock is still active
        uint256 lockPercentage;     // Lock Percentage

    }

    // Array to store all locks
    Lock[] public locks;

    // Events
    /**
     * @notice Emitted when tokens are locked
     * @param lockID The unique identifier for the lock
     * @param token The address of the locked token
     * @param amount The amount of tokens locked
     * @param startTime The timestamp when the lock starts
     * @param endTime The timestamp when the lock ends
     * @param owner The address of the lock creator
     */
    event TokensLocked(
        uint256 indexed lockID,
        address indexed token,
        uint256 amount,
        uint256 startTime,
        uint256 endTime,
        address indexed owner,
        uint256 lockPercentage
    );

    /**
     * @notice Emitted when funds are added to a lock
     * @param user The address adding the funds
     * @param lockId The unique identifier of the lock
     * @param amount The amount of tokens added
     * @param timestamp The timestamp when funds were added
     */
     event FundsAddedToLocker(
        address indexed user,
        uint256 indexed lockId,
        uint256 amount,
        uint256 timestamp
    );

    /**
     * @notice Emitted when tokens are withdrawn
     * @param lockID The unique identifier of the lock
     * @param token The address of the token
     * @param recipient The address of the recipient
     * @param amount The amount of tokens withdrawn
     */
    event TokensWithdraw(
        uint256 indexed lockID,
        address indexed token,
        address indexed recipient,
        uint256 amount
    );

    /**
     * @notice Emitted when a lock's end time is extended
     * @param lockID The unique identifier of the lock
     * @param newEndTime The new end time of the lock
     */
    event LockExtended(
        uint256 indexed lockID, 
        uint256 newEndTime
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer{
         __ReentrancyGuard_init();
        __Ownable_init();
        // require(msg.sender == owner(), "Unauthorized");
        __UUPSUpgradeable_init();
        __Pausable_init();
    }
 
    /**
     * @notice Authorizes upgrades to the contract
     * @param newImplementation The address of the new implementation
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner{}

    /**
     * @notice Pauses the contract
     * @dev Only callable by the owner
     */
    function pause() external onlyOwner{
        _pause();
    }

    /**
     * @notice Unpauses the contract
     * @dev Only callable by the owner
     */
    function unpause() external onlyOwner{
        _unpause();
    }

    /**
     * @notice Creates a new token lock
     * @param tokenAddress The address of the token to lock
     * @param startTime The timestamp when the lock starts
     * @param endTime The timestamp when the lock ends
     * @param title The title of the lock
     * @param description The description of the lock
     * @return lockId The index of the created lock
     * @notice Creates a new token lock with lock percentage
     */
    function createLock(
        address tokenAddress,
        uint256 amount,
        uint256 startTime,
        uint256 endTime,
        string memory title,
        string memory description,
        uint256 lockPercentage
    ) external nonReentrant onlyOwner returns (uint256) {
        require(tokenAddress != address(0), "Invalid Token Address");
        require(amount > 0, "Amount must be greater than zero");
        require(startTime >= block.timestamp, "Start Time must be in the future");
        require(endTime > startTime, "End time must be after the start time");
        require(bytes(title).length > 0, "Title cannot be empty");
        require(lockPercentage <= 10000000, "Lock Percentage cannot exceed 100.0000%");

        // Create new Lock
        Lock memory newLock = Lock({
            tokenAddress: tokenAddress,
            amount: amount, 
            startTime: startTime,
            endTime: endTime, 
            title: title,
            description: description,
            isActive: true,
            lockPercentage: lockPercentage
        });

        uint256 lockId = locks.length;
        locks.push(newLock);

         // Transfer tokens directly to the contract
        IERC20Upgradeable(tokenAddress).safeTransferFrom(msg.sender, address(this), amount);

        emit TokensLocked(lockId, tokenAddress,amount, startTime, endTime, msg.sender,lockPercentage);
        return lockId;
    }

    /**
     * @notice Adds funds to an existing lock
     * @param lockId The unique identifier of the lock
     * @param amount The amount of tokens to add
     */
    function addFundsToLocker(uint256 lockId, uint256 amount) external onlyOwner whenNotPaused {
        require(amount > 0, "amount should not be 0");
        require(lockId < locks.length, "locker doesn't exist");
        Lock storage lock = locks[lockId];

        //Ensures the user cannot add funds to a lock that is inactive
        require(lock.isActive, "Cannot add funds to an inactive Lock");

        //Update lock amount and user-specific record
        lock.amount += amount;

        //Emit the FundsAddedtoLocker event
        emit FundsAddedToLocker(msg.sender, lockId, amount, block.timestamp);

        // Transfer tokens directly to the contract
        IERC20Upgradeable(lock.tokenAddress).safeTransferFrom(msg.sender, address(this), amount);

    }

    /**
     * @notice Withdraws tokens from a lock
     * @param lockId The unique identifier of the lock
     * @param amount The amount of tokens to withdraw
     */
    function withdrawTokens(
        uint256 lockId,
        uint256 amount,
        address recipient
        ) external onlyOwner nonReentrant whenNotPaused {
        require(lockId < locks.length, "Invalid lock ID");
        require(recipient != address(0), "Invalid recipient Address");

        Lock storage lock = locks[lockId];

        require(block.timestamp >= lock.endTime, "Tokens are still locked");
        require(lock.isActive, "Lock is not Active");
        require(amount > 0 && amount <= lock.amount, "Invalid Withdrawal amount");

        lock.amount -= amount;

        // Automatically deactivate fully withdrawn locks
        if (lock.amount == 0) {
        lock.isActive = false;
        }

        IERC20Upgradeable(lock.tokenAddress).safeTransfer(recipient, amount);

        // Emit the TokensWithdraw event
        emit TokensWithdraw(lockId, lock.tokenAddress, recipient,amount);
    }
    
    /**
     * @notice Retrieves all locks
     * @return An array of all locks
     */
    function getAllUserLocks() external view returns(Lock[] memory){
        return locks;
    }


    /**
     * @notice Retrieves the balance of a user for a specific token
     * @param token The address of the token
     * @param user The address of the user
     * @return The token balance of the user
     */     
    function getUserTokenBalance(address token, address user) external view  returns (uint256) {
        require(token != address(0), "Invalid token address");
        return IERC20Upgradeable(token).balanceOf(user);
    }

    /**
     * @notice Checks if a lock is active
     * @param lockId The unique identifier of the lock
     * @return True if the lock is active, false otherwise
     */
    function isLockActive(uint256 lockId) external view  returns(bool) {
        require(lockId < locks.length, "Invalid lock ID");
        return locks[lockId].isActive;
    }

    /**
     * @notice Extends the lock period of a lock
     * @param lockId The unique identifier of the lock
     * @param additionalTime The additional time to extend the lock period by
     */
    function extendLockPeriod(uint256 lockId, uint256 additionalTime) public onlyOwner {
        require(lockId < locks.length, "Invalid Lock ID");
        require(additionalTime > 0, "Additional Time must be greater than 0");

        Lock storage lock = locks[lockId];

        require(lock.endTime > block.timestamp, "Lock period has ended");

        //Extend the unlock Time
        lock.endTime += additionalTime;

        emit LockExtended(lockId, lock.endTime);
    }  

    /**
     * @notice Retrieves the lock percentage of a specific lock
     */
    function getLockPercentage(uint256 lockId) external view returns(uint256){
        require(lockId < locks.length, "Invalid Lock ID");
        return locks[lockId].lockPercentage;
    }
}


