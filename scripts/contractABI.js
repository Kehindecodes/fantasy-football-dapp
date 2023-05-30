module.exports = [
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: 'address',
				name: 'userAddress',
				type: 'address',
			},
			{
				indexed: false,
				internalType: 'uint256',
				name: 'newBalance',
				type: 'uint256',
			},
		],
		name: 'BalanceUpdated',
		type: 'event',
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: 'address',
				name: 'userAddress',
				type: 'address',
			},
		],
		name: 'UserLoggedIn',
		type: 'event',
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: 'address',
				name: 'userAddress',
				type: 'address',
			},
		],
		name: 'UserLoggedOut',
		type: 'event',
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: 'address',
				name: 'userAddress',
				type: 'address',
			},
			{
				indexed: false,
				internalType: 'uint256',
				name: 'totalPoints',
				type: 'uint256',
			},
		],
		name: 'UserPointsUpdated',
		type: 'event',
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: 'address',
				name: 'userAddress',
				type: 'address',
			},
			{
				indexed: false,
				internalType: 'string',
				name: 'username',
				type: 'string',
			},
		],
		name: 'UserRegistered',
		type: 'event',
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: '_userAddress',
				type: 'address',
			},
		],
		name: 'getBalance',
		outputs: [
			{
				internalType: 'uint256',
				name: '',
				type: 'uint256',
			},
		],
		stateMutability: 'view',
		type: 'function',
	},
	{
		inputs: [],
		name: 'getLeaderBoard',
		outputs: [
			{
				internalType: 'address[]',
				name: '',
				type: 'address[]',
			},
			{
				internalType: 'uint256[]',
				name: '',
				type: 'uint256[]',
			},
		],
		stateMutability: 'view',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: '_userAddress',
				type: 'address',
			},
		],
		name: 'getUser',
		outputs: [
			{
				components: [
					{
						internalType: 'address',
						name: 'userAddress',
						type: 'address',
					},
					{
						internalType: 'string',
						name: 'username',
						type: 'string',
					},
					{
						internalType: 'uint256',
						name: 'balance',
						type: 'uint256',
					},
					{
						internalType: 'bool',
						name: 'isLoggedIn',
						type: 'bool',
					},
					{
						internalType: 'uint256',
						name: 'totalPoints',
						type: 'uint256',
					},
				],
				internalType: 'struct User.UserData',
				name: '',
				type: 'tuple',
			},
		],
		stateMutability: 'view',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: '_userAddress',
				type: 'address',
			},
		],
		name: 'getUserLeaderboardPosition',
		outputs: [
			{
				internalType: 'uint256',
				name: '',
				type: 'uint256',
			},
		],
		stateMutability: 'view',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: '_userAddress',
				type: 'address',
			},
		],
		name: 'getUserPoints',
		outputs: [
			{
				internalType: 'uint256',
				name: '',
				type: 'uint256',
			},
		],
		stateMutability: 'view',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'address',
				name: '_userAddress',
				type: 'address',
			},
		],
		name: 'isLoggedIn',
		outputs: [
			{
				internalType: 'bool',
				name: '',
				type: 'bool',
			},
		],
		stateMutability: 'view',
		type: 'function',
	},
	{
		inputs: [],
		name: 'login',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function',
	},
	{
		inputs: [],
		name: 'logout',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'string',
				name: '_username',
				type: 'string',
			},
		],
		name: 'registerUser',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'uint256',
				name: '_newBalance',
				type: 'uint256',
			},
		],
		name: 'updateBalance',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function',
	},
	{
		inputs: [
			{
				internalType: 'uint256',
				name: '_points',
				type: 'uint256',
			},
		],
		name: 'updatePoints',
		outputs: [],
		stateMutability: 'nonpayable',
		type: 'function',
	},
];
