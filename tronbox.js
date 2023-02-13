module.exports = {
  networks: {
    main: {
      privateKey: process.env.PRIVATE_KEY,
      fullHost: "https://api.trongrid.io",
      network_id: "1",
    },
    compilers: {
      solc: {
        version: "0.6.8",
      },
    },
  },
  // solc compiler optimize
  solc: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
    evmVersion: "istanbul",
  },
};
