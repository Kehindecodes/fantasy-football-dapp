// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./PlayerContract.sol"; // Import the contract that defines the Player struct

/**
 * @dev Contract for managing team creation and player transfers.
 */
contract TeamCreation {
    struct Team {
        address owner;
        uint256 teamBudget;
        uint256[] players;
        uint256[] starting11;
        string teamName;
    }

    mapping(uint256 => Team) public teams;
    uint256 public teamCount;
    mapping(address => uint256) public userTeams;

    uint256 public constant MAX_PLAYERS = 15;
    uint256 public constant STARTING_11_COUNT = 11;
    // uint256 public constant SUBSTITUTES_COUNT = 4;
    uint256 public constant TEAM_BUDGET = 100000000; // 100M

    PlayerContract public playerContract; // Instance of the PlayerContract
    event PlayerUpdated(uint256, uint256);

    // modifier isTeamCreationAllowed() {
    //     // Add logic to check if team creation or updates are allowed based on the game week
    //     require(
    //         /* Add your condition here */ "Team creation/update not allowed at this time"
    //     );
    //     _;
    // }

    /**
     * @dev Constructor function to initialize the TeamCreation contract.
     * @param _playerContractAddress The address of the PlayerContract.
     */
    constructor(address _playerContractAddress) {
        playerContract = PlayerContract(_playerContractAddress); // Initialize the PlayerContract instance
    }

    /**
     * @dev Creates a new team with a given team name.
     * @param _teamName The name of the team.
     */
    function createTeam(string memory _teamName) public {
        require(userTeams[msg.sender] == 0, "User can only create one team");

        // Create a new team
        teamCount++;
        Team storage newTeam = teams[teamCount];
        newTeam.owner = msg.sender;
        newTeam.teamBudget = TEAM_BUDGET;
        newTeam.teamName = _teamName;

        // Assign the team ID to the user
        userTeams[msg.sender] = teamCount;
    }

    /**
     * @dev Adds a player to the team.
     * @param _playerId The id of the player to add.
     */
    function addPlayer(uint256 _playerId) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");
        require(
            teams[userTeams[msg.sender]].players.length < MAX_PLAYERS,
            "Team already has the maximum number of players"
        );
        // get player with the id from the player Contract
        PlayerContract.Player memory player = playerContract.getPlayer(
            _playerId
        );

        // Get the player's position from the PlayerContract
        PlayerContract.PlayerPosition playerPosition = playerContract
            .getPlayerPosition(_playerId);

        // Ensure the team has enough budget to add the player
        require(
            teams[userTeams[msg.sender]].teamBudget >=
                playerContract.getPlayerPrice(_playerId),
            "Insufficient team budget"
        );

        // Validate position restrictions
        validatePositionRestrictions(userTeams[msg.sender], playerPosition);

        // Deduct the player's price from the team budget
        teams[userTeams[msg.sender]].teamBudget -= playerContract
            .getPlayerPrice(_playerId);

        // Add the player to the team
        teams[userTeams[msg.sender]].players.push(player);
    }

    /**
     * @dev Removes a player from the team.
     * @param _playerId The ID of the player to remove.
     */
    function removePlayer(uint256 _playerId) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");

        Team storage team = teams[userTeams[msg.sender]];
        uint256[] storage players = team.players;

        // Find the player index in the team
        uint256 playerIndex = findPlayerIndex(players, _playerId);

        // Ensure the player is found in the team
        require(playerIndex != 2 ** 256 - 1, "Player not found in the team");

        // Remove the player from the team
        players[playerIndex] = players[players.length - 1];
        players.pop();
    }

    /**
     * @dev Transfers a player from the sender's team to the recipient's team.
     * @param _to The address of the recipient.
     * @param _playerId The Id of the player to transfer.
     */
    function transferPlayer(address _to, uint256 _playerId) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");
        require(userTeams[_to] != 0, "Recipient must have a team");

        Team storage senderTeam = teams[userTeams[msg.sender]];
        Team storage recipientTeam = teams[userTeams[_to]];

        // Ensure the player exists in the sender's team
        require(
            playerExists(senderTeam.players, _playerId),
            "Player not found in the sender's team"
        );

        // Get the player's price from the PlayerContract
        uint256 playerPrice = playerContract.getPlayerPrice(_playerId);

        // Deduct the player's price from the sender's team budget
        senderTeam.teamBudget -= playerPrice;

        // Add the player to the recipient's team
        recipientTeam.players.push(_playerId);
    }

    /**
     * @dev Sets the team name for the sender's team.
     * @param _teamName The new team name.
     */
    function setTeamName(string memory _teamName) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");

        teams[userTeams[msg.sender]].teamName = _teamName;
    }

    /**
     * @dev Updates the player in the sender's team with a new player.
     * @param _playerId The ID of the existing player.
     * @param _newPlayerId The ID of the new player.
     */
    function updateTeam(uint256 _playerId, uint256 _newPlayerId) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");

        Team storage team = teams[userTeams[msg.sender]];

        // Ensure the existing player exists in the team
        require(
            playerExists(team.players, _playerId),
            "Existing player not found in the team"
        );

        // Ensure the new player exists
        require(
            playerExists(teams[userTeams[msg.sender]].players, _newPlayerId),
            "New player not found"
        );

        // Update the player in the team with the new player
        for (uint256 i = 0; i < team.players.length; i++) {
            if (team.players[i] == _playerId) {
                team.players[i] = _newPlayerId;
                break;
            }
        }

        // Emit an event or perform any other necessary actions
        emit PlayerUpdated(_playerId, _newPlayerId);
    }

    /**
     * @dev Sets the starting 11 players for the team.
     * @param _playerIds The IDs of the starting 11 players.
     */
    function setStarting11(uint256[] memory _playerIds) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");
        require(
            _playerIds.length == STARTING_11_COUNT,
            "Invalid number of players for starting 11"
        );

        Team storage team = teams[userTeams[msg.sender]];

        // Ensure all players exist in the team
        for (uint256 i = 0; i < _playerIds.length; i++) {
            require(
                playerExists(team.players, _playerIds[i]),
                "Player not found in the team"
            );
        }

        // Set the starting 11 players for the team
        team.starting11 = _playerIds;
    }

    /**
     * @dev Validates the position restrictions when adding a player to the team.
     * @param _teamId The ID of the team.
     * @param _playerPosition The position of the player.
     */
    function validatePositionRestrictions(
        uint256 _teamId,
        PlayerContract.PlayerPosition _playerPosition
    ) private view {
        Team storage team = teams[_teamId];

        // Count the number of players in each position
        uint256 numStrikers = 0;
        uint256 numMidfieldersForwards = 0;
        uint256 numDefenders = 0;
        uint256 numGoalkeepers = 0;

        for (uint256 i = 0; i < team.players.length; i++) {
            PlayerContract.PlayerPosition position = playerContract
                .getPlayerPosition(team.players[i]);

            if (position == PlayerContract.PlayerPosition.Striker) {
                numStrikers++;
            } else if (position == PlayerContract.PlayerPosition.Midfielder) {
                numMidfieldersForwards++;
            } else if (position == PlayerContract.PlayerPosition.Defender) {
                numDefenders++;
            } else if (position == PlayerContract.PlayerPosition.Goalkeeper) {
                numGoalkeepers++;
            }
        }

        // Check position restrictions
        if (_playerPosition == PlayerContract.PlayerPosition.Striker) {
            require(numStrikers < 3, "Exceeded maximum number of strikers");
        } else if (
            _playerPosition == PlayerContract.PlayerPosition.Midfielder
        ) {
            require(
                numMidfieldersForwards < 5,
                "Exceeded maximum number of midfielders/forwards"
            );
        } else if (_playerPosition == PlayerContract.PlayerPosition.Defender) {
            require(numDefenders < 5, "Exceeded maximum number of defenders");
        } else if (
            _playerPosition == PlayerContract.PlayerPosition.Goalkeeper
        ) {
            require(
                numGoalkeepers < 2,
                "Exceeded maximum number of goalkeepers"
            );
        }
    }

    /**
     * @dev Finds the index of a player in the given array of players.
     * @param _players The array of player IDs.
     * @param _playerId The ID of the player to find.
     * @return The index of the player in the array or -1 if not found.
     */
    function findPlayerIndex(
        uint256[] memory _players,
        uint256 _playerId
    ) internal pure returns (uint256) {
        for (uint256 i = 0; i < _players.length; i++) {
            if (_players[i] == _playerId) {
                return i;
            }
        }
        return 2 ** 256 - 1;
    }

    /**
     * @dev Checks if a player exists in the given array of players.
     * @param _players The array of player IDs.
     * @param _playerId The ID of the player to check.
     * @return A boolean indicating whether the player exists in the array or not.
     */
    function playerExists(
        uint256[] memory _players,
        uint256 _playerId
    ) internal pure returns (bool) {
        return findPlayerIndex(_players, _playerId) != 2 ** 256 - 1;
    }
}
