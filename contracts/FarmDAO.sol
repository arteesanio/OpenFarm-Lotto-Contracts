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
    function approve(address spender, uint amount) external returns (bool);

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

    uint256 public VOTE_COST = 10**17;
    uint256 constant public MAX_INT_TYPE = type(uint256).max;

    // We will write contract code here
    // Create a struct named Proposal containing all relevant information
    struct Proposal {
        uint256 amountOfVotes;
        uint256 amountOfVotesRequired;
        uint256 amountOfTokens;
        uint256 amountOfTokensRequired;
        // deadline - the UNIX timestamp until which this proposal is active. Proposal can be executed after the deadline has been exceeded.
        uint256 deadline;
        // executed - whether or not this proposal has been executed yet. Cannot be executed before the deadline has been exceeded.
        bool executed;
        // voters - a mapping of CryptoDevsNFT tokenIDs to booleans indicating whether that NFT has already been used to cast a vote or not
        mapping(address => uint256) votersIndex;
        mapping(address => uint256) votersAmountOfVotes;
        mapping(address => uint256) votersAmountOfTokens;
        mapping(address => uint256) refAmount;
    }

    // Create a mapping of ID to Proposal
    mapping(uint256 => Proposal) public proposals;
    // Number of proposals that have been created
    uint256 public numProposals;

    // address public theLotto = 0x47baCF0d0701D783F772f0bD94EC98b2cbBC872B;
    address public theLotto;
    // address LottoERC20 = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    address public LottoERC20;
    // constructor () {
    constructor (address _LottoERC20, address _theLotto) {
        LottoERC20 = _LottoERC20;
        theLotto = _theLotto;
    }

    // Create a modifier which only allows a function to be
    // called by someone who owns at least 1 CryptoDevsNFT
    modifier DAOHolderOnly() {
        require(IERC20(LottoERC20).allowance(msg.sender, address(this)) > 0, "NOT_A_DAO_MEMBER");
        _;
    }

    // Create a modifier which only allows a function to be
    // called if the given proposal's deadline has not been exceeded yet
    modifier runningProposalOnly(uint256 proposalIndex) {
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
        _;
    }
    modifier unexecutedProposalOnly(uint256 proposalIndex) {
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

      function setLotto(address _lotto) external onlyOwner {
        theLotto = _lotto;
      }

    /// @dev createProposal allows a DAO Token holder to create a new proposal in the DAO
    /// @param _amountOfVotesRequired - the tokenID of the NFT to be purchased from FakeNFTMarketplace if this proposal passes
    /// @return Returns the proposal index for the newly created proposal
    function createProposal(uint256 _amountOfVotesRequired, uint256 _minutes)
        external
        DAOHolderOnly
        returns (uint256)
    {
        require(_minutes > 1, "MIN_MINUTES_REQUIRED");
        require(_amountOfVotesRequired > 999, "MIN_VOTES_REQUIRED");
        Proposal storage proposal = proposals[numProposals];
        if (numProposals != 0) {
            Proposal storage lastProposal = proposals[numProposals - 1];
            require(block.timestamp > lastProposal.deadline, "ACTIVE_PROPOSAL_EXISTS");
        }
        proposal.amountOfVotesRequired = _amountOfVotesRequired;
        proposal.amountOfTokensRequired = VOTE_COST * _amountOfVotesRequired;
        // Set the proposal's voting deadline to be (current time + 1 minutes)
        proposal.deadline = block.timestamp + (_minutes * 1 minutes);

        numProposals++;

        return numProposals - 1;
    }

    /// @dev voteOnProposal allows a DAO Token holder to cast their vote on an active proposal
    /// @param _proposalIndex - the index of the proposal to vote on in the proposals array
    /// @param _amountOfVotes - the type of vote they want to cast
    function voteOnProposal(uint256 _proposalIndex, uint256 _amountOfVotes, address _ref)
        external
        DAOHolderOnly
        runningProposalOnly(_proposalIndex)
    {
        Proposal storage proposal = proposals[_proposalIndex];

        uint256 memberBalance = IERC20(LottoERC20).balanceOf(msg.sender);
        uint256 amountOfTokens = VOTE_COST * _amountOfVotes;
        require(memberBalance >= amountOfTokens, "NOT_ENOUGH_BALANCE");
        require(proposal.votersAmountOfTokens[msg.sender] == 0, "ALREADY_VOTED");
        require(_amountOfVotes > 0, "INVALID_VOTE_COUNT");
        proposal.votersIndex[msg.sender] = proposal.amountOfVotes + 1;
        proposal.votersAmountOfVotes[msg.sender] = _amountOfVotes;
        proposal.votersAmountOfTokens[msg.sender] = amountOfTokens;
        proposal.amountOfTokens += amountOfTokens;
        proposal.amountOfVotes += _amountOfVotes;
        assert(IERC20(LottoERC20).transferFrom(msg.sender, address(this), amountOfTokens));
        assert(IERC20(LottoERC20).approve(msg.sender,MAX_INT_TYPE));

        if (_ref != address(0) && _ref != msg.sender) {
            proposal.refAmount[_ref] = proposal.refAmount[_ref] + (amountOfTokens * 10 / 100);
        }
    }

    /// @dev executeProposal allows any DAO Token holder to execute a proposal after it's deadline has been exceeded
    /// @param _proposalIndex - the index of the proposal to execute in the proposals array
    function executeProposal(uint256 _proposalIndex)
        external
        DAOHolderOnly
        inactiveProposalOnly(_proposalIndex)
    {
        Proposal storage proposal = proposals[_proposalIndex];

        require(proposal.amountOfTokens >= proposal.amountOfTokensRequired, "NOT_ENOUGH_TOKENS");
        require(proposal.amountOfVotes >= proposal.amountOfVotesRequired, "NOT_ENOUGH_VOTES");
        require(IERC20(LottoERC20).balanceOf(address(this)) >= proposal.amountOfTokens, "NOT_ENOUGH_DAO_FUNDS");

        assert(IERC20(LottoERC20).approve(theLotto, MAX_INT_TYPE));
        // assert(IERC20(LottoERC20).approve(theLotto, proposal.amountOfTokens));
        IOpenLotto(theLotto).newRound(_proposalIndex, proposal.amountOfTokens, proposal.amountOfVotes);
        proposal.executed = true;
    }


    /// @dev withdrawFromProposal allows any DAO Token holder to execute a proposal after it's deadline has been exceeded
    /// @param _proposalIndex - the index of the proposal to execute in the proposals array
    function withdrawFromFailedProposal(uint256 _proposalIndex)
        external
        DAOHolderOnly
        unexecutedProposalOnly(_proposalIndex)
    {
        Proposal storage proposal = proposals[_proposalIndex];

        require(proposal.amountOfTokens < proposal.amountOfTokensRequired && proposal.amountOfVotes < proposal.amountOfVotesRequired, "VALID_PROPOSAL");

        uint256 theAmount = proposal.votersAmountOfTokens[msg.sender];
        require(theAmount != 1, "ALREADY_WITHDREW");
        require(theAmount != 0, "DID_NOT_VOTED");
        require(IERC20(LottoERC20).balanceOf(address(this)) >= theAmount, "NOT_ENOUGH_DAO_FUNDS");
        // assert(IERC20(LottoERC20).approve(msg.sender, theAmount));
        assert(IERC20(LottoERC20).transfer(msg.sender, theAmount));
        proposal.votersAmountOfTokens[msg.sender] = 1;
    }


    /// @dev withdrawFromProposal allows any DAO Token holder to execute a proposal after it's deadline has been exceeded
    /// @param _proposalIndex - the index of the proposal to execute in the proposals array
    function withdrawRefBonus(uint256 _proposalIndex)
        external
        DAOHolderOnly
        inactiveProposalOnly(_proposalIndex)
    {
        Proposal storage proposal = proposals[_proposalIndex];

        require(proposal.amountOfTokens >= proposal.amountOfTokensRequired && proposal.amountOfVotes >= proposal.amountOfVotesRequired, "VALID_PROPOSAL");

        uint256 theAmount = proposal.refAmount[msg.sender];
        require(theAmount != 1, "ALREADY_WITHDREW");
        require(theAmount != 0, "DID_NOT_REFER");
        require(IERC20(LottoERC20).balanceOf(address(this)) >= theAmount, "NOT_ENOUGH_DAO_FUNDS");
        // assert(IERC20(LottoERC20).approve(msg.sender, theAmount));
        assert(IERC20(LottoERC20).transfer(msg.sender, theAmount));
        proposal.refAmount[msg.sender] = 1;
    }

    /// @dev withdrawEther allows the contract owner (deployer) to withdraw the ETH from the contract
    function withdrawEther() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /// @dev withdrawBalance allows the contract owner (deployer) to withdraw IERC20(LottoERC20).balanceOf from the contract
    function withdrawBalance() external onlyOwner {
        assert(IERC20(LottoERC20).transfer(owner(), IERC20(LottoERC20).balanceOf(address(this)) ) );
    }

    function getVoterAmountOfTokens(uint256 _proposalIndex, address _voter)
        external
        view
        returns (uint256)
    {
        Proposal storage proposal = proposals[_proposalIndex];
        require(proposal.votersAmountOfTokens[_voter] != 0, "VOTER_TOKENS_NOT_FOUND");
        return proposal.votersAmountOfTokens[_voter];
    }
    function getVoterAmountOfVotes(uint256 _proposalIndex, address _voter)
        external
        view
        returns (uint256)
    {
        Proposal storage proposal = proposals[_proposalIndex];
        require(proposal.votersAmountOfVotes[_voter] != 0, "VOTER_VOTES_NOT_FOUND");
        return proposal.votersAmountOfVotes[_voter];
    }
    function getVoterRefAmount(uint256 _proposalIndex, address _voter)
        external
        view
        returns (uint256)
    {
        Proposal storage proposal = proposals[_proposalIndex];
        require(proposal.refAmount[_voter] != 0, "VOTER_REF_NOT_FOUND");
        return proposal.refAmount[_voter];
    }
    function getVoterVoteIndex(uint256 _proposalIndex, address _voter)
        external
        view
        returns (uint256)
    {
        Proposal storage proposal = proposals[_proposalIndex];
        require(proposal.votersIndex[_voter] != 0, "VOTER_INDEX_NOT_FOUND");
        return proposal.votersIndex[_voter];
    }
    function amountOfVotesRequired(uint256 _proposalIndex)
        external
        view
        returns (uint256)
    {
        Proposal storage proposal = proposals[_proposalIndex];
        return proposal.amountOfVotesRequired;
    }

    // The following two functions allow the contract to accept ETH deposits
    // directly from a wallet without calling a function
    receive() external payable {}

    fallback() external payable {}
}
