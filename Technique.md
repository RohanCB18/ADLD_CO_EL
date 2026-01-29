# AES-128 Technical Implementation Details

This document provides technical details of the AES-128 encryption implementation in Verilog HDL.

---

## Implementation Architecture

### Design Philosophy

This implementation uses a **fully unrolled, pipelined architecture**:

| Aspect | Design Choice |
|--------|---------------|
| **Architecture** | Fully unrolled (all 10 rounds instantiated) |
| **Timing** | Combinational logic with clock synchronization |
| **S-Box Implementation** | Lookup table (256 × 8-bit entries) |
| **Key Expansion** | Pre-computed round keys (all 11 keys generated in parallel) |
| **Throughput** | One encryption per clock cycle (after pipeline fills) |

---

## Module Hierarchy

```
encryption (aes_top_module.v)
├── key_expansion (aes_key_expansion.v)
│   ├── round_constant (aes_round_constant.v)
│   └── sbox × 40 instances (aes_substitution_box.v)
│
├── round × 9 instances (aes_round.v)
│   ├── sub_bytes (aes_sub_bytes.v)
│   │   └── sbox × 16 instances
│   ├── shift_rows (aes_shift_rows.v)
│   └── mix_column (aes_mix_columns.v)
│       └── mul_32 × 4 instances (aes_galois_multiply_32bit.v)
│           ├── mul_2 × 4 instances (aes_galois_multiply_by_2.v)
│           └── mul_3 × 4 instances (aes_galois_multiply_by_3.v)
│
└── last_round (aes_final_round.v)
    ├── sub_bytes (aes_sub_bytes.v)
    └── shift_rows (aes_shift_rows.v)
```

---

## Signal Specifications

### Top-Level Interface

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `clk` | Input | 1 bit | System clock |
| `i_Key` | Input | 128 bits | Secret encryption key |
| `i_Plain_Text` | Input | 128 bits | Data to encrypt |
| `o_Cipher_Text` | Output | 128 bits | Encrypted output |

### Internal Wire Naming Convention

| Prefix | Meaning |
|--------|---------|
| `w_` | Wire signal |
| `r_` | Register signal |
| `i_` | Input port |
| `o_` | Output port |

---

## Key Expansion Implementation

### Algorithm

The key expansion generates 44 words (W[0] to W[43]) from the 128-bit input key:

```verilog
// Initial key words
W[0] = Key[127:96]
W[1] = Key[95:64]
W[2] = Key[63:32]
W[3] = Key[31:0]

// For i = 4 to 43:
if (i mod 4 == 0):
    W[i] = W[i-4] ⊕ SubWord(RotWord(W[i-1])) ⊕ Rcon[i/4]
else:
    W[i] = W[i-4] ⊕ W[i-1]
```

### Round Constant Implementation

```verilog
// Rcon values based on GF(2^8) with polynomial x^8 + x^4 + x^3 + x + 1
case(i)
    4'h0: rcon = 8'h01;  // x^0 = 1
    4'h1: rcon = 8'h02;  // x^1
    4'h2: rcon = 8'h04;  // x^2
    4'h3: rcon = 8'h08;  // x^3
    4'h4: rcon = 8'h10;  // x^4
    4'h5: rcon = 8'h20;  // x^5
    4'h6: rcon = 8'h40;  // x^6
    4'h7: rcon = 8'h80;  // x^7
    4'h8: rcon = 8'h1b;  // x^8 mod p(x) = x^4 + x^3 + x + 1
    4'h9: rcon = 8'h36;  // x^9 mod p(x)
endcase
```

---

## S-Box Implementation

### Technical Details

| Aspect | Implementation |
|--------|----------------|
| **Size** | 256 entries × 8 bits |
| **Logic** | Combinational case statement |
| **Latency** | 0 clock cycles (pure combinational) |
| **Area** | ~256 bytes of LUT |

### Mathematical Basis

The S-Box is constructed in two steps:

1. **Multiplicative Inverse** in GF(2⁸):
   - S(x) = x⁻¹ in GF(2⁸) with irreducible polynomial x⁸ + x⁴ + x³ + x + 1
   - S(0) = 0 (special case)

