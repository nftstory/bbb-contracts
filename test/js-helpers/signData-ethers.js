const ethers = require('ethers');
require('dotenv').config();

const [name, signingDomainVersion, chainId, verifyingContract, creator, priceModel] = process.argv.slice(2); // Get args from test's ffi call

// const domain = [
//     { name: "name", type: "string" },
//     { name: "version", type: "string" },
//     { name: "chainId", type: "uint256" },
//     { name: "verifyingContract", type: "address" },
// ];

const domain = {
    name: name,
    version: signingDomainVersion,
    chainId: chainId,
    verifyingContract: verifyingContract,
};

const types = {
    MintIntent: [
        { name: "creator", type: "address" },
        { name: "signer", type: "address" },
        { name: "priceModel", type: "address" },
        { name: "uri", type: "string" }
    ],
};
const mnemonicInstance = ethers.Mnemonic.fromPhrase(process.env.SIGNER_MNEMONIC);
const signer = ethers.HDNodeWallet.fromMnemonic(mnemonicInstance, `m/44'/60'/0'/0/0`);


const value = {
    creator: creator,
    signer: signer.address,
    priceModel: priceModel,
    uri: "IPFS_SAMPLE_URI"

};

console.log("Logging:");
// console.log(domain);
// console.log(types);
console.log(signer.address);
// console.log(value);

async function signData(domain, types, value) {
    const wallet = signer;
    const signature = await wallet.signTypedData(domain, types, value);
}

signData(domain, types, value);
