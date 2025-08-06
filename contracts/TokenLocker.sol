// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";


contract TokenLocker is ReentrancyGuardUpgradeable, OwnableUpgradeable,UUPSUpgradeable, PausableUpgradeable{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    mapping(address => mapping(uint256 => uint256)) private userLockers;


    struct Lock{
        address tokenAddress;       // Address of the ERC20 token
        uint256 amount;             // Amount of the tokens locked
        uint256 startTime;          // Lock start timestamp
        uint256 endTime;            // Lock end timestamp
        string title;               // Title of the lock
        string description;         // Description of the lock
        bool isActive;              // Whether the lock is still active
        address owner;              // Owner of the locked tokens
    }

    // struct UserInfo {
    //    uint256 amount;
    // }

    // Array to store all locks
    Lock[] public locks;

    // Mapping from address to their lock indices
    mapping(address => uint256[]) public userLockIndices;

    // Mapping to store the user balances (total locked amount)
    // mapping(address => uint256) public userBalances;

    // Events
    event TokensLocked(
        uint256 indexed lockID,
        address indexed token,
        uint256 amount,
        uint256 startTime,
        uint256 endTime,
        address indexed owner
    );

    // event TokensUnlocked(
    //     uint256 indexed lockID,
    //     address indexed token,
    //     address indexed owner,
    //     uint256 amount
    // );
    
     event FundsAddedToLocker(
        address indexed user,
        uint256 indexed lockId,
        uint256 amount,
        uint256 timestamp
    );
    event TokensWithdraw(
        uint256 indexed lockID,
        address indexed token,
        address indexed owner,
        uint256 amount
    );
    event LockExtended(
        uint256 indexed lockID, 
        uint256 newEndTime
    );


    //Constructor is removed, replaced with an initializer function
    function initialize() public initializer{
        __Ownable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
        __Pausable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner{}

    function pause() external onlyOwner{
        _pause();
    }
    function unpause() external onlyOwner{
        _unpause();
    }


    /**
    * @dev Creates a new token lock
    * @param tokenAddress The address of the token to lock
    * @param startTime The timestamp when the lock starts
    * @param endTime The timestamp when the lock ends
    * @param description The description of the lock
    * @return lockId The index of the created Lock
    */
    function createLock(
        address tokenAddress,
        uint256 startTime,
        uint256 endTime,
        string memory title,
        string memory description
    ) external nonReentrant onlyOwner returns (uint256) {
        require(tokenAddress != address(0), "Invalid Token Address");
        require(startTime >= block.timestamp, "Start Time must be in the future");
        require(endTime > startTime, "End time must be after the start time");
        require(bytes(title).length > 0, "Title cannot be empty");

        //Prevent the same token from begin used for multiple locks by the user
        for (uint256 i =0; i < userLockIndices[msg.sender].length; i++){
            Lock storage existingLock = locks[userLockIndices[msg.sender][i]];
            require(existingLock.tokenAddress != tokenAddress, "Token already used for a lock");
        }

        // Create new Lock
        Lock memory newLock = Lock({
            tokenAddress: tokenAddress,
            amount: 0, //Funds can be added Later
            startTime: startTime,
            endTime: endTime,
            title: title,
            description: description,
            isActive: true,
            owner: msg.sender 
        });

        // Add lock to array and get index
        uint256 lockId = locks.length;
        locks.push(newLock);

        // Add lock index to the user's locks
        userLockIndices[msg.sender].push(lockId);


        // // Update user's locked balance
        // userBalances[msg.sender] += amount;

        // Emit the locked tokens event
        emit TokensLocked(lockId, tokenAddress,0, startTime, endTime, msg.sender);
        return lockId;
    }

    function addFundsToLocker(uint256 lockId, uint256 amount) external onlyOwner whenNotPaused {
        require(amount > 0, "amount should not be 0");
        require(lockId < locks.length, "locker doesn't exist");
        Lock storage lock = locks[lockId];

        //Ensures the user cannot add funds to a lock that is inactive
        require(lock.isActive, "Cannot add funds to an inactive Lock");

        // Transfer tokens directly to the contract
        IERC20Upgradeable(lock.tokenAddress).safeTransferFrom(msg.sender, address(this), amount);

        //Update lock amount and user-specific record
        lock.amount += amount;
        userLockers[msg.sender][lockId] += amount;    

        //Emit the FundsAddedtoLocker event
        emit FundsAddedToLocker(msg.sender, lockId, amount, block.timestamp);

    }

    // /**
    // * @dev Unlocks tokens if the lock period has ended (anyone can unlock after the lock ends)
    // * @param lockId The index of the lock to unlock
    // */
    // function unlock(uint256 lockId) external onlyOwner nonReentrant{
    //     require(lockId < locks.length, "Invalid Lock ID");
    //     Lock storage lock = locks[lockId];

    //     // require(lock.owner == msg.sender, "Not the Lock Owner"); 
    //     require(lock.isActive, "Lock is not Active");
    //     require(block.timestamp >= lock.endTime, "Lock period not ended yet!");

    //     lock.isActive = false;

    //     //Transfer tokens to the lock's owner
    //     IERC20Upgradeable(lock.tokenAddress).safeTransfer(msg.sender, lock.amount);

    //     // // Update user's locked balance
    //     // userBalances[lock.owner] -= lock.amount;

    //     emit TokensUnlocked(lockId, lock.tokenAddress,msg.sender, lock.amount);
    // }

    /**
    * @dev Emergency Withdraw of locked tokens, deducting dynamic penalty fee
    * @param lockId The index of the lock to withdraw from
    */
    function withdrawTokens(uint256 lockId, uint256 amount) external onlyOwner nonReentrant whenNotPaused {
        require(lockId < locks.length, "Invalid lock ID");
        Lock storage lock = locks[lockId];

        require(lock.isActive, "Lock is not Active");
        require(amount > 0 && amount <= lock.amount, "Invalid Withdrawal amount");

         lock.amount -= amount;
        // require(block.timestamp >= lock.startTime, "Lock period not started");
        // require(block.timestamp < lock.endTime, "Lock period already ended");

        // uint256 penaltyAmount = (lock.amount * penaltyPercentage) / 100; // Dynamic penalty based on penaltyPercentage
        // uint256 returnAmount = lock.amount - penaltyAmount;

        IERC20Upgradeable(lock.tokenAddress).safeTransfer(msg.sender, amount);


       
        // Emit the TokensWithdraw event
        emit TokensWithdraw(lockId, lock.tokenAddress, msg.sender,amount);
    }

    /**
    * @dev Returns all locks for a specific user
    * @param user The address of the user
    * @return Array of Lock structs
    */
    function getUserLocks(address user) external view returns (Lock[] memory) {
        uint256[] memory indices = userLockIndices[user];
        Lock[] memory userLocks = new Lock[](indices.length);

        for (uint256 i = 0; i < indices.length; i++){
            userLocks[i] = locks[indices[i]];
        }
        return userLocks;
    }

    //Function to allow only the Owner to view all user locks
    function getAllUserLocks() external view onlyOwner returns(Lock[] memory){
        return locks;
    }

   

    /**
    * @dev Returns the number of locks for a specific user
    * @param user The address of the user
    */
    function getUserLockCount(address user) external view onlyOwner returns(uint256) {
        return userLockIndices[user].length;
    }

     //Function to allow the owner to view the balance of a user in a specific token
     function getUserTokenBalance(address token, address user) external view onlyOwner returns (uint256) {
        require(token != address(0), "Invalid token address");
        return IERC20Upgradeable(token).balanceOf(user);
    }

   
    /**
    * @dev Checks if a lock is still active
    * @param lockId The index of the lock
    * @return bool True if the lock is active, otherwise false
    */
    function isLockActive(uint256 lockId) external view onlyOwner returns(bool) {
        require(lockId < locks.length, "Invalid lock ID");
        return locks[lockId].isActive;
    }

     //Extend to extend Lock period, only Callable by the admin
    function extendLockPeriod(uint256 lockId, uint256 additionalTime) public onlyOwner {
        require(lockId < locks.length, "Invalid Lock ID");
        require(additionalTime > 0, "Additional Time must be greater than 0");

        Lock storage lock = locks[lockId];

        require(lock.endTime > block.timestamp, "Lock period has ended");

        //Extend the unlock Time
        lock.endTime += additionalTime;

        emit LockExtended(lockId, lock.endTime);
    }


   
}

