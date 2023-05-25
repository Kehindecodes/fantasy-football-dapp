// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract User {
    struct UserData {
        address userAddress;
        string username;
        uint256 balance;
        bool isLoggedIn;
    }

    // Mapping to store user data based on their address
    mapping(address => UserData) private users;

    // Event emitted when a new user is registered
    event UserRegistered(address indexed userAddress, string username);

    // Event emitted when a user logs in
    event UserLoggedIn(address indexed userAddress);

    // Event emitted when a user logs out
    event UserLoggedOut(address indexed userAddress);

    event BalanceUpdated(address indexed userAddress, uint256 newBalance);

    /**
     * @dev Registers a new user by setting their isLoggedIn status to false.
     * Emits a UserRegistered event.
     */
    function registerUser(
        string memory _username,
        address _userAddress
    ) public {
        require(
            users[_userAddress].userAddress == address(0),
            "User already registered"
        );
        users[_userAddress] = UserData(_userAddress, _username, 0, false);

        emit UserRegistered(_userAddress, _username);
    }

    function getUser(
        address _userAddress
    ) public view returns (UserData memory) {
        return users[_userAddress];
    }

    /**
     * @dev Logs in a user by setting their isLoggedIn status to true.
     * Emits a UserLoggedIn event.
     */
    function login() public {
        // Check if the user is already logged in
        require(!users[msg.sender].isLoggedIn, "User already logged in");
        // Set the isLoggedIn status to true for the user
        users[msg.sender].isLoggedIn = true;

        // Emit the UserLoggedIn event
        emit UserLoggedIn(msg.sender);
    }

    /**
     * @dev Logs out a user by setting their isLoggedIn status to false.
     * Emits a UserLoggedOut event.
     */
    function logout() public {
        // Check if the user is already logged out
        require(users[msg.sender].isLoggedIn, "User already logged out");

        // Set the isLoggedIn status to false for the user
        users[msg.sender].isLoggedIn = false;

        // Emit the UserLoggedOut event
        emit UserLoggedOut(msg.sender);
    }

    /**
     * @dev Retrieves the isLoggedIn status of a user.
     * @param _userAddress The address of the user.
     * @return A boolean indicating whether the user is logged in.
     */
    function isLoggedIn(address _userAddress) public view returns (bool) {
        // Return the isLoggedIn status of the user
        return users[_userAddress].isLoggedIn;
    }

    function updateBalance(uint256 _newBalance) public {
        users[msg.sender].balance = _newBalance;
        emit BalanceUpdated(msg.sender, _newBalance);
    }

    function getBalance(address _userAddress) public view returns (uint256) {
        return users[_userAddress].balance;
    }
}
