// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function approve(address spender, uint amount) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);
    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
}
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

// We will add the Interfaces here
/**
 * Interface for the FakeNFTMarketplace
 */
interface IOpenLotto {
    /// @dev getPrice() returns the price of an NFT from the FakeNFTMarketplace
    /// @return Returns the price in Wei for an NFT
    function getPrice() external view returns (uint256);

    /// @dev availableReserve() returns whether or not the given _tokenId has already been purchased
    /// @return Returns a boolean value - true if availableReserve, false if not
    function availableReserve(uint256 _tokenId) external view returns (bool);

    /// @dev purchase() purchases an NFT from the FakeNFTMarketplace
    /// @param _tokenId - the fake NFT tokenID to purchase
    function purchase(uint256 _tokenId) external payable;

    function newRound(uint256 proposalIndex, uint256 _amount) external;
}
interface IOpenDAO {
    function getVoterAmountOfVotes(uint256 _proposalIndex, address _voter) external view returns (uint256);
    function getVoterVoteIndex(uint256 _proposalIndex, address _voter) external view returns (uint256);
}

/**
 * Minimal interface for Token containing only two functions
 * that we are interested in
 */
interface IToken {
    /// @dev balanceOf returns the number of NFTs owned by the given address
    /// @param owner - address to fetch number of NFTs for
    /// @return Returns the number of NFTs owned
    function balanceOf(address owner) external view returns (uint256);

    /// @dev tokenOfOwnerByIndex returns a tokenID at given index for owner
    /// @param owner - address to fetch the NFT TokenID for
    /// @param index - index of NFT in owned tokens array to fetch
    /// @return Returns the TokenID of the NFT
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);
}


interface IRandomResolver {
    function requestRandomWords() external;
    function s_requestId() external returns (bytes32);
    function s_randomWords0() external returns (uint256);
    function s_randomWords(uint256) external returns (uint256);

    // function getRandomNumber() external returns (bytes32 requestId);
    // function requestRandomNumber(uint256 userAddress) external returns (bytes32 requestId);
    // function userAddressesOf(bytes32 requestId) external returns (uint256);
    // function lastRequestId(uint256 userAddress) external returns (bytes32);
    // function randomResultsOf(bytes32 requestId) external returns (uint256);
    // function resetLastRandom(uint256 userAddress) external;
    // function lastRandomResultsOf(uint256 userAddress) external returns (uint256);
}

/** @title Open Lottery.
 * @notice It is a contract for a lottery system using
 * randomness provided externally controlled by a DAO.
 */
