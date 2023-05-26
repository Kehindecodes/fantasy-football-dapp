// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @title User Contract
 * @dev A contract to manage user registration, login/logout, balance, points, and leaderboard functionality.
 */
contract User {
    struct UserData {
        address userAddress;
        string username;
        uint256 balance;
        bool isLoggedIn;
        uint256 totalPoints;
    }

    // uint256 private totalUsers;
    address[] private userAddresses;

    // Mapping to store user data based on their address
    mapping(address => UserData) private users;

    /**
     * @dev Event emitted when a new user is registered.
     * @param userAddress The address of the registered user.
     * @param username The username of the registered user.
     */
    event UserRegistered(address indexed userAddress, string username);

    /**
     * @dev Event emitted when a user logs in.
     * @param userAddress The address of the logged-in user.
     */
    event UserLoggedIn(address indexed userAddress);

    /**
     * @dev Event emitted when a user logs out.
     * @param userAddress The address of the logged-out user.
     */
    event UserLoggedOut(address indexed userAddress);

    /**
     * @dev Event emitted when a user's balance is updated.
     * @param userAddress The address of the user.
     * @param newBalance The updated balance of the user.
     */
    event BalanceUpdated(address indexed userAddress, uint256 newBalance);

    /**
     * @dev Event emitted when a user's total points are updated.
     * @param userAddress The address of the user.
     * @param totalPoints The updated total points of the user.
     */
    event UserPointsUpdated(address indexed userAddress, uint256 totalPoints);

    /**
     * @dev Registers a new user by setting their isLoggedIn status to false.
     * Emits a UserRegistered event.
     * @param _username The username of the new user.
     */
    function registerUser(string memory _username) public {
        require(
            users[msg.sender].userAddress == address(0),
            "User already registered"
        );
        users[msg.sender] = UserData(msg.sender, _username, 0, false, 0);
        userAddresses.push(msg.sender); // Add the user address to the array

        emit UserRegistered(msg.sender, _username);
    }

    /**
     * @dev Retrieves the user data for a given user address.
     * @param _userAddress The address of the user.
     * @return The user data (userAddress, username, balance, isLoggedIn, totalPoints).
     */
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
        require(!users[msg.sender].isLoggedIn, "User already logged in");
        users[msg.sender].isLoggedIn = true;

        emit UserLoggedIn(msg.sender);
    }

    /**
     * @dev Logs out a user by setting their isLoggedIn status to false.
     * Emits a UserLoggedOut event.
     */
    function logout() public {
        require(users[msg.sender].isLoggedIn, "User already logged out");
        users[msg.sender].isLoggedIn = false;

        emit UserLoggedOut(msg.sender);
    }

    /**
     * @dev Retrieves the isLoggedIn status of a user.
     * @param _userAddress The address of the user.
     * @return A boolean indicating whether the user is logged in.
     */
    function isLoggedIn(address _userAddress) public view returns (bool) {
        return users[_userAddress].isLoggedIn;
    }

    /**
     * @dev Updates the balance of a user.
     * Emits a BalanceUpdated event.
     * @param _newBalance The new balance of the user.
     */
    function updateBalance(uint256 _newBalance) public {
        users[msg.sender].balance = _newBalance;

        emit BalanceUpdated(msg.sender, _newBalance);
    }

    /**
     * @dev Retrieves the balance of a user.
     * @param _userAddress The address of the user.
     * @return The balance of the user.
     */
    function getBalance(address _userAddress) public view returns (uint256) {
        return users[_userAddress].balance;
    }

    /**
     * @dev Updates the total points of a user.
     * Emits a UserPointsUpdated event.
     * @param _points The points to be added to the user's total points.
     */
    function updatePoints(uint256 _points) public {
        UserData storage user = users[msg.sender];
        user.totalPoints += _points;

        emit UserPointsUpdated(msg.sender, user.totalPoints);
    }

    /**
     * @dev Retrieves the total points of a user.
     * @param _userAddress The address of the user.
     * @return The total points of the user.
     */
    function getUserPoints(address _userAddress) public view returns (uint256) {
        return users[_userAddress].totalPoints;
    }

    /**
     * @dev Retrieves the leaderboard, sorted in descending order based on total points.
     * @return An array of user addresses and an array of their corresponding total points.
     */
    function getLeaderBoard()
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256 totalUsers = getTotalUsers();
        address[] memory addresses = new address[](totalUsers);
        uint256[] memory points = new uint256[](totalUsers);

        for (uint256 i = 0; i < totalUsers; i++) {
            addresses[i] = getUserAddressAtIndex(i);
            points[i] = users[addresses[i]].totalPoints;
        }

        sortLeaderboard(addresses, points);
        return (addresses, points);
    }

    function getUserLeaderboardPosition(
        address _userAddress
    ) public view returns (uint256) {
        (address[] memory addresses, ) = getLeaderBoard();
        uint256 totalUsers = addresses.length;

        for (uint256 i = 0; i < totalUsers; i++) {
            if (addresses[i] == _userAddress) {
                return i + 1; // Positions are indexed from 1
            }
        }

        revert("User not found in leaderboard");
    }

    /**
     * @dev Retrieves the total number of registered users.
     * @return The total number of registered users.
     */
    function getTotalUsers() private view returns (uint256) {
        return userAddresses.length;
    }

    /**
     * @dev Retrieves the user address at the specified index in the userAddresses array.
     * @param index The index of the user address.
     * @return The user address at the specified index.
     */
    function getUserAddressAtIndex(
        uint256 index
    ) private view returns (address) {
        require(index < userAddresses.length, "Invalid index");
        return userAddresses[index];
    }

    /**
     * @dev Sorts the leaderboard in descending order based on total points using bubble sort algorithm.
     * @param addresses The array of user addresses.
     * @param points The array of total points.
     */
    function sortLeaderboard(
        address[] memory addresses,
        uint256[] memory points
    ) private pure {
        uint256 n = points.length;
        for (uint256 i = 0; i < n - 1; i++) {
            for (uint256 j = 0; j < n - i - 1; j++) {
                if (points[j] < points[j + 1]) {
                    // Swap addresses
                    (addresses[j], addresses[j + 1]) = (
                        addresses[j + 1],
                        addresses[j]
                    );
                    // Swap points
                    (points[j], points[j + 1]) = (points[j + 1], points[j]);
                }
            }
        }
    }
}
