// eslint-disable-next-line no-undef
const Lottery = artifacts.require('Lottery')

module.exports = function (deployer) {
  deployer.deploy(Lottery)
}
