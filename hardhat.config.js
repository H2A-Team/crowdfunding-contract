const { APP_CONFIGS } = require("./configs");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts",
    },
    defaultNetwork: APP_CONFIGS.defaultNetwork,
    networks: {
        sepolia: {
            url: APP_CONFIGS.sepolia.url,
            accounts: [`0x${APP_CONFIGS.sepolia.key}`],
        },
    },
    solidity: {
        version: "0.8.17",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
};
