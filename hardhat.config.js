require("@nomiclabs/hardhat-waffle");
require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const RINKEBY_PRIVATE_KEY = process.env.RINKEBY_PRIVATE_KEY;
const ALCHEMY_API_KEY_URL = process.env.ALCHEMY_API_KEY_URL;

const rinkeby = { url: ALCHEMY_API_KEY_URL, accounts: [RINKEBY_PRIVATE_KEY], timeout: 100000, }

const MUMBAI_PRIVATE_KEY = process.env.MUMBAI_PRIVATE_KEY;

const POLYGONSCAN_KEY = process.env.POLYGONSCAN_KEY;
const mumbai = { url: ALCHEMY_API_KEY_URL, accounts: [MUMBAI_PRIVATE_KEY], timeout: 100000, }

module.exports = {
	solidity: "0.8.11",
	defaultNetwork: "mumbai",
	mocha: {
	  timeout: 60000
	},
	networks: {
	  // rinkeby,
	  mumbai,
	},
	  etherscan: {
	    apiKey: {
	      polygonMumbai: POLYGONSCAN_KEY,
	    },
	  },
};
