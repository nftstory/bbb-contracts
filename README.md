# bbb

bbb is an online megamall where all the products are digital! Post a product for free and earn creator fees when collectors trade it. 

## Deployed contracts

BBB deployer address https://explorer.degen.tips/address/0xBBB38c30E57a9FEf6068778caB91f1a0D4948BBb

### Degen

BBB.sol on Degen https://explorer.degen.tips/address/0x216848610fA858Ee4975356A9de627C18B479eF9
BBB AlmostLinearPriceCurve.sol v1 (original Base parameters) https://explorer.degen.tips/address/0xD26b595a322c789B9deF3479D960591C10094f08
BBB AlmostLinearPriceCurve.sol v2 (parameters adjusted for DEGEN: 3, 1, 6_090_909_090_909_090_909) https://explorer.degen.tips/address/0xa79956C2b65BE14Cb78761B51BB23053AB9a1494

## Build instructions

To test: `forge test`

To build: `forge build`

To simulate Deploy: `forge script script/Deploy.s.sol --rpc-url $GOERLI_RPC_URL`

To deploy and verify: `forge script script/Deploy.s.sol --rpc-url $BASE_SEPOLIA_RPC_URL --etherscan-api-key $BASESCAN_API_KEY --broadcast --verify`

think you found a bug? t.me/ nnnnicholas 

## License

MIT

© nftstory limited 2024

