const HDWalletProvider = require("@truffle/hdwallet-provider");
const mnemonic = process.env.MNEUMONIC;
module.exports = {

    networks: {

        development: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "*",
            gas: 9500000
        },

        mainnet: {
            provider: function() {
                return new HDWalletProvider(mnemonic, "https://mainnet.infura.io/v3/<YOUR_INFURA_API_KEY>")
            },
            network_id: "1"
        },

        rinkeby: {
            provider: function() {
                return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/abcc19e38a814ff3b9145209e6d1891c")
            },
            network_id: 4
        },

          },
    compilers: {
        solc: {
            version: "0.5.5"
        }
    }
};
