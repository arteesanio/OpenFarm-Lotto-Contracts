// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// entities = variables
// entities = functions
// entities = names
// entities in UPPER_CASE are constants
// entities prefixed with "_" are auto generated
// entities prefixed with "__" are internal

import "hardhat/console.sol";

contract TheOpenSimulation {

    enum _ThoughtCategory { supernatural, ambition, art, hazards, logic, pets, social, sports }
    struct Thought {
        uint256 collectiveIndex;
        uint256 id;
        string title;
        uint256 birthunix;
        _ThoughtCategory cat;
    }

    // All relevant information regarding ethereal stats of a player.
    struct Status {
        // pos - the etheral status of a player.
        uint8[2] _focus; uint8[2] _process; uint8[2] _action;
    }

    // All relevant information regarding a memori
    struct Memori {
        // id
        // memCat - the Category of the memori.
        // title - the title of the memori.
        // birthunix - the UNIX timestamp when the first memori ocurred.

        uint256 id;
        string title;
        uint256 birthunix;
        _ThoughtCategory thoughtCat;
        uint256 thoughtIndex;
        bool isWish;
    }

    // All relevant information regarding global stats of a player.
    struct State {
        // fun, energy, hygene, protein
        // fun fixes boredom
        // rest fixes energy
        // shower fixes hygene
        // food fixes protein
        uint8 fun; uint8 energy; uint8 hygene; uint8 protein;
        
        // pos, rot, sca - the Position, Rotation and Scale of a player.
        uint256[3] pos; uint256[3] rot; uint256[3] sca;
    }

    // All relevant information regarding a player
    struct Player {
        // URI - a player's name.
        // name - a player's name.
        // deadline - the UNIX timestamp when a player is expected to die.
        // memories - the list of Memori items of a players life.
        // globalState - the position, rotation and scale of a player.
        // graduated - whether or not this player has achieved its life goal. Cannot be true before the deadline has been reached.
        // ref - a player address that invited the next player.

        string URI;
        string name;
        uint256 birthunix;
        uint256 deadline;
        Memori[] memories;
        State globalState;
        Status status;
        uint256 lastSave;
        bool graduated;
        address ref;
    }



    mapping(uint => Thought[]) public thoughts;
    uint public collectiveThoughtIndex;

    // Keep track of players by their address
    mapping(address => Player) public players;



    // Only allows to be called by registered addresses
    modifier registeredOnly(address _player) {
        require(players[_player].birthunix != 0, "UNREGISTERED_PLAYER");
        _;
    }
    // Only allows to be called by unregistered addresses
    modifier unregisteredOnly(address _player) {
        require(players[_player].birthunix == 0, "REGISTERED_PLAYER");
        _;
    }
    // Only allows to be called by registered and alive addresses
    modifier alivePlayerOnly(address _player) {
        require(_player != address(0), "INVALID_PLAYER");
        require(address(this) == _player || (players[_player].birthunix != 0 && block.timestamp < players[_player].deadline), "DEAD_PLAYER");
        _;
    }
    // Only allows to be called by registered and graduated addresses
    modifier graduatedPlayerOnly(address _player) {
        require(players[_player].graduated == true, "STUDENT_PLAYER");
        _;
    }


    constructor () {
        Player storage player = players[address(this)];
        player.ref = msg.sender;
        
        player.birthunix = block.timestamp;
        player.deadline = block.timestamp + 42 days;

        __addThought(Thought(0, 0, "Supernatural Memory", block.timestamp, _ThoughtCategory.supernatural));
        __addThought(Thought(0, 0, "Ambition Memory", block.timestamp, _ThoughtCategory.ambition));
        __addThought(Thought(0, 0, "Art Memory", block.timestamp, _ThoughtCategory.art));
        __addThought(Thought(0, 0, "Hazards Memory", block.timestamp, _ThoughtCategory.hazards));
        __addThought(Thought(0, 0, "Logic Memory", block.timestamp, _ThoughtCategory.logic));
        __addThought(Thought(0, 0, "Pets Memory", block.timestamp, _ThoughtCategory.pets));
        __addThought(Thought(0, 0, "Social Memory", block.timestamp, _ThoughtCategory.social));
        __addThought(Thought(0, 0, "Sports Memory", block.timestamp, _ThoughtCategory.sports));
    }

    function __addThought(Thought memory _thot) internal {
        collectiveThoughtIndex++;
        thoughts[uint(_thot.cat)].push(Thought(collectiveThoughtIndex, thoughts[uint(_thot.cat)].length, _thot.title, _thot.birthunix, _thot.cat));
    }

    function __addPlayerMemory(address _player, _ThoughtCategory _thotCat, uint256 _thotIndex) internal
    {
        Player storage player = players[_player];
        player.memories.push(Memori(
            player.memories.length,
            thoughts[uint(_thotCat)][_thotIndex].title,
            block.timestamp,
            _thotCat,
            _thotIndex,
            false // isWish?
        ));
    }

    function addPlayerEnergy(uint8 _amount) public alivePlayerOnly(msg.sender) returns (uint8)
    {
        Player storage player = players[msg.sender];
        require(player.lastSave == 0 || block.timestamp > player.lastSave + 12 hours, "RECENT_ACTIVITY");
        if (uint256(player.globalState.energy) + uint256(_amount) < 255)
        {
            player.globalState.energy += _amount;        
        } else {
            player.globalState.energy /= 2;
        }
        

        // deterministic random category based on block timestamp,
        // so all players that fetch at the same time, get the same category
        _ThoughtCategory randomThoughtCat = _ThoughtCategory(block.timestamp % 7);

        // deterministic random category based on block timestamp + player birth,
        // so all players that fetch at the same time with same birth, get the same wish
        uint256 randomThoughtIndex = (player.birthunix + block.timestamp) % thoughts[uint(randomThoughtCat)].length;

        _addPlayerWish(msg.sender, randomThoughtCat, randomThoughtIndex);
        return player.globalState.energy;
    }

    function _addPlayerWish(address _player, _ThoughtCategory _thotCat, uint256 _thotIndex) internal
    {
        Player storage player = players[_player];
        player.memories.push(Memori(
            player.memories.length,
            thoughts[uint(_thotCat)][_thotIndex].title,
            block.timestamp,
            _thotCat,
            _thotIndex,
            true // isWish?
        ));
    }

    function createPlayer(address _ref, string memory _name) external unregisteredOnly(msg.sender) alivePlayerOnly(_ref)
    {
        Player storage player = players[msg.sender];
        if (_ref != msg.sender) {
            player.ref = _ref;
        }
        
        player.name = _name;
        player.birthunix = block.timestamp;
        player.deadline = block.timestamp + 21 days;

        player.status = Status([111,111],[111,111],[111,111]);

        uint256[] memory deterministicRandomResults = expand(block.timestamp, 3);
        for (uint256 i = 0; i < 3; i++) {
            _ThoughtCategory randomThoughtCat = _ThoughtCategory(deterministicRandomResults[i] % 7);
            uint256 randomThoughtIndex = block.timestamp % thoughts[uint(randomThoughtCat)].length;
            __addPlayerMemory(msg.sender,randomThoughtCat,randomThoughtIndex);
        }
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

    function _setScale(uint256 _X, uint256 _Y, uint256 _Z, address _player) internal registeredOnly(_player)
    {
        Player storage player = players[msg.sender];
        player.globalState.sca[0] = _X;
        player.globalState.sca[1] = _Y;
        player.globalState.sca[2] = _Z;
    }

    function expand(uint256 randomValue, uint256 n) public pure returns (uint256[] memory expandedValues) {
        expandedValues = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i)));
        }
        return expandedValues;
    }

    function getMyLegacy() public view registeredOnly(msg.sender) returns (Memori[] memory)
    {
        return players[msg.sender].memories;
    }
    function getMyMemory(uint256 _memIndex) public view registeredOnly(msg.sender) returns (Memori memory)
    {
        Player storage player = players[msg.sender];
        return player.memories[_memIndex];
    }
}