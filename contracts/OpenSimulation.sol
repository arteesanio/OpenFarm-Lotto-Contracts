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

    enum ThoughtCategory { supernatural, ambition, art, hazards, logic, pets, social, sports }
    struct Thought {
        uint256 collectiveIndex;
        uint256 id;
        string title;
        uint256 birthunix;
        ThoughtCategory cat;
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
        ThoughtCategory thoughtCat;
        uint256 thoughtIndex;
        uint8 isStatusStateDependant;
        bool isWish;

        // uint256[3] goalFoc; uint256[3] goalPro; uint256[3] goalAct;
        uint256[3] goalPos; uint256[3] goalRot; uint256[3] goalSca;
    }

    // All relevant information regarding global stats of a player.
    struct State {
        // fun, energy, hygene, protein
        // fun fixes fun
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
        uint256 wishCount;
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

        __addThought(Thought(0, 0, "Supernatural Memory", block.timestamp, ThoughtCategory.supernatural));
        __addThought(Thought(0, 0, "Ambition Memory", block.timestamp, ThoughtCategory.ambition));
        __addThought(Thought(0, 0, "Art Memory", block.timestamp, ThoughtCategory.art));
        __addThought(Thought(0, 0, "Hazards Memory", block.timestamp, ThoughtCategory.hazards));
        __addThought(Thought(0, 0, "Logic Memory", block.timestamp, ThoughtCategory.logic));
        __addThought(Thought(0, 0, "Pets Memory", block.timestamp, ThoughtCategory.pets));
        __addThought(Thought(0, 0, "Social Memory", block.timestamp, ThoughtCategory.social));
        __addThought(Thought(0, 0, "Sports Memory", block.timestamp, ThoughtCategory.sports));
    }

    function __addThought(Thought memory _thot) internal {
        collectiveThoughtIndex++;
        thoughts[uint(_thot.cat)].push(Thought(collectiveThoughtIndex, thoughts[uint(_thot.cat)].length, _thot.title, _thot.birthunix, _thot.cat));
    }

    function __addPlayerMemory(address _player, ThoughtCategory _thotCat, uint256 _thotIndex) internal
    {
        Player storage player = players[_player];
        player.memories.push(Memori(
            player.memories.length,
            thoughts[uint(_thotCat)][_thotIndex].title,
            block.timestamp,
            _thotCat,
            _thotIndex,
            uint8(block.timestamp % 255),
            false, // isWish?
            [uint256(0),uint256(0),uint256(0)],[uint256(0),uint256(0),uint256(0)],[uint256(0),uint256(0),uint256(0)]
        ));
    }

    // allowed to be called by registered dead or alive players, target has to be alive
    function stealPlayerEnergy(address _forgottenPlayer)
        public alivePlayerOnly(_forgottenPlayer) registeredOnly(msg.sender) 
    {
        Player storage forgottenPlayer = players[_forgottenPlayer];
        require(forgottenPlayer.lastSave > 0, "UNUSED_PLAYER");
        require(block.timestamp > forgottenPlayer.lastSave + 48 minutes, "NOT_FORGOTTEN");

        forgottenPlayer.globalState.energy /= 2;
        forgottenPlayer.globalState.fun /= 2;
        forgottenPlayer.globalState.hygene /= 2;
        forgottenPlayer.globalState.protein /= 2;

        addPlayerEnergy(
            forgottenPlayer.globalState.energy,
            forgottenPlayer.globalState.fun,
            forgottenPlayer.globalState.hygene,
            forgottenPlayer.globalState.protein
        );
    }

    // fun, energy, hygene, protein
    // allowed to be called by alive players only
    function addPlayerEnergy(uint8 _energy, uint8 _fun, uint8 _hygene, uint8 _protein)
        public alivePlayerOnly(msg.sender)
    {
        Player storage player = players[msg.sender];
        require(player.lastSave == 0 || block.timestamp > player.lastSave + 12 minutes, "RECENT_ACTIVITY");

        if (uint256(player.globalState.energy) + uint256(_energy) < 255)
        {
            player.globalState.energy += _energy;        
        } else {
            player.globalState.energy /= 2;
        }

        if (uint256(player.globalState.fun) + uint256(_fun) < 255)
        {
            player.globalState.fun += _fun;        
        } else {
            player.globalState.fun /= 2;
        }

        if (uint256(player.globalState.hygene) + uint256(_hygene) < 255)
        {
            player.globalState.hygene += _hygene;        
        } else {
            player.globalState.hygene /= 2;
        }

        if (uint256(player.globalState.protein) + uint256(_protein) < 255)
        {
            player.globalState.protein += _protein;        
        } else {
            player.globalState.protein /= 2;
        }


        // focus[0] | focus on senses is inversly proportional to the fun of a player 
        // focus[1] | focus force is directly proportional to the energy of a player 
        player.status._focus[0] = 255-player.globalState.fun;        
        player.status._focus[1] = player.globalState.energy;

        // process[0] | process with logic is inversly proportional to the protein of a player 
        // process[1] | process force is directly proportional to the energy of a player 
        player.status._process[0] = 255-player.globalState.protein;        
        player.status._process[1] = player.globalState.energy;

        // action[0] | action to the outer world is inversly proportional to the hygene of a player 
        // action[1] | action force is directly proportional to the protein of a player 
        player.status._action[0] = 255-player.globalState.hygene;        
        player.status._action[1] = player.globalState.protein;        
        

        // deterministic random category based on block timestamp,
        // so all players that fetch at the same time, get the same category
        ThoughtCategory randomThoughtCat = ThoughtCategory(block.timestamp % 7);

        // deterministic random category based on block timestamp + player birth,
        // so all players that fetch at the same time with same birth, get the same wish
        uint256 randomThoughtIndex = (player.birthunix + block.timestamp) % thoughts[uint(randomThoughtCat)].length;

        _addPlayerWish(msg.sender, randomThoughtCat, randomThoughtIndex);

        player.lastSave = block.timestamp;
    }

    function fufillWish(uint256 _memIndex) public registeredOnly(msg.sender)
    {
        Player storage player = players[msg.sender];
        // require(player.memories[_memIndex].thoughtCat == _thotCat, "INVALID_CATEGORY");
        require(player.memories[_memIndex].isWish == true, "IS_NOT_WISH");

        bool nowIsWish = true;

        // if (player.memories[_memIndex].isStatusStateDependant >= 255) { // both dependant

        // status dependant or both dependent
        if (player.memories[_memIndex].isStatusStateDependant < 100 || player.memories[_memIndex].isStatusStateDependant >= 200)
        {
            require (player.status._focus[0] >= 123, "NOT_ENOUGH_STAT status._focus");
            require (player.status._focus[1] >= 123, "NOT_ENOUGH_STAT status._focus force");
            require (player.status._process[0] >= 123, "NOT_ENOUGH_STAT status._process");
            require (player.status._process[1] >= 123, "NOT_ENOUGH_STAT status._process force");
            require (player.status._action[0] >= 123, "NOT_ENOUGH_STAT status._action");
            require (player.status._action[1] >= 123, "NOT_ENOUGH_STAT status._action force");
            nowIsWish = false;
        }

        // state or both dependant
        if (player.memories[_memIndex].isStatusStateDependant >= 100)
        {
            require (player.globalState.fun >= 123, "NOT_ENOUGH_STAT globalState.fun");
            require (player.globalState.energy >= 123, "NOT_ENOUGH_STAT globalState.energy");
            require (player.globalState.hygene >= 123, "NOT_ENOUGH_STAT globalState.hygene");
            require (player.globalState.protein >= 123, "NOT_ENOUGH_STAT globalState.protein");
            nowIsWish = false;
        }
        
        player.memories[_memIndex].isWish = nowIsWish;
        player.wishCount++;
    }
    function _addPlayerWish(address _player, ThoughtCategory _thotCat, uint256 _thotIndex) internal
    {
        Player storage player = players[_player];
        
        player.memories.push(Memori(
            player.memories.length,
            thoughts[uint(_thotCat)][_thotIndex].title,
            block.timestamp,
            _thotCat,
            _thotIndex,
            uint8(block.timestamp % 255),
            true, // isWish?

            [uint256(0),uint256(0),uint256(0)],[uint256(0),uint256(0),uint256(0)],[uint256(0),uint256(0),uint256(0)]
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

        player.globalState = State(
            // fun, energy, hygene, protein
            1,1,3,5,

            // position
            [uint256(0),uint256(0),uint256(0)],
            // rotation
            [uint256(0),uint256(0),uint256(0)],
            // scale
            [uint256(0),uint256(0),uint256(0)]
        );

        uint256[] memory deterministicRandomResults = expand(block.timestamp, 3);
        for (uint256 i = 0; i < 3; i++) {
            ThoughtCategory randomThoughtCat = ThoughtCategory(deterministicRandomResults[i] % 7);
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