// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract TheOpenSimulation {


    // All relevant information regarding a global state of a player.
    struct Feeling {
        // pos - the Position of the player.
        // rot - the Rotation of the player.
        // sca - the Scale of the player.
        uint256[3] pos;
        uint256[3] rot;
        uint256[3] sca;
        // wish categories
        // ambition
        // art
        // hazards
        // logic
        // pets
        // social
        // sports
        // supernatural
    }
    // All relevant information regarding a global state of a player.
    struct State {
        // pos - the Position of the player.
        // rot - the Rotation of the player.
        // sca - the Scale of the player.
        uint256[3] pos;
        uint256[3] rot;
        uint256[3] sca;
    }

    // All relevant information regarding a wish
    struct Wish {
        // id
        // wishCat - the Category of the wish.
        // title - the title of the wish.
        // birthunix - the UNIX timestamp when the first wish ocurred.

        uint8 id;
        uint8 wishCat;
        string title;
        uint256 birthunix;
    }

    // All relevant information regarding a memory
    struct Memori {
        // id
        // memCat - the Category of the memory.
        // title - the title of the memory.
        // birthunix - the UNIX timestamp when the first memory ocurred.

        uint8 id;
        uint8 memCat;
        string title;
        uint256 birthunix;
    }

    // All relevant information regarding a player
    struct Player {
        // URI - the player's name.
        // name - the player's name.
        // playerdeadline - the UNIX timestamp when the player is expected to die.
        // memories - the list of Memori items of a players life.
        // globalState - the position, rotation and scale of a player.
        // graduated - whether or not this player has achieved its life goal. Cannot be true before the playerdeadline has been reached.
        // ref - the player address that invited the next player.

        string URI;
        string name;
        uint256 birthunix;
        uint256 playerdeadline;
        mapping(uint8 => Memori) memories;
        State globalState;
        Feeling status;
        Feeling satisfaction;
        bool graduated;
        address ref;
    }

    // Keep track of players by their address
    mapping(address => Player) public players;

    // Only allows to be called by
    modifier registeredOnly(address _ref) {
        require(players[_ref].birthunix != 0, "UNREGISTERED_PLAYER");
        _;
    }
    modifier unregisteredOnly(address _ref) {
        require(players[_ref].birthunix == 0, "REGISTERED_PLAYER");
        _;
    }
    modifier alivePlayerOnly(address _ref) {
        require(players[_ref].birthunix != 0 && block.timestamp < players[_ref].playerdeadline, "DEAD_PLAYER");
        _;
    }

    constructor () {
        Player storage player = players[address(0)];
        player.ref = msg.sender;
        
        player.birthunix = block.timestamp;
        player.playerdeadline = block.timestamp + 42 days;
    }

    function createPlayer(address _ref) external unregisteredOnly(msg.sender) alivePlayerOnly(_ref)
    {
        Player storage player = players[msg.sender];
        if (_ref != msg.sender) {
            player.ref = _ref;
        }
        
        player.birthunix = block.timestamp;
        player.playerdeadline = block.timestamp + 21 days;
    }

    function setPosition(uint256 _X, uint256 _Y, uint256 _Z) public registeredOnly(msg.sender)
    {
        Player storage player = players[msg.sender];
        player.globalState.pos[0] = _X;
        player.globalState.pos[1] = _Y;
        player.globalState.pos[2] = _Z;
    }

    function setRotation(uint256 _X, uint256 _Y, uint256 _Z) public registeredOnly(msg.sender)
    {
        Player storage player = players[msg.sender];
        player.globalState.rot[0] = _X;
        player.globalState.rot[1] = _Y;
        player.globalState.rot[2] = _Z;
    }

    function setScale(uint256 _X, uint256 _Y, uint256 _Z, address _player) internal registeredOnly(_player)
    {
        Player storage player = players[msg.sender];
        player.globalState.sca[0] = _X;
        player.globalState.sca[1] = _Y;
        player.globalState.sca[2] = _Z;
    }
}