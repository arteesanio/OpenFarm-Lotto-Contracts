// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
interface ITokenLotto {
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

contract TheOpenFarmDAO is Ownable {

	uint256 public MIN_VOTE = 1 * 10**12;

    // We will write contract code here
	// Create a struct named Proposal containing all relevant information
	struct Proposal {
	    uint256 amount;
	    uint256 amountFunded;
	    // deadline - the UNIX timestamp until which this proposal is active. Proposal can be executed after the deadline has been exceeded.
	    uint256 deadline;
	    // executed - whether or not this proposal has been executed yet. Cannot be executed before the deadline has been exceeded.
	    bool executed;
	    // voters - a mapping of CryptoDevsNFT tokenIDs to booleans indicating whether that NFT has already been used to cast a vote or not
	    mapping(address => uint256) voters;
	}

	// Create a mapping of ID to Proposal
	mapping(uint256 => Proposal) public proposals;
	// Number of proposals that have been created
	uint256 public numProposals;

	address tokenLotto;
	address ERC20;

	// Create a payable constructor which initializes the contract
	// instances for FakeNFTMarketplace and CryptoDevsNFT
	// The payable allows this constructor to accept an ETH deposit when it is being deployed
	constructor(address _tokenLotto, address _ERC20) payable {
	    tokenLotto = _tokenLotto;
	    ERC20 = _ERC20;
	}

	// Create a modifier which only allows a function to be
	// called by someone who owns at least 1 CryptoDevsNFT
	modifier DAOHolderOnly() {
	    require(IERC20(ERC20).balanceOf(msg.sender) > 0, "NOT_A_DAO_MEMBER");
	    _;
	}

	// Create a modifier which only allows a function to be
	// called if the given proposal's deadline has not been exceeded yet
	modifier activeProposalOnly(uint256 proposalIndex) {
	    require(
	        proposals[proposalIndex].deadline > block.timestamp,
	        "DEADLINE_EXCEEDED"
	    );
	    _;
	}

	// Create a modifier which only allows a function to be
	// called if the given proposals' deadline HAS been exceeded
	// and if the proposal has not yet been executed
	modifier inactiveProposalOnly(uint256 proposalIndex) {
	    require(
	        proposals[proposalIndex].deadline <= block.timestamp,
	        "DEADLINE_NOT_EXCEEDED"
	    );
	    require(
	        proposals[proposalIndex].executed == false,
	        "PROPOSAL_ALREADY_EXECUTED"
	    );
	    _;
	}

	/// @dev createProposal allows a DAO Token holder to create a new proposal in the DAO
	/// @param _amount - the tokenID of the NFT to be purchased from FakeNFTMarketplace if this proposal passes
	/// @return Returns the proposal index for the newly created proposal
	function createProposal(uint256 _amount)
	    external
	    DAOHolderOnly
	    returns (uint256)
	{
	    Proposal storage proposal = proposals[numProposals];
	    proposal.amount = _amount;
	    // Set the proposal's voting deadline to be (current time + 5 minutes)
	    proposal.deadline = block.timestamp + 5 minutes;

	    numProposals++;

	    return numProposals - 1;
	}

	/// @dev voteOnProposal allows a DAO Token holder to cast their vote on an active proposal
	/// @param _proposalIndex - the index of the proposal to vote on in the proposals array
	/// @param _amount - the type of vote they want to cast
	function voteOnProposal(uint256 _proposalIndex, uint256 _amount)
	    external
	    DAOHolderOnly
	    activeProposalOnly(_proposalIndex)
	{
	    Proposal storage proposal = proposals[_proposalIndex];

	    uint256 memberBalance = IERC20(ERC20).balanceOf(msg.sender);
	    require(memberBalance >= MIN_VOTE, "ALREADY_VOTED");
	    require(proposal.voters[msg.sender] == 0, "ALREADY_VOTED");
	    proposal.voters[msg.sender] = _amount;
        proposal.amountFunded += _amount;
		assert(IERC20(ERC20).transferFrom(msg.sender, address(this), _amount));
	}

	/// @dev executeProposal allows any DAO Token holder to execute a proposal after it's deadline has been exceeded
	/// @param proposalIndex - the index of the proposal to execute in the proposals array
	function executeProposal(uint256 proposalIndex)
	    external
	    DAOHolderOnly
	    inactiveProposalOnly(proposalIndex)
	{
	    Proposal storage proposal = proposals[proposalIndex];

        require(proposal.amountFunded >= proposal.amount, "NOT_ENOUGH_FUNDING");
        require(IERC20(ERC20).balanceOf(address(this)) >= proposal.amountFunded, "NOT_ENOUGH_DAO_FUNDS");
        require(IERC20(ERC20).balanceOf(tokenLotto) >= proposal.amountFunded, "NOT_ENOUGH_LOTTO_FUNDS");

        ITokenLotto(tokenLotto).newRound(proposalIndex, proposal.amountFunded);
	    proposal.executed = true;
	}

	/// @dev withdrawEther allows the contract owner (deployer) to withdraw the ETH from the contract
	function withdrawEther() external onlyOwner {
	    payable(owner()).transfer(address(this).balance);
	}

	/// @dev withdrawBalance allows the contract owner (deployer) to withdraw IERC20(ERC20).balanceOf from the contract
	function withdrawBalance() external onlyOwner {
		assert
			(
				IERC20(ERC20).transferFrom
				(
					address(this),
					owner(),
					IERC20(ERC20).balanceOf(address(this))
				)
			);
	}

	// The following two functions allow the contract to accept ETH deposits
	// directly from a wallet without calling a function
	receive() external payable {}

	fallback() external payable {}
}


/*
// 50000 tickets
// 1 - 5000 = 5000	(0.1)
// 6 - 1000 = 6000	(0.02)
// 17 - 500 = 8500	(0.01)
// 49 - 100 = 4900	(0.002)
// 298 - 20 = 5960	(0.0004)
// 4545 - 1 = 4545	(0.00002)

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

contract TheOpenFarmDAOsLotto is Context {

	address ERC20 = 0xE5CD6B21455E87D5F8DaaB3a0AC1f0C728E09e66;
	address RANDOM_RESOLVER = 0xE5CD6B21455E87D5F8DaaB3a0AC1f0C728E09e66;
	address DAO_ADDRESS = 0xE5CD6B21455E87D5F8DaaB3a0AC1f0C728E09e66;

    modifier onlyDAO() {
        require(DAO_ADDRESS == _msgSender(), "caller is not the DAO");
        _;
    }

    struct Round {
        uint256 randomRequestBlock;
        uint256 randomResult;
        uint256 randomResultBlock;
        uint256 lockedFunds;
        uint256 wonAmount;

        bytes32 randomRequestId;
        uint8 lastResult;
        bool redeemed;
    }

	uint256 public MIN_AMOUNT = 1 * 10**17;
	uint256 public MIN_VOTE = 1 * 10**12;

    mapping(uint256 => Round) public gameRounds;
    mapping(uint256 => bool) public hasRequestedRandom;

    event NewRandomRequest(uint256 indexed _proposalIndex, bytes32 requestId);

    function requestResolveRound(uint256 _proposalIndex) internal {
        require(gameRounds[_proposalIndex].lockedFunds > 0, "PROPOSAL_DOESNT_EXIST");
        require(!hasRequestedRandom[_proposalIndex], "RANDOM_REQUEST_EXISTS");

        hasRequestedRandom[_proposalIndex] = true;

        gameRounds[_proposalIndex].randomRequestId = IRandomResolver(RANDOM_RESOLVER).requestRandomNumber(_proposalIndex);
        gameRounds[_proposalIndex].randomRequestBlock = block.number;
        emit NewRandomRequest(_proposalIndex, gameRounds[_proposalIndex].randomRequestId);
    }

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

    function newRound(uint256 _proposalIndex, uint256 _amount) external onlyDAO {
        require(!hasRequestedRandom[_proposalIndex], "RANDOM_REQUEST_EXISTS");
        require(gameRounds[_proposalIndex].lockedFunds == 0, "PROPOSAL_EXIST");
        require(_amount > MIN_AMOUNT, "MINIMUN_BET_AMOUNT");

        gameRounds[_proposalIndex].lockedFunds = _amount;
        assert(IERC20(ERC20).transferFrom(DAO_ADDRESS, address(this), _amount));

        requestResolveRound(_proposalIndex);
    }
}