2. **Affine Transformation**:
   ```
   b'ᵢ = bᵢ ⊕ b₍ᵢ₊₄₎ mod 8 ⊕ b₍ᵢ₊₅₎ mod 8 ⊕ b₍ᵢ₊₆₎ mod 8 ⊕ b₍ᵢ₊₇₎ mod 8 ⊕ cᵢ
   ```
   where c = 0x63

---

## Galois Field Multiplication

### GF(2⁸) Operations

The irreducible polynomial used is: **x⁸ + x⁴ + x³ + x + 1** (0x11B)

### Multiplication by 2 (xtime)

```verilog
function xtime(b):
    if (b[7] == 1):
        return (b << 1) ⊕ 0x1B
    else:
        return (b << 1)
```

### Multiplication by 3

```verilog
function mul_3(b):
    return xtime(b) ⊕ b    // (2 × b) ⊕ b = 3 × b
```

### MixColumns Matrix Multiplication

For each column [a₀, a₁, a₂, a₃]:

```verilog
b₀ = (2·a₀) ⊕ (3·a₁) ⊕ a₂ ⊕ a₃
b₁ = a₀ ⊕ (2·a₁) ⊕ (3·a₂) ⊕ a₃
b₂ = a₀ ⊕ a₁ ⊕ (2·a₂) ⊕ (3·a₃)
b₃ = (3·a₀) ⊕ a₁ ⊕ a₂ ⊕ (2·a₃)
```

---

## ShiftRows Mapping

### Byte Position Transformation

| Input Position | Output Position |
|----------------|-----------------|
| Byte 0 (127:120) | Byte 0 via Byte 4 position |
| Byte 1 (119:112) | Byte 1 via Byte 5 position |
| Byte 2 (111:104) | Byte 2 via Byte 6 position |
| ... | ... |

### Implementation

```verilog
// Row 0: No shift
o_Data[127:120] <= i_Data[127:120];  // Column 0, Row 0
o_Data[103:96]  <= i_Data[103:96];   // Column 1, Row 0
...

// Row 1: Shift left by 1
o_Data[119:112] <= i_Data[87:80];    // Shifts from column 1 to 0
...

// Row 2: Shift left by 2
// Row 3: Shift left by 3
```

---

## Timing Analysis

### Pipeline Stages

| Stage | Operation | Clock Cycles |
|-------|-----------|--------------|
| Key Expansion | All 11 keys generated | 0 (combinational) |
| Initial AddRoundKey | XOR with Key₀ | 0 (combinational) |
| Round 1-9 | SubBytes + ShiftRows + MixColumns + AddRoundKey | 1 per round |
| Final Round | SubBytes + ShiftRows + AddRoundKey | 1 |
| **Total Latency** | | ~10 clock cycles |

### Resource Estimation

| Resource | Approximate Usage |
|----------|-------------------|
| S-Box LUTs | 256 × 16 instances = 4096 entries |
| XOR Gates | ~5000 |
| Registers | ~1400 bits (per pipeline stage) |

---

## Verification

### NIST Test Vector

```
Key:       5b7e151628aed2a6abf7158809cf4f3c
Plaintext: 4256f6a8885a308d313198a2e0370734
Expected:  3925841d02dc09fbdc118597196a0b32
```

### Testbench Execution

```bash
# Compile
make

# Simulate
make simulate

# View waveforms
make display
```

---

## Code File Reference Table

