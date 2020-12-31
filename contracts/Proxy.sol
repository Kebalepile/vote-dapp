// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Voters.sol";
import "./Proposals.sol";
import "./functools.sol";

contract Proxy is Voters, Proposals, functools {
    // functions
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    function proposeProxy(address proxy_) public isRegistered {
        address[] storage proxies_ = proxies[msg.sender];

        for (uint256 i = 0; i < proxies_.length; i++) {
            if (proxies_[i] == proxy_) {
                emit isAlreadyProxy(
                    proxy_,
                    msg.sender,
                    "proposed proxy is already a proxy of current right holder"
                );
                return;
            }
        }

        proxies_.push(proxy_);
        proxies[msg.sender] = proxies_;

        if (!hasProxy[msg.sender]) {
            hasProxy[msg.sender] = true;
        }

        emit proxy(msg.sender, proxy_, "new proxy added");
    }

    function voteByProxy(
        address rightHolder,
        string memory topic,
        string memory dateVoted,
        uint256 number,
        address proposedBy
    ) public isProxyAndCanVote(rightHolder) {
        Proposition[] storage proposedProposals = proposalsPutForward[topic];

        for (uint256 i = 0; i < proposedProposals.length; i++) {
            if (proposedProposals[i].proposedBy == proposedBy) {
                proposedProposals[i].votedForBy += 1;
                votedForProposals[rightHolder].push(
                    VotedFor({
                        topic: topic,
                        voteCount: 1,
                        proposalNumber: number,
                        proposedBy: proposedProposals[i].proposedBy,
                        dateVoted: dateVoted,
                        viaProxy: true
                    })
                );

                votedForTopic[topic].push(rightHolder);
                votedViaProxy[rightHolder][topic] = msg.sender;
                emit proxyVotedForProposal(rightHolder, "you've voted.", topic);

                return;
            }
        }
    }

    function removedProxy(address proxy_) public isRegistered {
        require(
            hasProxy[msg.sender] == true,
            "msg.sender does not have a proxy"
        );
        address[] memory proxies_ = proxies[msg.sender];
        uint256 index;
        bool found;

        for (uint256 i = 0; i < proxies_.length; i++) {
            if (proxies_[i] == proxy_) {
                index = i;
                found = true;
                break;
            }
        }

        if (found == true) {
            if (index == 0) {
                address[] memory slice1 = slice(index, 1, proxies_);
                address[] memory slice2;
                if (slice1.length != (proxies_.length - 1)) {
                    slice2 = slice(index + 1, proxies_.length + 1, proxies_);
                }
                // remove in produciton.
                require(
                    (slice1.length + slice2.length) == proxies_.length,
                    "503 internal Error, array slices length problem."
                );
                uint256 total = slice1.length + slice2.length;
                uint256 i = 0;
                uint256 ii = 0;

                while (total != 0) {
                    if (i <= slice1.length) {
                        proxies_[i] = slice1[i];
                    } else {
                        if (ii == 0) {
                            ii = i;
                        }
                        proxies_[i] = slice2[i - ii];
                    }

                    total--;
                    i += 1;
                }
            }
            proxies[msg.sender] = proxies_;
            emit proxyRemoved(
                proxy_,
                msg.sender,
                "proxy address is removed from current right holder, proxies"
            );

            return;
        }
        emit isNotProxy(
            proxy_,
            msg.sender,
            "address is not registerd as current  right holders proxy"
        );
    }

    // modifiers
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    modifier isProxyAndCanVote(address rightHolder) {
        require(hasProxy[rightHolder], "rightHolder has no proxy");

        bool isProxy;

        address[] memory proxies_ = proxies[rightHolder];

        for (uint256 i = 0; i <= proxies_.length; i++) {
            if (proxies_[i] == msg.sender) {
                isProxy = true;
                break;
            }
        }

        require(isProxy == true, "You are not a proxy");
        _;
    }

    // mappings
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    mapping(address => bool) public hasProxy;
    mapping(address => address[]) public proxies;
    mapping(address => mapping(string => address)) public votedViaProxy;

    // Events
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    // *******************************************************************
    event proxy(
        address indexed rightHolder,
        address indexed proxy,
        string message
    );

    event isAlreadyProxy(address proxy, address rightHolder, string message);
    event proxyRemoved(address proxy, address rightHolder, string message);
    event isNotProxy(address proxy, address rightHolder, string message);
    event proxyVotedForProposal(address proxy, string topic, string message);
}
