// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function getVotes(uint256 _proposalIndex, address _voter) external view returns (uint256);
    function getVote(uint256 _proposalIndex, address _voter) external view returns (uint256);
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


/*
// 50000 tickets
// 1 - 5000 = 5000  (0.1)
// 6 - 1000 = 6000  (0.02)
// 17 - 500 = 8500  (0.01)
// 49 - 100 = 4900  (0.002)
// 298 - 20 = 5960  (0.0004)
// 4545 - 1 = 4545  (0.00002)

// 4545
// = 4545
// 4545+5960
// = 10405
// 4545+5960+4900
// = 15405
// 4545+5960+4900+8500
// = 23905
// 4545+5960+4900+8500+6000
// = 29905
// 4545+5960+4900+8500+6000+5000
// = 34905
*/


/*
// 50000 tickets
// 1 - 5000 = 5000
// 6 - 1000 = 6000
// 16 - 500 = 8000
// 40 - 100 = 4000
// 300 - 20 = 6000
// 4000 - 1 = 4000

// 4000
// = 4000
// 4000+6000
// = 10000
// 4000+6000+4000
// = 14000
// 4000+6000+4000+8000
// = 22000
// 4000+6000+4000+8000+6000
// = 28000
// 4000+6000+4000+8000+6000+4000
// = 32000
*/


/*
// 6000 tickets
// 1 - 1000 = 1000
// 3 - 500 = 1500
// 5 - 100 = 500
// 16 - 50 = 800
// 30 - 20 = 600
// 400 - 1 = 400

// 400
// = 400
// 400+600
// = 1000
// 400+600+800
// = 1800
// 400+600+800+500
// = 2300
// 400+600+800+500+1500
// = 3800
// 400+600+800+500+1500+1000
// = 4800
*/

interface IRandomResolver {
    function getRandomNumber() external returns (bytes32 requestId);
    function requestRandomNumber(uint256 userAddress) external returns (bytes32 requestId);
    function userAddressesOf(bytes32 requestId) external returns (uint256);
    function lastRequestId(uint256 userAddress) external returns (bytes32);
    function randomResultsOf(bytes32 requestId) external returns (uint256);
    function resetLastRandom(uint256 userAddress) external;
    function lastRandomResultsOf(uint256 userAddress) external returns (uint256);
}

contract TheOpenFarmDAOsLotto is Ownable {

    address LottoERC20 = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    address RANDOM_RESOLVER = 0xE5CD6B21455E87D5F8DaaB3a0AC1f0C728E09e66;

    struct Round {
        uint256 randomRequestBlock;
        uint256 randomResult;
        uint256 randomResultBlock;
        uint256 lockedFunds;
        uint256 votes;
        uint256 wonAmount;

        bytes32 randomRequestId;
        uint8 lastResult;
        bool redeemed;
    }

    uint256 public MIN_AMOUNT = 10**18;

    mapping(uint256 => Round) public gameRounds;
    mapping(uint256 => bool) public hasRequestedRandom;

    event NewRandomRequest(uint256 indexed _proposalIndex, bytes32 requestId);

    function resolveBet(uint256 _proposalIndex) external returns (bool) {
        require(gameRounds[_proposalIndex].lockedFunds > 0, "PROPOSAL_DOESNT_EXIST");
        require(gameRounds[_proposalIndex].randomRequestId != 0, "RANDOM_HASH_NOT_SET");
        bytes32 requestId = gameRounds[_proposalIndex].randomRequestId;
        require(IRandomResolver(RANDOM_RESOLVER).randomResultsOf(requestId) != 0, "RESULT_IS_NOT_DONE");

        gameRounds[_proposalIndex].randomResultBlock = block.number;
        gameRounds[_proposalIndex].randomResult = IRandomResolver(RANDOM_RESOLVER).randomResultsOf(requestId);
        bool result = true;
        // IRandomResolver(RANDOM_RESOLVER).resetLastRandom(_proposalIndex);
        return result;
    }

    function newRound(uint256 _proposalIndex, uint256 _amount, uint256 _votes) external onlyOwner {
        require(!hasRequestedRandom[_proposalIndex], "RANDOM_REQUEST_EXISTS");
        require(gameRounds[_proposalIndex].lockedFunds == 0, "PROPOSAL_EXIST");
        require(_amount > MIN_AMOUNT, "MINIMUN_ROUND_AMOUNT");

        gameRounds[_proposalIndex].lockedFunds = _amount;
        assert(IERC20(LottoERC20).transferFrom(owner(), address(this), _amount));
        gameRounds[_proposalIndex].votes = _votes;

        requestResolveRound(_proposalIndex);
    }

    function requestResolveRound(uint256 _proposalIndex) internal {
        require(gameRounds[_proposalIndex].lockedFunds > 0, "PROPOSAL_DOESNT_EXIST");
        require(!hasRequestedRandom[_proposalIndex], "RANDOM_REQUEST_EXISTS");

        hasRequestedRandom[_proposalIndex] = true;

        gameRounds[_proposalIndex].randomRequestId = IRandomResolver(RANDOM_RESOLVER).requestRandomNumber(_proposalIndex);
        gameRounds[_proposalIndex].randomRequestBlock = block.number;
        emit NewRandomRequest(_proposalIndex, gameRounds[_proposalIndex].randomRequestId);
    }
}