𝓟𝓮𝓻𝓶𝓲𝓼𝓼𝓲𝓸𝓷 𝓲𝓼 𝓱𝓮𝓻𝓮𝓫𝔂 𝓰𝓻𝓪𝓷𝓽𝓮𝓭, 𝓯𝓻𝓮𝓮 𝓸𝓯 𝓬𝓱𝓪𝓻𝓰𝓮, 𝓽𝓸 𝓪𝓷𝔂 𝓹𝓮𝓻𝓼𝓸𝓷 𝓸𝓫𝓽𝓪𝓲𝓷𝓲𝓷𝓰 𝓪 𝓬𝓸𝓹𝔂 𝓸𝓯 𝓽𝓱𝓲𝓼 𝓼𝓸𝓯𝓽𝔀𝓪𝓻𝓮 𝓪𝓷𝓭 𝓪𝓼𝓼𝓸𝓬𝓲𝓪𝓽𝓮𝓭 𝓭𝓸𝓬𝓾𝓶𝓮𝓷𝓽𝓪𝓽𝓲𝓸𝓷 𝓯𝓲𝓵𝓮𝓼 (𝓽𝓱𝓮 “𝓢𝓸𝓯𝓽𝔀𝓪𝓻𝓮”), 𝓽𝓸 𝓭𝓮𝓪𝓵 𝓲𝓷 𝓽𝓱𝓮 𝓢𝓸𝓯𝓽𝔀𝓪𝓻𝓮 𝔀𝓲𝓽𝓱𝓸𝓾𝓽 𝓻𝓮𝓼𝓽𝓻𝓲𝓬𝓽𝓲𝓸𝓷, 𝓲𝓷𝓬𝓵𝓾𝓭𝓲𝓷𝓰 𝔀𝓲𝓽𝓱𝓸𝓾𝓽 𝓵𝓲𝓶𝓲𝓽𝓪𝓽𝓲𝓸𝓷 𝓽𝓱𝓮 𝓻𝓲𝓰𝓱𝓽𝓼 𝓽𝓸 𝓾𝓼𝓮, 𝓬𝓸𝓹𝔂, 𝓶𝓸𝓭𝓲𝓯𝔂, 𝓶𝓮𝓻𝓰𝓮, 𝓹𝓾𝓫𝓵𝓲𝓼𝓱, 𝓭𝓲𝓼𝓽𝓻𝓲𝓫𝓾𝓽𝓮, 𝓼𝓾𝓫𝓵𝓲𝓬𝓮𝓷𝓼𝓮, 𝓪𝓷𝓭/𝓸𝓻 𝓼𝓮𝓵𝓵 𝓬𝓸𝓹𝓲𝓮𝓼 𝓸𝓯 𝓽𝓱𝓮 𝓢𝓸𝓯𝓽𝔀𝓪𝓻𝓮, 𝓪𝓷𝓭 𝓽𝓸 𝓹𝓮𝓻𝓶𝓲𝓽 𝓹𝓮𝓻𝓼𝓸𝓷𝓼 𝓽𝓸 𝔀𝓱𝓸𝓶 𝓽𝓱𝓮 𝓢𝓸𝓯𝓽𝔀𝓪𝓻𝓮 𝓲𝓼 𝓯𝓾𝓻𝓷𝓲𝓼𝓱𝓮𝓭 𝓽𝓸 𝓭𝓸 𝓼𝓸, 𝓼𝓾𝓫𝓳𝓮𝓬𝓽 𝓽𝓸 𝓽𝓱𝓮 𝓯𝓸𝓵𝓵𝓸𝔀𝓲𝓷𝓰 𝓬𝓸𝓷𝓭𝓲𝓽𝓲𝓸𝓷𝓼:𝓣𝓱𝓮 𝓪𝓫𝓸𝓿𝓮 𝓬𝓸𝓹𝔂𝓻𝓲𝓰𝓱𝓽 𝓷𝓸𝓽𝓲𝓬𝓮 𝓪𝓷𝓭 𝓽𝓱𝓲𝓼 𝓹𝓮𝓻𝓶𝓲𝓼𝓼𝓲𝓸𝓷 𝓷𝓸𝓽𝓲𝓬𝓮 𝓼𝓱𝓪𝓵𝓵 𝓫𝓮 𝓲𝓷𝓬𝓵𝓾𝓭𝓮𝓭 𝓲𝓷 𝓪𝓵𝓵 𝓬𝓸𝓹𝓲𝓮𝓼 𝓸𝓻 𝓼𝓾𝓫𝓼𝓽𝓪𝓷𝓽𝓲𝓪𝓵 𝓹𝓸𝓻𝓽𝓲𝓸𝓷𝓼 𝓸𝓯 𝓽𝓱𝓮 𝓢𝓸𝓯𝓽𝔀𝓪𝓻𝓮.𝓣𝓗𝓔 𝓢𝓞𝓕𝓣𝓦𝓐𝓡𝓔 𝓘𝓢 𝓟𝓡𝓞𝓥𝓘𝓓𝓔𝓓 “𝓐𝓢 𝓘𝓢”, 𝓦𝓘𝓣𝓗𝓞𝓤𝓣 𝓦𝓐𝓡𝓡𝓐𝓝𝓣𝓨 𝓞𝓕 𝓐𝓝𝓨 𝓚𝓘𝓝𝓓, 𝓔𝓧𝓟𝓡𝓔𝓢𝓢 𝓞𝓡 𝓘𝓜𝓟𝓛𝓘𝓔𝓓, 𝓘𝓝𝓒𝓛𝓤𝓓𝓘𝓝𝓖 𝓑𝓤𝓣 𝓝𝓞𝓣 𝓛𝓘𝓜𝓘𝓣𝓔𝓓 𝓣𝓞 𝓣𝓗𝓔 𝓦𝓐𝓡𝓡𝓐𝓝𝓣𝓘𝓔𝓢 𝓞𝓕 𝓜𝓔𝓡𝓒𝓗𝓐𝓝𝓣𝓐𝓑𝓘𝓛𝓘𝓣𝓨, 𝓕𝓘𝓣𝓝𝓔𝓢𝓢 𝓕𝓞𝓡 𝓐 𝓟𝓐𝓡𝓣𝓘𝓒𝓤𝓛𝓐𝓡 𝓟𝓤𝓡𝓟𝓞𝓢𝓔 𝓐𝓝𝓓 𝓝𝓞𝓝𝓘𝓝𝓕𝓡𝓘𝓝𝓖𝓔𝓜𝓔𝓝𝓣. 𝓘𝓝 𝓝𝓞 𝓔𝓥𝓔𝓝𝓣 𝓢𝓗𝓐𝓛𝓛 𝓣𝓗𝓔 𝓐𝓤𝓣𝓗𝓞𝓡𝓢 𝓞𝓡 𝓒𝓞𝓟𝓨𝓡𝓘𝓖𝓗𝓣 𝓗𝓞𝓛𝓓𝓔𝓡𝓢 𝓑𝓔 𝓛𝓘𝓐𝓑𝓛𝓔 𝓕𝓞𝓡 𝓐𝓝𝓨 𝓒𝓛𝓐𝓘𝓜, 𝓓𝓐𝓜𝓐𝓖𝓔𝓢 𝓞𝓡 𝓞𝓣𝓗𝓔𝓡 𝓛𝓘𝓐𝓑𝓘𝓛𝓘𝓣𝓨, 𝓦𝓗𝓔𝓣𝓗𝓔𝓡 𝓘𝓝 𝓐𝓝 𝓐𝓒𝓣𝓘𝓞𝓝 𝓞𝓕 𝓒𝓞𝓝𝓣𝓡𝓐𝓒𝓣, 𝓣𝓞𝓡𝓣 𝓞𝓡 𝓞𝓣𝓗𝓔𝓡𝓦𝓘𝓢𝓔, 𝓐𝓡𝓘𝓢𝓘𝓝𝓖 𝓕𝓡𝓞𝓜, 𝓞𝓤𝓣 𝓞𝓕 𝓞𝓡 𝓘𝓝 𝓒𝓞𝓝𝓝𝓔𝓒𝓣𝓘𝓞𝓝 𝓦𝓘𝓣𝓗 𝓣𝓗𝓔 𝓢𝓞𝓕𝓣𝓦𝓐𝓡𝓔 𝓞𝓡 𝓣𝓗𝓔 𝓤𝓢𝓔 𝓞𝓡 𝓞𝓣𝓗𝓔𝓡 𝓓𝓔𝓐𝓛𝓘𝓝𝓖𝓢 𝓘𝓝 𝓣𝓗𝓔 𝓢𝓞𝓕𝓣𝓦𝓐𝓡𝓔.

