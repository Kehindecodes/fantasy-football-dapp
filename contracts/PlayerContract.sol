// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract PlayerContract {
    enum PlayerPosition {
        Striker,
        Midfielder,
        Defender,
        Goalkeeper
    }

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

    Player[] public players;
    mapping(uint256 => mapping(uint256 => uint256)) public gameWeekPoints;

    event PlayerAdded(
        uint256 playerId,
        string playerName,
        uint256 playerPrice,
        PlayerPosition position
    );

    event GameWeekPointsSet(uint256 playerId, uint256 gameWeek, uint256 points);

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

    function setGameWeekPoints(
        uint256 _playerId,
        uint256 _gameWeek,
        uint256 _points
    ) public {
        require(_playerId < players.length, "Invalid player ID");

        gameWeekPoints[_playerId][_gameWeek] = _points;
        emit GameWeekPointsSet(_playerId, _gameWeek, _points);
    }

    function getGameWeekPoints(
        uint256 _playerId,
        uint256 _gameWeek
    ) public view returns (uint256) {
        require(_playerId < players.length, "Invalid player ID");

        return gameWeekPoints[_playerId][_gameWeek];
    }

    function getPlayerPrice(uint256 _playerId) public view returns (uint256) {
        return players[_playerId].playerPrice;
    }

    function getPlayerPosition(
        uint256 _playerId
    ) public view returns (PlayerPosition) {
        return players[_playerId].position;
    }
}
