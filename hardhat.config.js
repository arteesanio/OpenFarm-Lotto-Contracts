require("@nomiclabs/hardhat-waffle");
require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const ALCHEMY_API_URL = process.env.ALCHEMY_API_URL;
// const ALCHEMY_PRIVATE_KEY = process.env.ALCHEMY_PRIVATE_KEY;
// const RINKEBY_PRIVATE_KEY = process.env.RINKEBY_PRIVATE_KEY;
// const RINKEBY_URL = process.env.RINKEBY_URL;

// const alchemy = { url: ALCHEMY_API_URL, accounts: [ALCHEMY_PRIVATE_KEY], timeout: 100000, }
// const rinkeby = { url: ALCHEMY_API_URL, accounts: [RINKEBY_PRIVATE_KEY], timeout: 100000, }

const POLYGON_URL = process.env.POLYGON_URL;
const POLYGONSCAN_KEY = process.env.POLYGONSCAN_KEY;
const POLYGON_PRIVATE_KEY = process.env.POLYGON_PRIVATE_KEY;
const polygon = { url: ALCHEMY_API_URL, accounts: [POLYGON_PRIVATE_KEY], timeout: 100000, }
// const MUMBAI_PRIVATE_KEY = process.env.MUMBAI_PRIVATE_KEY;
// const MUMBAI_URL = process.env.MUMBAI_URL;
// const mumbai = { url: ALCHEMY_API_URL, accounts: [MUMBAI_PRIVATE_KEY], timeout: 100000, }


module.exports = {
	solidity: "0.8.4",
	// defaultNetwork: "polygon",
	mocha: {
	  timeout: 60000
	},
	networks: {
	  // rinkeby,
	  // alchemy,
	  // mumbai,
	  polygon,
	},
	  etherscan: {
	    apiKey: {
	      polygonMumbai: POLYGONSCAN_KEY,
	    },
	  },
};
