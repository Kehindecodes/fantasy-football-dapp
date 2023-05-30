async function main() {
	const [deployer] = await ethers.getSigners();

	// Compile and deploy the User contract
	const User = await ethers.getContractFactory('User');
	const userContract = await User.deploy();
	await userContract.deployed();

	console.log(`contract is deployed on : ${userContract.address}`);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
