async function main() {
	const [deployer] = await ethers.getSigners();

	// Compile and deploy the User contract
	const User = await ethers.getContractFactory('User');
	const userContract = await User.deploy();
	await userContract.deployed();

	// Interact with the contract methods
	const registerTx = await userContract.registerUser('Alice');
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

	console.log('Updating user points...');
	const updatePointsTx = await userContract.updatePoints(50);
	await updatePointsTx.wait();

	const userPoints = await userContract.getUserPoints(deployer.address);
	console.log('User points:', userPoints);

	console.log('Fetching leaderboard...');
	const [addresses, points] = await userContract.getLeaderBoard();
	console.log('Leaderboard:');
	for (let i = 0; i < addresses.length; i++) {
		console.log(`Address: ${addresses[i]}, Points: ${points[i]}`);
	}
	console.log('Fetching user leaderboard position...');
	const userPosition = await userContract.getUserLeaderboardPosition(
		deployer.address,
	);
	console.log('User leaderboard position:', userPosition);

	console.log('logging out...');
	const logoutTx = await userContract.logout();
	await logoutTx.wait();

	const loggedOut = await userContract.isLoggedIn(deployer.address);
	console.log('Is user logged in?', loggedOut);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
