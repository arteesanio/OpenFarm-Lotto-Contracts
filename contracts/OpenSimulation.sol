// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract TheOpenSimulation {

    enum ThoughtCategory {
        supernatural,
        ambition,
        art,
        hazards,
        logic,
        pets,
        social,
        sports
    }
    struct Thought {
        uint256 collectiveIndex;
        uint256 id;
        string title;
        uint256 birthunix;
        ThoughtCategory cat;
    }

    // All relevant information regarding a global state of a player.
    struct Status {
        uint256[2] focus;
        uint256[2] process;
        uint256[2] action;
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
        // memCat - the Category of the memori.
        // title - the title of the wish.
        // birthunix - the UNIX timestamp when the first wish ocurred.

        uint8 id;
        uint8 memCat;
        string title;
        uint256 birthunix;
    }

    enum MemCats
    {
      ambition,
      art,
      hazards,
      logic,
      pets,
      social,
      sports,
      supernatural
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
        ThoughtCategory thoughtCat;
        uint256 thoughtIndex;
    }

    // All relevant information regarding a player
    struct Player {
        // URI - the player's name.
        // name - the player's name.
        // deadline - the UNIX timestamp when the player is expected to die.
        // memories - the list of Memori items of a players life.
        // globalState - the position, rotation and scale of a player.
        // graduated - whether or not this player has achieved its life goal. Cannot be true before the deadline has been reached.
        // ref - the player address that invited the next player.

        string URI;
        string name;
        uint256 birthunix;
        uint256 deadline;
        Memori[] memories;
        State globalState;
        Status status;
        bool graduated;
        address ref;
    }

    mapping(uint => Thought[]) public thoughts;
    uint public collectiveThoughtIndex;

    // Keep track of players by their address
    mapping(address => Player) public players;

    // Only allows to be called by
    modifier registeredOnly(address _player) {
        require(players[_player].birthunix != 0, "UNREGISTERED_PLAYER");
        _;
    }
    modifier unregisteredOnly(address _player) {
        require(players[_player].birthunix == 0, "REGISTERED_PLAYER");
        _;
    }
    modifier alivePlayerOnly(address _player) {
        require(_player != address(0), "INVALID_PLAYER");
        require(address(this) == _player || (players[_player].birthunix != 0 && block.timestamp < players[_player].deadline), "DEAD_PLAYER");
        _;
    }
    // Only allows to be called by
    modifier graduatedPlayerOnly(address _player) {
        require(players[_player].graduated == true, "STUDENT_PLAYER");
        _;
    }


    constructor () {
        Player storage player = players[address(this)];
        player.ref = msg.sender;
        
        player.birthunix = block.timestamp;
        player.deadline = block.timestamp + 42 days;

        _addThought(Thought(0, 0, "Supernatural Memory", block.timestamp, ThoughtCategory.supernatural));
        _addThought(Thought(0, 0, "Ambition Memory", block.timestamp, ThoughtCategory.ambition));
        _addThought(Thought(0, 0, "Art Memory", block.timestamp, ThoughtCategory.art));
        _addThought(Thought(0, 0, "Hazards Memory", block.timestamp, ThoughtCategory.hazards));
        _addThought(Thought(0, 0, "Logic Memory", block.timestamp, ThoughtCategory.logic));
        _addThought(Thought(0, 0, "Pets Memory", block.timestamp, ThoughtCategory.pets));
        _addThought(Thought(0, 0, "Social Memory", block.timestamp, ThoughtCategory.social));
        _addThought(Thought(0, 0, "Sports Memory", block.timestamp, ThoughtCategory.sports));
    }

    function _addThought(Thought memory _thot) internal {
        collectiveThoughtIndex++;
        thoughts[uint(_thot.cat)].push(Thought(collectiveThoughtIndex, thoughts[uint(_thot.cat)].length, _thot.title, _thot.birthunix, _thot.cat));
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
    function _addPlayerMemory(address _player, ThoughtCategory _thotCat, uint256 _thotIndex) internal
    {
        Player storage player = players[_player];
        player.memories.push(Memori(
            player.memories.length,
            thoughts[uint(_thotCat)][_thotIndex].title,
            block.timestamp,
            _thotCat,
            _thotIndex
        ));

        // uint256 id;
        // string title;
        // uint256 birthunix;
        // ThoughtCategory thoughtCat;
        // uint256 thoughtIndex;
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

        uint256[] memory deterministicRandomResults = expand(player.birthunix, 3);
        for (uint256 i = 0; i < 3; i++) {
            ThoughtCategory randomThoughtCat = ThoughtCategory(deterministicRandomResults[i] % 7);
            uint256 randomThoughtIndex = player.birthunix % thoughts[uint(randomThoughtCat)].length;
            _addPlayerMemory(msg.sender,randomThoughtCat,randomThoughtIndex);
        }
    }

    function _createTestPlayer(address _player) external unregisteredOnly(_player)
    {
        Player storage player = players[_player];
        player.name = "test";
        player.birthunix = block.timestamp;
        player.deadline = block.timestamp + 21 days;

        uint256[] memory deterministicRandomResults = expand(player.birthunix, 3);
        for (uint256 i = 0; i < 3; i++) {
            ThoughtCategory randomThoughtCat = ThoughtCategory(deterministicRandomResults[i] % 7);
            uint256 randomThoughtIndex = player.birthunix % thoughts[uint(randomThoughtCat)].length;
            _addPlayerMemory(_player,randomThoughtCat,randomThoughtIndex);
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
}