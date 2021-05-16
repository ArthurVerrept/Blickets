# Blickets
What is "insert name", the thinking behind this idea was to use blockchain tech to store users event tickets. But why store users tickets on the blockchain? Simple, If everyone knows who has what ticket, theres no way you could scam people when selling them. The whole idea is to give event hosts control of the life of their tickets after they sell them.

Working template for vue+ts+eslint with solidity smart contract running on local ganache blockchain

## What you need:



1. [Ganache](https://www.trufflesuite.com/ganache)
<br>Only required if you want to run contract locally. (must be running if you plan on running the blockchain locally /want to run tests on your contract)

2. [MetaMask Extension](https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn?hl=en)

## Set up:

Install the project's server packages.

```bash
> npm i
```

<strong>IMPORTANT: You must be running node version 11+ for tailwind to work!</strong>

## Deploying Smart Contracts:
Once you get to this section you have two choices, either deploy <strong>and</strong> run the contract on your local network (recommended for local development). Or use the already deployed contract on rinkeby (this will require you to have an account with "ether" on it from the rinkeby network
<a href="https://faucet.rinkeby.io/"> <u>get ether for rinkeby here</u></a>).
<br>
<br>
if you are planning to use the rinkeby network you can <strong>skip the deployment step.</strong>

### Locally:
if you choose to host your contract locally please ensure that ganache is running before running this command.
This uses the first account on your local ganache blockchain to deploy the contract
```bash
# this should be ran when first creating a contract
> truffle migrate

# this should be ran when updating a contract
> truffle migrate --reset
```

This command is locked to the owner of the command and so is only for arthur to remember it exists
### Rinkeby:
```bash
# to deploy smart contract on rinkeby testnet
> truffle migrate --network rinkeby
```


Once your smart contract is running on your local blockchain, start the client by running.

```bash
# if you are running the contract locally
> npm run serve:local

# if you are using the contract on rinkeby
> npm run serve:rinkeby
```

## Side notes:

If you want to interact with a locally deployed contract without having to use the client you can enter the truffle console.

```bash
> truffle console
> contract = await [myContract].deployed()
```

this will set up a variable with the name "contract" within that console you use to interact with the contract. You can then interact with the functions withing the contract.

```bash
> contract.symbol
```

## Testing:

to test the smart contract:

```bash
> npm run test
```


## Technologies:

### 1. Smart Contract
<ul>
<li>Solidity </li>
<li>OpenZepplin</li>
<li>Solc</li>
<li>Truffle</li>
</ul>

### 2. Client
<ul>
<li>Vue</li>
<li>Web3</li>
<li>Tailwind</li>
<li>Eslint</li>
<li>Chai</li>
</ul>

### 3. Tests
<ul>
<li>Mocha</li>
</ul>
