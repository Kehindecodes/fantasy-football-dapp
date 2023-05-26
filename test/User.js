const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('User Contract', function () {
	let userContract;
	let deployer;

	before(async function () {
		this.timeout(60000);
		const User = await ethers.getContractFactory('User');
		const signers = await ethers.getSigners();
		deployer = signers[0];
		userContract = await User.deploy();
		await userContract.deployed();
	});

	it('should register a user', async function () {
		await userContract.registerUser('Alice');
		const alice = await userContract.getUser(deployer.address);
		expect(alice.username).to.equal('Alice');
	});

	it('should log in and out a user', async function () {
		await userContract.login();
		const loggedIn = await userContract.isLoggedIn(deployer.address);
		expect(loggedIn).to.be.true;
	});

	it('should update user balance', async function () {
		await userContract.updateBalance(100);
		const balance = await userContract.getBalance(deployer.address);
		expect(balance).to.equal(100);
	});
	it('should log out a user', async function () {
		await userContract.logout();
		const loggedOut = await userContract.isLoggedIn(deployer.address);
		expect(loggedOut).to.be.false;
	});

	it('should update user points and retrieve leaderboard position', async function () {
		await userContract.updatePoints(50);
		const points = await userContract.getUserPoints(deployer.address);
		expect(points).to.equal(50);

		const leaderboardPosition = await userContract.getUserLeaderboardPosition(
			deployer.address,
		);
		expect(leaderboardPosition).to.equal(1);
	});

	it('should retrieve the leaderboard', async function () {
		const [addresses, points] = await userContract.getLeaderBoard();

		expect(addresses).to.have.lengthOf(1);
		expect(points).to.have.lengthOf(1);
		expect(addresses[0]).to.equal(deployer.address);
		expect(points[0]).to.equal(50);
	});
});
