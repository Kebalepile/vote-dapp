const VoteContract = artifacts.require('Main.sol');
module.exports = (deployer) => {
	deployer.deploy(VoteContract, '0x979564017ecee100b844a8c5289bceedcc4d2e54');
};
