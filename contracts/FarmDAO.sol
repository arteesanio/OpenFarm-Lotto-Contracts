// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
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

    function newRound(uint256 proposalIndex, uint256 _amount, uint256 _votes) external;
}


contract TheOpenFarmDAO is Ownable {

    uint256 public VOTE_COST = 1**15;

    // We will write contract code here
    // Create a struct named Proposal containing all relevant information
    struct Proposal {
        uint256 amount;
        uint256 amountVotes;
        // deadline - the UNIX timestamp until which this proposal is active. Proposal can be executed after the deadline has been exceeded.
        uint256 deadline;
        // executed - whether or not this proposal has been executed yet. Cannot be executed before the deadline has been exceeded.
        bool executed;
        // voters - a mapping of CryptoDevsNFT tokenIDs to booleans indicating whether that NFT has already been used to cast a vote or not
        mapping(address => uint256) voters;
        mapping(address => uint256) votersVotes;
    }

    // Create a mapping of ID to Proposal
    mapping(uint256 => Proposal) public proposals;
    // Number of proposals that have been created
    uint256 public numProposals;

    address tokenLotto = 0x12b1a00d967c9Ab27ef27e7728923067EF3a7Fc2;
    address LottoERC20 = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;

    // Create a modifier which only allows a function to be
    // called by someone who owns at least 1 CryptoDevsNFT
    modifier DAOHolderOnly() {
        require(IERC20(LottoERC20).allowance(msg.sender, address(this)) > 0, "NOT_A_DAO_MEMBER");
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

    function getVotes(uint256 _proposalIndex, address _voter)
        external
        view
        returns (uint256)
    {
        Proposal storage proposal = proposals[_proposalIndex];
        require(proposal.votersVotes[_voter] != 0, "NOT_FOUND");
        return proposal.votersVotes[_voter];
    }
    function getVote(uint256 _proposalIndex, address _voter)
        external
        view
        returns (uint256)
    {
        Proposal storage proposal = proposals[_proposalIndex];
        require(proposal.voters[_voter] != 0, "NOT_FOUND");
        return proposal.voters[_voter];
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

        uint256 memberBalance = IERC20(LottoERC20).balanceOf(msg.sender);
        uint256 amount = VOTE_COST * _amount;
        require(memberBalance >= amount, "NOT_ENOUGH_BALANCE");
        require(proposal.votersVotes[msg.sender] == 0, "ALREADY_VOTED");
        require(_amount > 0, "INVALID_VOTE_COUNT");
        proposal.votersVotes[msg.sender] = _amount;
        proposal.voters[msg.sender] = proposal.amountVotes;
        proposal.amountVotes += _amount;
        assert(IERC20(LottoERC20).transferFrom(msg.sender, address(this), amount));
    }

    /// @dev executeProposal allows any DAO Token holder to execute a proposal after it's deadline has been exceeded
    /// @param proposalIndex - the index of the proposal to execute in the proposals array
    function executeProposal(uint256 proposalIndex)
        external
        DAOHolderOnly
        inactiveProposalOnly(proposalIndex)
    {
        Proposal storage proposal = proposals[proposalIndex];

        require(proposal.amountVotes >= proposal.amount, "NOT_ENOUGH_VOTES");
        require(IERC20(LottoERC20).balanceOf(tokenLotto) >= proposal.amount, "NOT_ENOUGH_LOTTO_FUNDS");
        assert(IERC20(LottoERC20).transferFrom(tokenLotto, address(this), proposal.amount));
        require(IERC20(LottoERC20).balanceOf(address(this)) >= proposal.amount, "NOT_ENOUGH_DAO_FUNDS");

        IOpenLotto(tokenLotto).newRound(proposalIndex, proposal.amount, proposal.amountVotes);
        proposal.executed = true;
    }

    /// @dev withdrawEther allows the contract owner (deployer) to withdraw the ETH from the contract
    function withdrawEther() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /// @dev withdrawBalance allows the contract owner (deployer) to withdraw IERC20(LottoERC20).balanceOf from the contract
    function withdrawBalance() external onlyOwner {
        assert(IERC20(LottoERC20).transferFrom (address(this), owner(), IERC20(LottoERC20).balanceOf(address(this)) ) );
    }

    // The following two functions allow the contract to accept ETH deposits
    // directly from a wallet without calling a function
    receive() external payable {}

    fallback() external payable {}
}
