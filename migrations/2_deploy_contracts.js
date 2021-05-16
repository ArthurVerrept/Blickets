// eslint-disable-next-line no-undef
const Ticket = artifacts.require('Ticket')

module.exports = function (deployer) {
  deployer.deploy(Ticket)
}
