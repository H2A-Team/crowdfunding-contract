const APP_CONFIGS = {
    defaultNetwork: process.env.NETWORK || "sepolia",

    sepolia: {
        url: process.env.SEPOLIA_URL || "",
        key: process.env.SEPOLIA_KEY || "",
    },
};

Object.freeze(APP_CONFIGS);

module.exports = {
    APP_CONFIGS,
};
