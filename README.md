# AES-128 Encryption in Verilog

This project implements the **Advanced Encryption Standard (AES)** using Verilog HDL. AES is a widely-used encryption method that keeps data secure by scrambling it using a secret key.

## What is AES?

**AES (Advanced Encryption Standard)** is like a digital lock for your data:
- You have a **key** (like a password) - 128 bits (16 characters)
- You have **data** (what you want to protect) - 128 bits
- AES **scrambles** your data so only someone with the key can read it

Think of it like putting your message in a locked box - only someone with the same key can open it!

---

## How AES Works (Simple Explanation)

AES uses **10 rounds** of scrambling to make the encryption strong. Each round does 4 things:

| Step | What it Does | Real-World Analogy |
|------|-------------|-------------------|
| **1. SubBytes** | Replaces each byte using a lookup table (S-Box) | Like changing letters using a secret codebook |
| **2. ShiftRows** | Moves bytes to different positions | Like rearranging deck chairs |
| **3. MixColumns** | Mixes data within columns using math | Like blending colors together |
| **4. AddRoundKey** | Combines data with the secret key | Like adding your signature |

> **Note:** The last round skips MixColumns (step 3)

---

## Project Structure

```
AES/
├── hdl/                              # Verilog source files
│   ├── aes_top_module.v              # Main encryption module (connects everything)
│   └── AES/                          # Sub-modules folder
│       ├── aes_substitution_box.v    # S-Box lookup table (256 entries)
│       ├── aes_sub_bytes.v           # Applies S-Box to all 16 bytes
│       ├── aes_shift_rows.v          # Shifts row positions
│       ├── aes_mix_columns.v         # Column mixing operation
│       ├── aes_round.v               # One complete round (rounds 1-9)
│       ├── aes_final_round.v         # Last round (no MixColumns)
│       ├── aes_key_expansion.v       # Generates 11 round keys from main key
│       ├── aes_round_constant.v      # Constants used in key expansion
│       ├── aes_galois_multiply_by_2.v  # Math: multiply by 2 in GF(2^8)
│       ├── aes_galois_multiply_by_3.v  # Math: multiply by 3 in GF(2^8)
│       └── aes_galois_multiply_32bit.v # 32-bit multiplication for MixColumns
├── test/
│   └── aes_encryption_testbench.v    # Test file to verify encryption works
├── assets/
│   └── view.jpg                      # AES structure diagram
├── Makefile                          # Build and run commands
└── README.md                         # This file
```

---

## AES Structure Diagram

![AES Structure](assets/view.jpg)

---

## How to Run This Project

### Prerequisites
1. Install **Icarus Verilog** (Verilog compiler)
   - Windows: Download from [http://bleyer.org/icarus/](http://bleyer.org/icarus/)
   - macOS: `brew install icarus-verilog`
   - Linux: `sudo apt install iverilog`

2. Install a waveform viewer (to see signals):
   - **GTKWave** (free): [http://gtkwave.sourceforge.net/](http://gtkwave.sourceforge.net/)
   - **Scansion** (macOS only): [http://www.logicpoet.com/scansion/](http://www.logicpoet.com/scansion/)

### Running the Simulation

```bash
# Step 1: Compile the Verilog files
make

# Step 2: Run the simulation
make simulate

# Step 3: View the waveform (macOS with Scansion)
make display
```

For Windows/GTKWave, open the `.vcd` file manually:
```bash
gtkwave aes_encryption_testbench.vcd
```

---

## Module Descriptions

| Module | File | What it Does |
|--------|------|-------------|
| **encryption** | `aes_top_module.v` | The main module - takes key + plaintext, outputs ciphertext |
| **key_expansion** | `aes_key_expansion.v` | Creates 11 different keys from your 1 main key |
| **sbox** | `aes_substitution_box.v` | Lookup table - replaces each byte with a new value |
| **sub_bytes** | `aes_sub_bytes.v` | Applies the S-Box to all 16 bytes at once |
| **shift_rows** | `aes_shift_rows.v` | Moves bytes around in a specific pattern |
| **mix_column** | `aes_mix_columns.v` | Mathematical mixing of data |
| **round** | `aes_round.v` | One complete encryption round |
| **last_round** | `aes_final_round.v` | Special final round (no mixing) |
| **round_constant** | `aes_round_constant.v` | Fixed values needed for key expansion |
| **mul_2** | `aes_galois_multiply_by_2.v` | Galois field multiplication by 2 |
| **mul_3** | `aes_galois_multiply_by_3.v` | Galois field multiplication by 3 |
| **mul_32** | `aes_galois_multiply_32bit.v` | 32-bit Galois field multiplication |

---

## Input/Output Specification

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `clk` | Input | 1 bit | Clock signal |
| `i_Key` | Input | 128 bits | Secret encryption key |
| `i_Plain_Text` | Input | 128 bits | Data to encrypt |
| `o_Cipher_Text` | Output | 128 bits | Encrypted data |

---

## Learn More

- [AES on Wikipedia](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard)
- [NIST AES Standard (PDF)](https://csrc.nist.gov/publications/detail/fips/197/final)

---

## License

This project is for educational purposes.
