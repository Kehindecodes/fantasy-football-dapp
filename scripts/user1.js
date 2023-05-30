const { ethers } = require('hardhat');
const abi = require('./contractABI');

async function main() {
	// Connect to the deployed contract using its address
	const contractAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
	const provider = new ethers.providers.JsonRpcProvider();
	// Get the list of available accounts
	const accounts = await ethers.getSigners();

	// Access the first account (index 0)
	const signer = accounts[0];

	// Retrieve the account address
	const accountAddress = await signer.getAddress();

	const userContract = new ethers.Contract(contractAddress, abi, signer);

	// get accounts
	console.log(accountAddress);

	// Interact with the contract methods
	const registerTx = await userContract.registerUser('kehinde');
	await registerTx.wait();

	const kehinde = await userContract.getUser(accountAddress);
	console.log('Registered user:', kehinde);

	console.log('logging user...');
	const loginTx = await userContract.login();
	await loginTx.wait();

	const loggedIn = await userContract.isLoggedIn(accountAddress);
	console.log('Is user logged in?', loggedIn);

	const balanceUpdateTx = await userContract.updateBalance(100);
	await balanceUpdateTx.wait();
	const balance = await userContract.getBalance(accountAddress);
	console.log('User balance:', balance);

	console.log('Updating user points...');
	const updatePointsTx = await userContract.updatePoints(150);
	await updatePointsTx.wait();

	const userPoints = await userContract.getUserPoints(accountAddress);
	console.log('User points:', userPoints);

	console.log('Fetching leaderboard...');
	const [addresses, points] = await userContract.getLeaderBoard();
	console.log('Leaderboard:');
	for (let i = 0; i < addresses.length; i++) {
		console.log(`Address: ${addresses[i]}, Points: ${points[i]}`);
	}
	console.log('Fetching user leaderboard position...');
	const userPosition = await userContract.getUserLeaderboardPosition(
		accountAddress,
	);
	console.log('User leaderboard position:', userPosition);

	// console.log('logging out...');
	// const logoutTx = await userContract.logout();
	// await logoutTx.wait();

	// const loggedOut = await userContract.isLoggedIn(deployer.address);
	// console.log('Is user logged in?', loggedOut);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
