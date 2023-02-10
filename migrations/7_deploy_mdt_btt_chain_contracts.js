const MDT_e = artifacts.require('MDT_e')
const MDT_t = artifacts.require('MDT_t')

const utils = require('./utils')

module.exports = async(deployer, network, accounts) => {
  deployer.then(async() => {
    await deployer.deploy(MDT_e, 'Measurable Data Token_Ethereum', 'MDT_e', 18, "0x9a15F3a682d086C515be4037BDA3B0676203A8ef")
    console.log("MDT_e.address", MDT_e.address)
    await deployer.deploy(MDT_t, 'Measurable Data Token_TRON', 'MDT_t', 18, "0x9a15F3a682d086C515be4037BDA3B0676203A8ef", MDT_e.address)
    console.log("MDT_t.address", MDT_t.address)

    const contractAddresses = utils.getContractAddresses()

    contractAddresses.child.MDT_e = MDT_e.address
    contractAddresses.child.MDT_t = MDT_t.address

    utils.writeContractAddresses(contractAddresses)
  })
}
