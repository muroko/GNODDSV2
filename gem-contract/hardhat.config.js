require("@nomiclabs/hardhat-waffle");
require("hardhat-abi-exporter");

/**
 * @type import('hardhat/config').HardhatUserConfig
*/

//GemNodesV2_Dev Mainnet Deployer Addr: 0x350db736C992d907aC663Fd2D00e54728b6CBE77
/** */
//const AVALANCHE_TEST_PRIVATE_KEY = "INPUT-PRIVATE-KEY-HERE"; 
const AVALANCHE_MAIN_PRIVATE_KEY = "GO FUCK YOURSELF LOSER!!!";

module.exports = {
	solidity: {
		compilers: [
			{
				version: "0.8.0",
				settings: {
					optimizer: {
						enabled: true,
						runs: 200,
					},
				},
			},
			{
				version: "0.8.2",
				settings: {
					optimizer: {
						enabled: true,
						runs: 200,
					},
				},
			},
			{
				version: "0.6.2",
				settings: {
					optimizer: {
						enabled: true,
						runs: 200,
					},
				},
			}
		],
	},
	abiExporter: {
		path: './abi',
		runOnCompile: true,
	},
	networks: {
		//avalancheTest: {
			//url: 'https://api.avax-test.network/ext/bc/C/rpc',
			/**gasPrice: 225000000000,*/
			//chainId: 43113,
			//accounts: [`0x${AVALANCHE_TEST_PRIVATE_KEY}`]
		//},
		avalancheMain : {
			url: "https://api.avax.network/ext/bc/C/rpc",
			/**gasPrice: 225000000000,*/
			chainId: 43114,
			accounts: [`0x${AVALANCHE_MAIN_PRIVATE_KEY}`]
		},
	},
};


