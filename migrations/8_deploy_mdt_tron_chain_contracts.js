const MDT = artifacts.require('MDT')

const utils = require('./utils')

module.exports = async(deployer, network, accounts) => {
  deployer.then(async() => {
    await deployer.deploy(MDT, 'Measurable Data Token', 'MDT')

    const contractAddresses = utils.getContractAddresses()

    contractAddresses.root.MDT = MDT.address

    utils.writeContractAddresses(contractAddresses)
  })
}
