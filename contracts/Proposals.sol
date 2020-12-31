// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Voters.sol";

contract Proposals is Voters {
    bool public openForPrposal;

    // functions
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************

    function SubmitProposal(
        string memory topic,
        string memory dateProposed,
        string memory proposal
    ) public isRegistered proposalsAllowed {
        Proposition[] storage proposedProposals = proposalsPutForward[topic];

        for (uint256 i = 0; i < proposedProposals.length; i++) {
            if (proposedProposals[i].proposedBy == msg.sender) {
                proposedProposals[i].propositions.push(proposal);
                proposedProposals[i].dateProposed = dateProposed;
                proposalsPutForward[topic] = proposedProposals;
                emit ProposalsUpdated(
                    msg.sender,
                    "you've put forward another proposal"
                );

                return;
            }
        }

        string[] memory proposals;
        proposals[0] = proposal;

        proposedProposals.push(
            Proposition({
                propositions: proposals,
                proposedBy: msg.sender,
                picked: false,
                dateProposed: dateProposed,
                datePicked: "N/A",
                votedForBy: 0
            })
        );
        emit newProposal(msg.sender, "you've put forward a new proposal");
    }

    function approvedProposal(
        string memory topic_ // returns ( //     uint256 votes, //     string memory proposedBy, //     string memory proposal // )
    ) public view {
        address[] memory voters = votedForTopic[topic_];

        for (uint256 i = 0; i <= voters.length; i++) {
            VotedFor[] memory proposalsVotedFor = votedForProposals[voters[i]];

            for (uint256 j = 0; j <= proposalsVotedFor.length; j++) {
                // if(proposalsVotedFor[j][topic_] == topic_){
                // }
            }
        }
    }

    // modifiers
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************

    modifier proposalsAllowed() {
        require(
            openForPrposal == true,
            "Due date for proposal acceptence is closed."
        );
        _;
    }

    // structs
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************

    // mappings
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************

    //  events
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************

    event newProposal(address indexed candidate, string indexed message);
    event ProposalsUpdated(address indexed candiate, string indexed message);
}
