// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title TimeLockedVault
/// @notice Multi-role vault with time-locked withdrawals and admin controls
contract TimeLockedVault {
    /// @notice Defines user roles in the contract
    enum Role { 
        None, // Default role
        User, // Regular user allowed to deposit and withdraw
        Admin // Admin can assign roles
    }

    /// @notice Deposit structure containing amount and unlock timestamp
    struct Deposit {
        uint256 amount;           // Amount of ETH deposited
        uint256 unlockTimestamp;  // Time when funds become withdrawable
    }

    /// @notice Address of the contract owner
    address public owner;

    /// @notice Mapping from address to assigned role
    mapping(address => Role) public roles;

    /// @notice Mapping from address to array of deposits
    mapping(address => Deposit[]) public deposits;

    /// @notice Emitted when a new deposit is created
    event DepositCreated(address indexed user, uint256 amount, uint256 unlockTime);

    /// @notice Emitted when a withdrawal is performed
    event Withdrawal(address indexed user, uint256 amount);

    /// @notice Emitted when a role is assigned or changed
    event RoleChanged(address indexed user, Role newRole);

    /// @notice Restricts function to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @notice Restricts function to accounts with Admin role
    modifier onlyAdmin() {
        require(roles[msg.sender] == Role.Admin, "Not admin");
        _;
    }

    /// @notice Restricts function to accounts with User role
    modifier onlyUser() {
        require(roles[msg.sender] == Role.User, "Not user");
        _;
    }

    /// @notice Constructor sets the deployer as Owner and Admin
    constructor() {
        owner = msg.sender;
        roles[msg.sender] = Role.Admin;
    }

    /// @notice Assigns a role to a user address
    /// @param _user The address to assign the role to
    /// @param _role The Role enum value to assign
    function setRole(address _user, Role _role) external onlyAdmin {
        require(_user != address(0), "Zero address");
        roles[_user] = _role;
        emit RoleChanged(_user, _role);
    }

    /// @notice Allows a user to deposit ETH with a time lock
    /// @param _lockSeconds Number of seconds the deposit will be locked
    function deposit(uint256 _lockSeconds) external payable onlyUser {
        require(msg.value > 0, "Zero amount");
        uint256 unlockTime = block.timestamp + _lockSeconds;

        // Store deposit information
        deposits[msg.sender].push(Deposit({
            amount: msg.value,
            unlockTimestamp: unlockTime
        }));

        emit DepositCreated(msg.sender, msg.value, unlockTime);
    }

    /// @notice Allows a user to withdraw a specific deposit after it is unlocked
    /// @param _index Index of the deposit in the user's deposits array
    function withdraw(uint256 _index) external onlyUser {
        // Load deposit reference
        Deposit storage userDeposit = deposits[msg.sender][_index];

        require(block.timestamp >= userDeposit.unlockTimestamp, "Still locked");
        uint256 amount = userDeposit.amount;
        require(amount > 0, "Already withdrawn");

        // Set deposit amount to zero to prevent re-entrancy
        userDeposit.amount = 0;

        // Transfer ETH to the user
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Transfer failed");

        emit Withdrawal(msg.sender, amount);
    }

    /// @notice Returns all deposits for a given user address
    /// @param _user The address to query deposits for
    /// @return Array of Deposit structs
    function getDeposits(address _user) external view returns (Deposit[] memory) {
        return deposits[_user];
    }
}
