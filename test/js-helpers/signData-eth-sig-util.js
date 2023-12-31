const ethSigUtil = require('@metamask/eth-sig-util');
const { bufferToHex } = require('ethereumjs-util');

const typedData = {
    domain: {
        name: 'Your Contract Name', // Replace with your contract's name
        version: 'Your Contract Version', // Replace with your contract's version
        chainId: 31337, // Replace with the correct chain ID
        verifyingContract: '0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f', // Replace with your contract's address
    },
    types: {
        MintIntent: [
            { name: 'creator', type: 'address' },
            { name: 'signer', type: 'address' },
            { name: 'priceModel', type: 'address' },
            { name: 'uri', type: 'string' }
        ],
        // Include EIP712Domain type definition
        EIP712Domain: [
            { name: 'name', type: 'string' },
            { name: 'version', type: 'string' },
            { name: 'chainId', type: 'uint256' },
            { name: 'verifyingContract', type: 'address' },
        ],
    },
    primaryType: "MintIntent",
    message: {
        creator: '0x2190d584E30F4a2396C1487Aa784428f2068CBE8', // Replace with actual data
        signer: '0x6E12D8C87503D4287c294f2Fdef96ACd9DFf6bd2',  // Replace with actual data
        priceModel: '0x790387f168aD5aDd8a056C4f1965ed9bcc0619f6',  // Replace with actual data
        uri: 'some-uri'  // Replace with actual data
    }
};

const signature = ethSigUtil.signTypedData({
    privateKey: 0xf9fc766a27e844ad50c0e567e921d5d2cb661560d2bd2421f3db0c0f0a8e4364n,
    data: typedData,
    version: 'V4' // Using version V4 for full EIP-712 support
});

console.log(signature);

// Check if the signature has the correct length (132 characters, including the '0x' prefix)
if (signature.length !== 132) {
    throw new Error('Invalid signature length');
}

// Extract r, s, and v
const r = signature.substring(0, 66); // '0x' + first 64 characters
const s = "0x" + signature.substring(66, 130); // '0x' + next 64 characters
const v = "0x" + signature.substring(130, 132); // last 2 characters

console.log("r:", r);
console.log("s:", s);
console.log("v:", v);
