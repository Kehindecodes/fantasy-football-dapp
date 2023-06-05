// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PlayerContract.sol"; // Import the contract that defines the Player struct

contract TeamCreation {
    struct Team {
        address owner;
        uint256 teamBudget;
        uint256[] players;
        string teamName;
        // string leagueType;
    }

    mapping(uint256 => Team) public teams;
    uint256 public teamCount;
    mapping(address => uint256) public userTeams;

    uint256 public constant MAX_PLAYERS = 11;
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
        // require(userTeams[msg.sender] == 0, "User can only create one team");

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
            "Team already has maximum number of players"
        );

        // Get the player's price from the PlayerContract
        uint256 playerPrice = playerContract.getPlayerPrice(_playerName);

        // Ensure the team has enough budget to add the player
        require(
            teams[userTeams[msg.sender]].teamBudget >= playerPrice,
            "Insufficient team budget"
        );

        // Deduct the player's price from the team budget
        teams[userTeams[msg.sender]].teamBudget -= playerPrice;

        // Add the player to the team
        teams[userTeams[msg.sender]].players.push(_playerId);
    }

    function removePlayer(uint256 _playerId) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");

        Team storage team = teams[userTeams[msg.sender]];
        uint256[] storage players = team.players;

        // Find the player index in the team
        uint256 playerIndex = findPlayerIndex(players, _playerName);
        require(playerIndex != players.length, "Player not found in the team");

        // Get the player's price from the PlayerContract
        uint256 playerPrice = playerContract.getPlayerPrice(_playerName);

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

    function setTeamName(string memory _teamName) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");

        teams[userTeams[msg.sender]].teamName = _teamName;
    }

    function updatePlayer(uint256 _playerId, uint256 _newPlayerId) public {
        require(userTeams[msg.sender] != 0, "User must create a team first");

        Team storage team = teams[userTeams[msg.sender]];

        // Ensure the existing player exists in the team
        require(
            playerExists(team.players, _playerId),
            "Existing player not found in the team"
        );

        // Ensure the new player exists
        require(playerExists(allPlayers, _newPlayerId), "New player not found");

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
}
