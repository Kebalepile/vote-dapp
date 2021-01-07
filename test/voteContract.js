const VoteContract = artifacts.require("Main.sol");
const web3 = require("web3");
const date = require("../functools/Date.js");
contract("Vote Contract", function (accounts) {
  let owner = accounts[0],
    chairMan = accounts[1],
    ContractInstance;

  before("initiate Vote Contract", async () => {
    ContractInstance = await VoteContract.deployed();
  });

  context("has set owner and chairman", () => {
    it("should have contract owner", async () => {
      const address = await ContractInstance.owner();
      assert.equal(
        address,
        owner,
        "retrived address is not of pre-determined owner."
      );
    });

    it("should have chairman", async () => {
      const address = await ContractInstance.chairMan();
      assert.equal(address, chairMan),
        "retrived address is not of pre-determined chairman";
    });
  });

  context("Agenda Topics", () => {
    it("should add topic to agenda mapping", async () => {
      const topics = ["online learning in 2021", "how to train indoors"];

      for await (let topic of topics) {
        ContractInstance.submitTopic(topic, { from: owner });
      }
      const bool = await ContractInstance.openForProposal(topics[0]);

      assert.equal(bool, true, "topic not open for proposals");
    });
    it("should return topic at given key from mapping", async () => {
      const topic = await ContractInstance.topicsOnAgenda(1, {
        from: accounts[3],
      });

      assert.equal(topic, "how to train indoors", "not pre-determined topic.");
    });

    it("should remove topic from agenda mapping", async () => {
      await ContractInstance.removeTopic(0, { from: owner });
      const message = await ContractInstance.topicsOnAgenda(0, {
        from: accounts[9],
      });

      assert.equal(
        message,
        "topic removed.",
        "did not receive pre-determined message."
      );
    });
  });
  context("Register", () => {
    it("should register public address", async () => {
      for await (let account of accounts.slice(2)) {
        const { logs } = await ContractInstance.register(account, {
          from: account,
        });

        const { voter } = logs[0].args;
        assert.equal(
          logs[0].event,
          "voterRegistered",
          "unexpected event emitted"
        );
        assert.equal(voter, account, "not expected registered voter address.");
      }
    });

    it("should have registered all 10 accounts", async () => {
      const numOfVoters = await ContractInstance.numberOfVoters({
        from: accounts[7],
      });

      assert.equal(numOfVoters, 10, "faild to register all voters.");
    });
  });

  context("Submit proposal", () => {
    it("should submit proposal", () => {
      [
        ["how to train indoors", "learn parkour", accounts[5]],
        ["how to train indoors", "take zoombar classes.", accounts[8]],
        ["how to train indoors", "use kitosis diet.", accounts[7]],
      ].forEach(async (ary) => {
        let { logs } = await ContractInstance.submitProposal(
          ary[0],
          date(),
          ary[1],
          { from: ary[2] }
        );
        assert.equal(logs[0].args.candidate, ary[2], "not required address.");
      });
    });
  });

  context("Vote on submitted proposals", () => {
    it("All 10 accounts should vote", () => {
     const topic = "how to train indoors";

      vote(accounts.slice(0, 6), topic, accounts[5]);
      vote(accounts.slice(6, 8), topic, accounts[7]);
      vote(accounts.slice(8), topic, accounts[8]);

      function vote(accounts, topic, address) {
        accounts.forEach(async (account) => {
          let { logs } = await ContractInstance.vote(topic, address, date(), {
            from: account,
          });

          // assert.equal(logs[0].args.voter, account);
          const yes = await ContractInstance.voted(account, topic, {
            from: account,
          });

          assert.equal(yes, true);
        });
      }
    });
  });

  context("Approved proposal is", () => {
    it("Should return winner proposition of given topic", async () => {
      let putForwardProposal = new Map();
      const topic = "how to train indoors";
      for (let acc of accounts) {
        let yes = await ContractInstance.putForwardProposal(acc, { from: acc });

        if (yes) {
          let proposal = await ContractInstance.readProposition(acc, topic, {
            from: acc,
          });

          putForwardProposal.set(acc, {
            address: acc,
            votes: 0,
            proposal,
          });
        }
      }

      for (let acc of accounts) {
        let address = await ContractInstance.votedFor(acc, topic, {
          from: acc,
        });

        let obj = putForwardProposal.get(address);

        putForwardProposal.set(address, {
          ...obj,
          votes: obj.votes + 1,
        });
      }
      let winner = {
        address: null,
        votes: 0,
        proposal: null,
      };
      for (let value of putForwardProposal.values()) {
        if (value.votes > winner.votes) {
          winner = value;
        }
      }

      console.log("Winner is \n");
      console.table(winner);
    });
  });
});
