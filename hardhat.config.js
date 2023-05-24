require('@nomicfoundation/hardhat-toolbox');
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
	solidity: '0.8.18',
	networks: {
		polygon_testnet: {
			url: process.env.POLYGON_TESTNET,
			accounts: [process.env.PRIVATE_KEY],
		},
	},
};
