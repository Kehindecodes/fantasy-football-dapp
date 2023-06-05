// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PlayerContract.sol"; // Import the contract that defines the Player struct

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

    modifier isTeamCreationAllowed() {
        // Add logic to check if team creation or updates are allowed based on the game week
        require(
            /* Add your condition here */ "Team creation/update not allowed at this time"
        );
        _;
    }

    constructor(address _playerContractAddress) {
        playerContract = PlayerContract(_playerContractAddress); // Initialize the PlayerContract instance
    }

    function createTeam(string memory _teamName) public isTeamCreationAllowed {
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

    function addPlayer(uint256 _playerName) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");
        require(
            teams[userTeams[msg.sender]].players.length < MAX_PLAYERS,
            "Team already has the maximum number of players"
        );

        // Get the player's position from the PlayerContract
        PlayerPosition playerPosition = playerContract.getPlayerPosition(
            _playerName
        );

        // Ensure the team has enough budget to add the player
        require(
            teams[userTeams[msg.sender]].teamBudget >=
                playerContract.getPlayerPrice(_playerName),
            "Insufficient team budget"
        );

        // Validate position restrictions
        validatePositionRestrictions(userTeams[msg.sender], playerPosition);

        // Deduct the player's price from the team budget
        teams[userTeams[msg.sender]].teamBudget -= playerContract
            .getPlayerPrice(_playerName);

        // Add the player to the team
        teams[userTeams[msg.sender]].players.push(_playerId);
    }

    function removePlayer(uint256 _playerId) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");

        Team storage team = teams[userTeams[msg.sender]];
        uint256[] storage players = team.players;

        // Find the player index in the team
        uint256 playerIndex = findPlayerIndex(players, _playerId);
        require(playerIndex != players.length, "Player not found in the team");

        // Get the player's price from the PlayerContract
        uint256 playerPrice = playerContract.getPlayerPrice(_playerId);

        // Remove the player from the team
        players[playerIndex] = players[players.length - 1];
        players.pop();

        // Refund the player's price to the team budget
        team.teamBudget += playerPrice;
    }

    function transferPlayer(address _to, uint256 _playerName) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");
        require(userTeams[_to] != 0, "Recipient must have a team");

        Team storage senderTeam = teams[userTeams[msg.sender]];
        Team storage recipientTeam = teams[userTeams[_to]];

        // Ensure the player exists in the sender's team
        require(
            playerExists(senderTeam.players, _playerName),
            "Player not found in the sender's team"
        );

        // Get the player's price from the PlayerContract
        uint256 playerPrice = playerContract.getPlayerPrice(_playerName);

        // Deduct the player's price from the sender's team budget
        senderTeam.teamBudget -= playerPrice;

        // Add the player to the recipient's team
        recipientTeam.players.push(_playerName);
    }

    function setTeamName(string memory _teamName) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");

        teams[userTeams[msg.sender]].teamName = _teamName;
    }

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

    function setStarting11(uint256[] memory _playerIds) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");
        require(
            _playerIds.length == STARTING_11_COUNT,
            "Invalid number of players for the starting 11"
        );

        Team storage team = teams[userTeams[msg.sender]];
        uint256[] storage players = team.players;

        // Ensure all players exist in the team
        for (uint256 i = 0; i < _playerIds.length; i++) {
            require(
                playerExists(players, _playerIds[i]),
                "Player not found in the team"
            );
        }

        // Set the starting 11 players
        team.starting11 = _playerIds;
    }

    function makeSubstitution(
        uint256 _playerToReplace,
        uint256 _newPlayer
    ) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");

        Team storage team = teams[userTeams[msg.sender]];
        uint256[] storage players = team.players;

        // Ensure both players exist in the team
        require(
            playerExists(players, _playerToReplace) &&
                playerExists(players, _newPlayer),
            "Player(s) not found in the team"
        );

        // Ensure the player to replace is in the starting 11
        require(
            isPlayerInStarting11(team.starting11, _playerToReplace),
            "Player to replace is not in the starting 11"
        );

        // Replace the player in the starting 11
        for (uint256 i = 0; i < team.starting11.length; i++) {
            if (team.starting11[i] == _playerToReplace) {
                team.starting11[i] = _newPlayer;
                break;
            }
        }
    }

    function findPlayerIndex(
        uint256[] storage _players,
        uint256 _playerId
    ) private view returns (uint256) {
        for (uint256 i = 0; i < _players.length; i++) {
            if (_players[i] == _playerId) {
                return i;
            }
        }
        return _players.length; // Player not found
    }

    function playerExists(
        uint256[] storage _players,
        uint256 _playerId
    ) private view returns (bool) {
        for (uint256 i = 0; i < _players.length; i++) {
            if (_players[i] == _playerId) {
                return true;
            }
        }
        return false;
    }

    function isPlayerInStarting11(
        uint256[] storage _starting11,
        uint256 _playerId
    ) private view returns (bool) {
        for (uint256 i = 0; i < _starting11.length; i++) {
            if (_starting11[i] == _playerId) {
                return true;
            }
        }
        return false;
    }

    function validatePositionRestrictions(
        uint256 _teamId,
        PlayerPosition _playerPosition
    ) private view {
        Team storage team = teams[_teamId];

        // Count the number of players in each position
        uint256 numStrikers = 0;
        uint256 numMidfieldersForwards = 0;
        uint256 numDefenders = 0;
        uint256 numGoalkeepers = 0;

        for (uint256 i = 0; i < team.players.length; i++) {
            PlayerPosition position = playerContract.getPlayerPosition(
                team.players[i]
            );
            if (position == PlayerPosition.Striker) {
                numStrikers++;
            } else if (
                position == PlayerPosition.Midfielder ||
                position == PlayerPosition.Forward
            ) {
                numMidfieldersForwards++;
            } else if (position == PlayerPosition.Defender) {
                numDefenders++;
            } else if (position == PlayerPosition.Goalkeeper) {
                numGoalkeepers++;
            }
        }

        // Check position restrictions
        if (_playerPosition == PlayerPosition.Striker) {
            require(numStrikers < 3, "Exceeded maximum number of strikers");
        } else if (
            _playerPosition == PlayerPosition.Midfielder ||
            _playerPosition == PlayerPosition.Forward
        ) {
            require(
                numMidfieldersForwards < 5,
                "Exceeded maximum number of midfielders/forwards"
            );
        } else if (_playerPosition == PlayerPosition.Defender) {
            require(numDefenders < 5, "Exceeded maximum number of defenders");
        } else if (_playerPosition == PlayerPosition.Goalkeeper) {
            require(
                numGoalkeepers < 2,
                "Exceeded maximum number of goalkeepers"
            );
        }
    }
}
