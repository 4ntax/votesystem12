// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract VotingSystem {
    address public admin;
    bool public votingOpen;

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    mapping(uint => Candidate) public candidates;
    uint public candidatesCount;

    mapping(address => bool) public hasVoted;

    event CandidateRegistered(uint id, string name);
    event VoteCast(address indexed voter, uint candidateId);
    event VotingStatusChanged(bool open);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier whenVotingOpen() {
        require(votingOpen, "Voting is not open");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerCandidate(string memory _name) external onlyAdmin {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateRegistered(candidatesCount, _name);
    }

    function startVoting() external onlyAdmin {
        votingOpen = true;
        emit VotingStatusChanged(true);
    }

    function endVoting() external onlyAdmin {
        votingOpen = false;
        emit VotingStatusChanged(false);
    }

    function vote(uint _candidateId) external whenVotingOpen {
        require(!hasVoted[msg.sender], "Already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate");

        hasVoted[msg.sender] = true;
        candidates[_candidateId].voteCount++;

        emit VoteCast(msg.sender, _candidateId);
    }

    function getWinner() external view returns (uint winnerId, string memory name, uint voteCount) {
        uint maxVotes = 0;
        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerId = i;
            }
        }
        Candidate memory winner = candidates[winnerId];
        return (winner.id, winner.name, winner.voteCount);
    }
}
