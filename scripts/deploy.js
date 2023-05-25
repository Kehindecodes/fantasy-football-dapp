async function main() {
	const [deployer] = await ethers.getSigners();

	// Compile and deploy the User contract
	const User = await ethers.getContractFactory('User');
	const userContract = await User.deploy();
	await userContract.deployed();

	// Interact with the contract methods
	const registerTx = await userContract.registerUser('Alice', deployer.address);
	await registerTx.wait();

	const alice = await userContract.getUser(deployer.address);
	console.log('Registered user:', alice);

	console.log('logging user...');
	const loginTx = await userContract.login();
	await loginTx.wait();

	const loggedIn = await userContract.isLoggedIn(deployer.address);
	console.log('Is user logged in?', loggedIn);

	const balanceUpdateTx = await userContract.updateBalance(100);
	await balanceUpdateTx.wait();
	const balance = await userContract.getBalance(deployer.address);
	console.log('User balance:', balance);

	console.log('logging out...');
	const logoutTx = await userContract.logout();
	await logoutTx.wait();

	const loggedOut = await userContract.isLoggedIn(deployer.address);
	console.log('Is user logged out?', loggedOut);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
