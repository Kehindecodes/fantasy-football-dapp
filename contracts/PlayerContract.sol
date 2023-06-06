// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// This contract defines the PlayerContract, which manages player information and game week points.

contract PlayerContract {
    // Enum to represent player positions
    enum PlayerPosition {
        Striker,
        Midfielder,
        Defender,
        Goalkeeper
    }

    // Struct to represent a player
    struct Player {
        uint256 playerId;
        string playerName;
        uint256 playerPrice;
        PlayerPosition position;
        uint256 goals;
        uint256 assists;
        uint256 cleanSheets;
        uint256 redCards;
        uint256 yellowCards;
        uint256 goalsConceded;
        uint256 saves;
        uint256 overallPoints;
    }

    // Array to store all players
    Player[] public players;

    // Mapping to store game week points for each player
    mapping(uint256 => mapping(uint256 => uint256)) public gameWeekPoints;

    // Event emitted when a new player is added
    event PlayerAdded(
        uint256 playerId,
        string playerName,
        uint256 playerPrice,
        PlayerPosition position
    );

    // Event emitted when game week points are set for a player
    event GameWeekPointsSet(uint256 playerId, uint256 gameWeek, uint256 points);

    /**
     * @dev Adds a new player to the contract.
     * @param _playerName The name of the player.
     * @param _playerPrice The price of the player.
     * @param _position The position of the player.
     */
    function addPlayer(
        string memory _playerName,
        uint256 _playerPrice,
        PlayerPosition _position
    ) public {
        uint256 playerId = players.length;
        players.push(
            Player({
                playerId: playerId,
                playerName: _playerName,
                playerPrice: _playerPrice,
                position: _position,
                goals: 0,
                assists: 0,
                cleanSheets: 0,
                redCards: 0,
                yellowCards: 0,
                goalsConceded: 0,
                saves: 0,
                overallPoints: 0
            })
        );
        emit PlayerAdded(playerId, _playerName, _playerPrice, _position);
    }

    /**
     * @dev Sets the game week points for a player.
     * @param _playerId The ID of the player.
     * @param _gameWeek The game week number.
     * @param _points The points earned by the player in the game week.
     */
    function setGameWeekPoints(
        uint256 _playerId,
        uint256 _gameWeek,
        uint256 _points
    ) public {
        require(_playerId < players.length, "Invalid player ID");

        gameWeekPoints[_playerId][_gameWeek] = _points;
        emit GameWeekPointsSet(_playerId, _gameWeek, _points);
    }

    /**
     * @dev Gets the game week points for a player.
     * @param _playerId The ID of the player.
     * @param _gameWeek The game week number.
     * @return The points earned by the player in the game week.
     */
    function getGameWeekPoints(
        uint256 _playerId,
        uint256 _gameWeek
    ) public view returns (uint256) {
        require(_playerId < players.length, "Invalid player ID");

        return gameWeekPoints[_playerId][_gameWeek];
    }

    /**
     * @dev Gets the price of a player.
     * @param _playerId The ID of the player.
     * @return The price of the player.
     */
    function getPlayerPrice(uint256 _playerId) public view returns (uint256) {
        return players[_playerId].playerPrice;
    }

    /**
     * @dev Gets the position of a player.
     * @param _playerId The ID of the player.
     * @return The position of the player.
     */
    function getPlayerPosition(
        uint256 _playerId
    ) public view returns (PlayerPosition) {
        return players[_playerId].position;
    }
}
