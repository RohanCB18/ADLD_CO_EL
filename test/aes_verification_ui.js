import { hexToBytes, bytesToHex, encryptBlockWithTrace } from '../frontend/src/lib/aes128.js';

const PLAINTEXT = "00112233445566778899aabbccddeeff";
const KEY = "000102030405060708090a0b0c0d0e0f";
const EXPECTED_CIPHER = "69 c4 e0 d8 6a 7b 04 30 d8 cd b7 80 70 b4 c5 5a";

console.log("Running AES-128 FIPS-197 Test Vector...");
console.log(`Plaintext: ${PLAINTEXT}`);
console.log(`Key:       ${KEY}`);

try {
    const ptBytes = hexToBytes(PLAINTEXT);
    const keyBytes = hexToBytes(KEY);
    const result = encryptBlockWithTrace(ptBytes, keyBytes);
    const cipherHex = bytesToHex(result.cipherState, " ");

    console.log(`Expected:  ${EXPECTED_CIPHER}`);
    console.log(`Actual:    ${cipherHex}`);

    if (cipherHex === EXPECTED_CIPHER) {
        console.log("RESULT: SUCCESS");
    } else {
        console.log("RESULT: FAILURE");
        process.exit(1);
    }
} catch (error) {
    console.error("An error occurred during encryption:", error);
    process.exit(1);
}