contract TheOpenLotto is Ownable {

    // address LottoERC20 = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063; // DAI Polygon Networ
    address public LottoERC20;
    // address public RANDOM_RESOLVER = 0x4C5f09D239E11896ed4B21e5BEba0DE9D777eEbD;
    address public RANDOM_RESOLVER;

    struct Round {
        uint256 randomRequestBlock;
        uint256 randomResultBlock;
        uint256 lockedFunds;
        uint256 amountRaised;
        uint256 votes;

        bytes32 randomRequestId;
        uint8 lastResult;
    }
    struct RoundLog {
        uint256 randomResult;
        mapping(uint256 => uint256) scratchedNumber;
        mapping(uint256 => uint256) wonAmount;
        uint256[83] winners;
    }

    // Keeps track of round progress
    mapping(uint256 => Round) public gameRounds;
    // Keeps track of round results
    mapping(uint256 => RoundLog) public gameLogs;
    // For verifying maximun amount of winners per bracket
    mapping(uint256 => uint256[6]) public redeemHistory;

    // Keeps track of VRF requests per round
    mapping(uint256 => uint256) public randomRequests;
    // Keeps track of duplicate VRF requests
    mapping(uint256 => bool) public hasRequestedRandom;
    event NewRandomRequest(uint256 indexed _proposalIndex, bytes32 requestId);

    constructor(address _LottoERC20, address _resolver) {
        LottoERC20 = _LottoERC20;
        RANDOM_RESOLVER = _resolver;
    }

    function newRound(uint256 _proposalIndex, uint256 _amount, uint256 _votes) external onlyOwner {
        require(!hasRequestedRandom[_proposalIndex], "RANDOM_REQUEST_EXISTS");
        require(gameRounds[_proposalIndex].amountRaised == 0, "PROPOSAL_EXIST");

        gameRounds[_proposalIndex].amountRaised = _amount;
        gameRounds[_proposalIndex].lockedFunds = gameRounds[_proposalIndex].amountRaised * 7 / 10;

        // assert(IERC20(LottoERC20).transferFrom(owner(), address(this), gameRounds[_proposalIndex].lockedFunds));
        gameRounds[_proposalIndex].votes = _votes;

        // requestResolveRound(_proposalIndex);
    }

    function requestResolveRound(uint256 _proposalIndex) external {
        require(gameRounds[_proposalIndex].amountRaised > 0, "PROPOSAL_DOESNT_EXIST");
        require(hasRequestedRandom[_proposalIndex] == false, "RANDOM_REQUEST_EXISTS");

        hasRequestedRandom[_proposalIndex] = true;

        IRandomResolver(RANDOM_RESOLVER).requestRandomWords();
        gameRounds[_proposalIndex].randomRequestId = IRandomResolver(RANDOM_RESOLVER).s_requestId();
        gameRounds[_proposalIndex].randomRequestBlock = block.number;
        emit NewRandomRequest(_proposalIndex, gameRounds[_proposalIndex].randomRequestId);
    }

    function withdrawAmount(uint256 _proposalIndex, uint256 _votePos, address _voter) external returns (uint256) {
        uint256 voteIndex = IOpenDAO(owner()).getVoterVoteIndex(_proposalIndex, _voter);
        uint256 voteDistance = IOpenDAO(owner()).getVoterAmountOfVotes(_proposalIndex, _voter);
        require(_votePos >= voteIndex && _votePos <= voteIndex + voteDistance, "NOT_VOTE_OWNER");
        uint256 winAmount = gameLogs[_proposalIndex].wonAmount[_votePos];

        require(winAmount > 0, "INVALID_WIN");
        require(winAmount > 1, "ALREADY_REDEEMED");

        assert(IERC20(LottoERC20).transferFrom(owner(), _voter, winAmount));

        gameLogs[_proposalIndex].wonAmount[_votePos] = 1;
        return winAmount;
    }

    function withdrawAll(uint256 _proposalIndex, uint256 _voteIndex, address _voter, uint256 _voteDistance) external returns (uint256) {
        uint256 voteIndex = IOpenDAO(owner()).getVoterVoteIndex(_proposalIndex, _voter);
        uint256 voteDistance = IOpenDAO(owner()).getVoterAmountOfVotes(_proposalIndex, _voter);
        require(_voteIndex <= voteIndex + voteDistance, "NOT_VALID_INDEX");
        require(_voteDistance > 0, "MIN_DISTANCE");
        require(_voteIndex + _voteDistance <= voteIndex + voteDistance, "OUT_OF_BOUNDARY");
        
        if(_voteDistance < voteDistance) {
            voteDistance = _voteDistance;
        }

        uint256 wonAmount = 0;
        for (uint256 i = 0; i < voteDistance; i++) {
            uint256 PREwinAmount = gameLogs[_proposalIndex].wonAmount[i + _voteIndex];
            require(PREwinAmount != 1, "ALREADY_REDEEMED");
            // getVoteResult(_proposalIndex, i + _voteIndex, _voter);
            uint256 winAmount = gameLogs[_proposalIndex].wonAmount[i + _voteIndex];
            if (winAmount > 1) {
                wonAmount += winAmount;
                gameLogs[_proposalIndex].wonAmount[i + _voteIndex] = 1;
            }
        }
        if (wonAmount > 0) {
            assert(IERC20(LottoERC20).transferFrom(owner(), _voter, wonAmount));
        }

        return wonAmount;
    }

    function resolveBet(uint256 _proposalIndex) external returns (bool) {
        require(gameRounds[_proposalIndex].amountRaised > 0, "PROPOSAL_DOESNT_EXIST");
        bytes32 requestId = gameRounds[_proposalIndex].randomRequestId;
        require(requestId == IRandomResolver(RANDOM_RESOLVER).s_requestId(), "REQUEST_NOT_CURRENT");
        require(randomRequests[_proposalIndex] == 0, "RESULT_ALREADY_DONE");

        gameRounds[_proposalIndex].randomResultBlock = block.number;
        randomRequests[_proposalIndex] = IRandomResolver(RANDOM_RESOLVER).s_randomWords0();
        gameLogs[_proposalIndex].randomResult = IRandomResolver(RANDOM_RESOLVER).s_randomWords(0);

        uint256[] memory results = expand(gameLogs[_proposalIndex].randomResult, 83);
        uint256 winAmount;

        for (uint256 i = 0; i < 83; i++) {

            uint256 winnerIndex = (results[i] % gameRounds[_proposalIndex].votes) + 1;
            gameLogs[_proposalIndex].winners[i] = winnerIndex;

            if (i == 0) {
                winAmount = gameRounds[_proposalIndex].amountRaised * 2 / 10;
            } else if(i < 3) {
                winAmount = gameRounds[_proposalIndex].amountRaised * 5 / 100;
            } else if(i < 13) {
                winAmount = gameRounds[_proposalIndex].amountRaised * 1 / 100;
            } else if(i < 33) {
                winAmount = gameRounds[_proposalIndex].amountRaised * 5 / 1000;
            } else {
                winAmount = gameRounds[_proposalIndex].amountRaised * 2 / 1000;
            }

            gameLogs[_proposalIndex].wonAmount[winnerIndex] = winAmount;
            gameLogs[_proposalIndex].scratchedNumber[winnerIndex] = i;

        }

        bool result = true;
        return result;
    }

    function getVoteScratchedNumber(uint256 _proposalIndex, uint256 _votePos) external view returns (uint256) {
        return gameLogs[_proposalIndex].scratchedNumber[_votePos];
    }
    function getWonAmount(uint256 _proposalIndex, uint256 _votePos) external view returns (uint256) {
        return gameLogs[_proposalIndex].wonAmount[_votePos];
    }
    function getWinner(uint256 _proposalIndex, uint256 _winnerIndex) external view returns (uint256) {
        return gameLogs[_proposalIndex].winners[_winnerIndex];
    }
    function emergencyWithdraw() external onlyOwner {
        assert(IERC20(LottoERC20).transferFrom(address(this), owner(), IERC20(LottoERC20).balanceOf(address(this))));
    }

    function expand(uint256 randomValue, uint256 n) public pure returns (uint256[] memory expandedValues) {
        expandedValues = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i)));
        }
        return expandedValues;
    }
}