| File | Module Name | Description |
|------|-------------|-------------|
| [aes_top_module.v](hdl/aes_top_module.v) | `encryption` | **Top-level module** that connects all components. Takes 128-bit plaintext and key, outputs 128-bit ciphertext. Instantiates key expansion, 9 standard rounds, and 1 final round. |
| [aes128_nist.v](hdl/aes128_nist.v) | `aes128_encrypt` | **Alternative NIST-compliant implementation** using pure combinational logic with Verilog functions. Compact single-file implementation for testing/reference. |
| [aes_nist_wrapper.v](hdl/aes_nist_wrapper.v) | `aes_wrapper` | **NIST wrapper module** providing a standardized interface to the AES-128 encryption module for integration purposes. |
| [aes_key_expansion.v](hdl/AES/aes_key_expansion.v) | `key_expansion` | **Key schedule generator** that expands the 128-bit key into 11 round keys (44 words: W[0]-W[43]). Uses S-Box and Rcon for key derivation. |
| [aes_round.v](hdl/AES/aes_round.v) | `round` | **Standard encryption round** (Rounds 1-9). Chains SubBytes → ShiftRows → MixColumns → AddRoundKey operations. |
| [aes_final_round.v](hdl/AES/aes_final_round.v) | `last_round` | **Final encryption round** (Round 10). Same as standard round but **omits MixColumns step**. |
| [aes_sub_bytes.v](hdl/AES/aes_sub_bytes.v) | `sub_bytes` | **Byte substitution transformation**. Applies S-Box to all 16 bytes of the state matrix using 16 parallel S-Box instances. |
| [aes_substitution_box.v](hdl/AES/aes_substitution_box.v) | `sbox` | **Substitution box (S-Box)**. 256-entry lookup table implementing multiplicative inverse in GF(2⁸) followed by affine transformation. |
| [aes_shift_rows.v](hdl/AES/aes_shift_rows.v) | `shift_rows` | **Row shifting transformation**. Cyclically shifts rows 1, 2, 3 by 1, 2, 3 positions respectively. Row 0 unchanged. |
| [aes_mix_columns.v](hdl/AES/aes_mix_columns.v) | `mix_column` | **Column mixing transformation**. Applies GF(2⁸) matrix multiplication to each column. Uses 4 instances of 32-bit multiplier. |
| [aes_galois_multiply_32bit.v](hdl/AES/aes_galois_multiply_32bit.v) | `mul_32` | **32-bit Galois Field column multiplier**. Computes the MixColumns matrix multiplication for one column (4 bytes). |
| [aes_galois_multiply_by_2.v](hdl/AES/aes_galois_multiply_by_2.v) | `mul_2` | **xtime operation**. Multiplies a byte by 2 in GF(2⁸). Left shift with conditional XOR of 0x1B on overflow. |
| [aes_galois_multiply_by_3.v](hdl/AES/aes_galois_multiply_by_3.v) | `mul_3` | **Multiply by 3 in GF(2⁸)**. Computes (2×b) ⊕ b using mul_2 and XOR operations. |
| [aes_round_constant.v](hdl/AES/aes_round_constant.v) | `round_constant` | **Round constants (Rcon) generator**. Provides 10 round constants for key expansion: 01, 02, 04, 08, 10, 20, 40, 80, 1B, 36. |
| [aes_encryption_testbench.v](test/aes_encryption_testbench.v) | `encryption_test` | **Testbench module**. Validates encryption using NIST test vectors. Generates VCD waveform for debugging. |

---

## Project Structure Summary

```
ADLD_CO_EL/
├── hdl/                              # Verilog source files
│   ├── aes_top_module.v              # Main encryption module
│   ├── aes128_nist.v                 # NIST-compliant reference implementation
│   ├── aes_nist_wrapper.v            # Interface wrapper
│   └── AES/                          # Sub-modules folder
│       ├── aes_substitution_box.v    # S-Box (256 entries)
│       ├── aes_sub_bytes.v           # 16-byte parallel S-Box application
│       ├── aes_shift_rows.v          # Row shifting
│       ├── aes_mix_columns.v         # Column mixing
│       ├── aes_round.v               # Standard round (Rounds 1-9)
│       ├── aes_final_round.v         # Final round (Round 10)
│       ├── aes_key_expansion.v       # Key schedule
│       ├── aes_round_constant.v      # Rcon values
│       ├── aes_galois_multiply_by_2.v   # GF(2^8) multiply by 2
│       ├── aes_galois_multiply_by_3.v   # GF(2^8) multiply by 3
│       └── aes_galois_multiply_32bit.v  # 32-bit column multiplication
├── test/
│   └── aes_encryption_testbench.v    # Verification testbench
├── assets/
│   └── view.jpg                      # Block diagram
├── Makefile                          # Build automation
├── README.md                         # Project overview
├── Algorithm.md                      # Encryption algorithm explanation
└── Technique.md                      # This file - Technical details
```
