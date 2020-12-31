// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Voters {
    uint256 public numberOfVoters;

    // functions
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    function Register(address candidate) public isRegisteredNot(candidate) {
        registeredVoter[candidate] = true;
        numberOfVoters += 1;
        emit voterRegistered(candidate);
    }

    function vote(
        string memory topic,
        address proposedBy,
        uint256 number,
        string memory dateVoted
    ) public isRegistered alreadyVotedForTopic(topic) {
        Proposition[] storage proposedProposals = proposalsPutForward[topic];

        for (uint256 i = 0; i < proposedProposals.length; i++) {
            if (proposedProposals[i].proposedBy == proposedBy) {
                proposedProposals[i].votedForBy += 1;
                votedForProposals[msg.sender].push(
                    VotedFor({
                        topic: topic,
                        voteCount: 1,
                        proposalNumber: number,
                        proposedBy: proposedProposals[i].proposedBy,
                        dateVoted: dateVoted,
                        viaProxy: false
                    })
                );

                votedForTopic[topic].push(msg.sender);

                emit votedForProposal(msg.sender, "you've voted.", topic);

                return;
            }
        }
    }

    // modefiers
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    modifier isRegisteredNot(address candidate) {
        require(
            registeredVoter[candidate] == false,
            "candidate is registered, no need to re-register."
        );
        _;
    }

    modifier isRegistered() {
        require(
            registeredVoter[msg.sender],
            "You are not registered, Register first."
        );
        _;
    }
    modifier alreadyVotedForTopic(string memory topicName) {
        bool votedFor;

        address[] memory voters = votedForTopic[topicName];
        for (uint256 i = 0; i <= voters.length; i++) {
            if (voters[i] == msg.sender) {
                votedFor = true;
                break;
            }
        }
        require(votedFor == false, "alread voted for a proposal");
        _;
    }
    // structs
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    struct Proposition {
        string[] propositions;
        address proposedBy;
        bool picked;
        uint256 votedForBy;
        string dateProposed;
        string datePicked;
    }
    struct VotedFor {
        string topic;
        uint256 voteCount;
        uint256 proposalNumber;
        address proposedBy;
        string dateVoted;
        bool viaProxy;
    }

    // mappings
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    mapping(address => bool) internal registeredVoter;
    mapping(string => address[]) public votedForTopic;
    mapping(string => Proposition[]) public proposalsPutForward;
    mapping(address => VotedFor[]) public votedForProposals;

    // events
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************

    event voterRegistered(address indexed voter);
    event votedForProposal(address, string, string);
}
