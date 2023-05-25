const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('User', function () {
	let user;
	let wallet;
	before(async function () {
		const User = await ethers.getContractFactory('User');
		user = await User.deploy();
		await user.deployed();

		const [connectedWallet] = await ethers.getSigners(); // Get the connected wallet
		wallet = connectedWallet.connect(user); // Connect the wallet to the deployed contract
		console.log(user);
	});

	it('should register a new user', async function () {
		const username = 'Alice';
		const txn = await wallet.registerUser(username);
		expect(txn.hash).to.not.be.null;

		const userData = await wallet.getUser(txn.from);
		expect(userData.username).to.equal(username);
		expect(userData.isLoggedIn).to.equal(false);
	});

	it('should log in a user', async function () {
		expect(await wallet.isLoggedIn()).to.equal(false);

		await wallet.login();

		expect(await wallet.isLoggedIn()).to.equal(true);
	});

	it('should log out a user', async function () {
		expect(await wallet.isLoggedIn()).to.equal(true);

		await wallet.logout();

		expect(await wallet.isLoggedIn()).to.equal(false);
	});

	it('should update the balance of a user', async function () {
		const initialBalance = await wallet.getBalance();
		expect(initialBalance).to.equal(0);

		await wallet.updateBalance(100);

		const updatedBalance = await wallet.getBalance();
		expect(updatedBalance).to.equal(100);
	});
});
