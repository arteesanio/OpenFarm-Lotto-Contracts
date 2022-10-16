// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract TheOpenSimulation {









    struct People {
        uint peopleId;
        string country;
        string state;
        uint[] personIds;
    }

    mapping(address => People[]) private people;

    function addPeople(
        uint _peopleId,
        string memory _country,
        string memory _state,
        uint[] calldata _personIds
    ) public {
        people[msg.sender].push(People(_peopleId, _country, _state, _personIds));
    }
    













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
    struct Feeling {
        uint256[3] pos;
        uint256[3] rot;
        uint256[3] sca;
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
        // memoriMap - the list of Memori items of a players life.
        // globalState - the position, rotation and scale of a player.
        // graduated - whether or not this player has achieved its life goal. Cannot be true before the deadline has been reached.
        // ref - the player address that invited the next player.

        string URI;
        string name;
        uint256 birthunix;
        uint256 deadline;
        Memori[] memories;
        State globalState;
        Feeling status;
        Feeling satisfaction;
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
        require(players[_player].birthunix != 0 && block.timestamp < players[_player].deadline, "DEAD_PLAYER");
        _;
    }
    // Only allows to be called by
    modifier graduatedPlayerOnly(address _player) {
        require(players[_player].graduated == true, "STUDENT_PLAYER");
        _;
    }


    constructor () {
        Player storage player = players[address(0)];
        player.ref = msg.sender;
        
        player.birthunix = block.timestamp;
        player.deadline = block.timestamp + 42 days;
        player.graduated = true;

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

    function _addPlayerMemory(address _player, ThoughtCategory _thotCat, uint256 _thotIndex) internal alivePlayerOnly(_player)
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