# Template Info

For instructions about what's included in the Foundry Template this is based on, see the
[documentation](https://github.com/PaulRBerg/foundry-template).

## Installation

### Install Foundry

Call `curl -L https://foundry.paradigm.xyz | bash`

Call `foundryup` to update Foundry.

### Install Dependencies

Dependencies are managed with pnpm. Install dependencies with `pnpm i`

### Adding Dependencies

Add dependencies from npm like so: `pnpm add @openzeppelin/contracts`

## Usage

This is a list of the most frequently needed commands.

### Build

Build the contracts:

```sh
$ forge build
```

### Clean

Delete the build artifacts and cache directories:

```sh
$ forge clean
```

### Compile

Compile the contracts:

```sh
$ forge build
```

### Coverage

Get a test coverage report:

```sh
$ forge coverage
```

### Deploy

Deploy to Goerli:

You can simulate this before doing it for real by removing `--broadcast`.

```sh
forge script script/Deploy.s.sol --rpc-url $GOERLI_RPC_URL --broadcast --verify
```

Deploy to Anvil:

```sh
$ forge script script/Deploy.s.sol --broadcast --fork-url http://localhost:8545
```

For this script to work, you need to have a `MNEMONIC` environment variable set to a valid
[BIP39 mnemonic](https://iancoleman.io/bip39/).

For instructions on how to deploy to a testnet or mainnet, check out the
[Solidity Scripting](https://book.getfoundry.sh/tutorials/solidity-scripting.html) tutorial.


### Testing

To generate a signature for use against deployed instances of the contract, first mutate the chainId and deployed contract address in `/scripts/GenerateSignature.s.sol`, then call

```sh
forge script script/GenerateSignature.s.solure
```

### Format

Format the contracts:

```sh
$ forge fmt
```

### Gas Usage

Get a gas report:

```sh
$ forge test --gas-report
```

### Lint

Lint the contracts:

```sh
$ pnpm lint
```

### Test

Run the tests:

```sh
$ forge test
```

Generate test coverage and output result to the terminal:

```sh
$ pnpm test:coverage
```

Generate test coverage with lcov report (you'll have to open the `./coverage/index.html` file in your browser, to do so
simply copy paste the path):

```sh
$ pnpm test:coverage:report
```

### GitHub Actions

This template comes with GitHub Actions pre-configured. Your contracts will be linted and tested on every push and pull
request made to the `main` branch.

You can edit the CI script in [.github/workflows/ci.yml](./.github/workflows/ci.yml).

## Writing Tests

To write a new test contract, you start by importing [PRBTest](https://github.com/PaulRBerg/prb-test) and inherit from
it in your test contract. PRBTest comes with a pre-instantiated [cheatcodes](https://book.getfoundry.sh/cheatcodes/)
environment accessible via the `vm` property. If you would like to view the logs in the terminal output you can add the
`-vvv` flag and use [console.log](https://book.getfoundry.sh/faq?highlight=console.log#how-do-i-use-consolelog).

This template comes with an example test contract [Foo.t.sol](./test/Foo.t.sol)

## License

This project is licensed under MIT.
