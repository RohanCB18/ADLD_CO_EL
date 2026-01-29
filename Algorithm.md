# AES-128 Encryption Algorithm

This document explains the **Advanced Encryption Standard (AES-128)** encryption process step-by-step as implemented in this project.

---

## What is AES?

**AES (Advanced Encryption Standard)** is a symmetric block cipher algorithm adopted by the U.S. National Institute of Standards and Technology (NIST) in 2001. It is the successor to DES and is now the most widely used encryption standard worldwide.

### Key Characteristics

| Property | Value |
|----------|-------|
| **Type** | Symmetric Block Cipher |
| **Block Size** | 128 bits (16 bytes) |
| **Key Sizes** | 128, 192, or 256 bits |
| **Standard** | FIPS 197 (Federal Information Processing Standard) |
| **Adoption** | November 26, 2001 |

---

## What Type of AES Are We Using?

This project implements **AES-128 in ECB (Electronic Codebook) mode**:

| Specification | Detail |
|---------------|--------|
| **Key Length** | 128 bits (16 bytes) |
| **Block Size** | 128 bits (16 bytes) |
| **Number of Rounds** | 10 |
| **Mode of Operation** | ECB (Electronic Codebook) |
| **Implementation** | Verilog HDL for FPGA/ASIC |

> [!NOTE]
> AES-128 uses a 128-bit key and performs 10 rounds of transformation. AES-192 uses 12 rounds, and AES-256 uses 14 rounds.

---

## The AES-128 State Matrix

AES operates on a **4×4 matrix of bytes** called the "state." The 128-bit input is arranged as:

```
| S0,0  S0,1  S0,2  S0,3 |     | Byte 0   Byte 4   Byte 8   Byte 12 |
| S1,0  S1,1  S1,2  S1,3 | --> | Byte 1   Byte 5   Byte 9   Byte 13 |
| S2,0  S2,1  S2,2  S2,3 |     | Byte 2   Byte 6   Byte 10  Byte 14 |
| S3,0  S3,1  S3,2  S3,3 |     | Byte 3   Byte 7   Byte 11  Byte 15 |
```

---

## Step-by-Step Encryption Process

### Overview Flow

```
┌──────────────────────────────────────────────────────────┐
│                     PLAINTEXT (128 bits)                 │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│           INITIAL ROUND: AddRoundKey (Key 0)             │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│                    ROUNDS 1-9 (Loop)                     │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  1. SubBytes    → S-Box substitution                │ │
│  │  2. ShiftRows   → Byte position shifting            │ │
│  │  3. MixColumns  → Galois Field multiplication       │ │
│  │  4. AddRoundKey → XOR with round key                │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│                   FINAL ROUND (Round 10)                 │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  1. SubBytes    → S-Box substitution                │ │
│  │  2. ShiftRows   → Byte position shifting            │ │
│  │  3. AddRoundKey → XOR with round key                │ │
│  └─────────────────────────────────────────────────────┘ │
│  (NO MixColumns in final round)                          │
└──────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────┐
│                     CIPHERTEXT (128 bits)                │
└──────────────────────────────────────────────────────────┘
```

---

### Step 0: Key Expansion

Before encryption begins, the **128-bit key is expanded** into **11 round keys** (176 bytes total).

**Process:**
1. The original 128-bit key forms the first round key (words W[0] to W[3])
2. For each subsequent round key (words W[4] to W[43]):
   - Every 4th word undergoes: **RotWord → SubWord → XOR with Rcon**
   - Other words are XOR of previous word and word 4 positions back

**Round Constants (Rcon):**
| Round | Rcon (Hex) |
|-------|------------|
| 1 | 0x01 |
| 2 | 0x02 |
| 3 | 0x04 |
| 4 | 0x08 |
| 5 | 0x10 |
| 6 | 0x20 |
| 7 | 0x40 |
| 8 | 0x80 |
| 9 | 0x1B |
| 10 | 0x36 |

---

### Step 1: Initial AddRoundKey

The plaintext is **XORed with the first round key** (the original key).

```
State = Plaintext ⊕ Round_Key_0
```

This is the only operation before the main rounds begin.

---

### Step 2: SubBytes (Byte Substitution)

Each byte in the state is replaced using the **S-Box** (Substitution Box).

**How it works:**
- The S-Box is a 256-entry lookup table
- Each byte value (0x00 to 0xFF) maps to another byte
- The S-Box is constructed using:
  1. Multiplicative inverse in GF(2⁸)
  2. Affine transformation

**Example:**
```
Input:  0x00 → Output: 0x63
Input:  0x53 → Output: 0xED
Input:  0xFF → Output: 0x16
```

**Purpose:** Provides non-linearity to the cipher, preventing linear cryptanalysis.

---

### Step 3: ShiftRows (Row Shifting)

Bytes in each row are **cyclically shifted** to the left:

| Row | Shift Amount |
|-----|--------------|
| Row 0 | No shift (0 positions) |
| Row 1 | Shift left by 1 byte |
| Row 2 | Shift left by 2 bytes |
| Row 3 | Shift left by 3 bytes |

**Visual representation:**
```
Before:                     After:
| S0,0  S0,1  S0,2  S0,3 |   | S0,0  S0,1  S0,2  S0,3 |  (no change)
| S1,0  S1,1  S1,2  S1,3 |   | S1,1  S1,2  S1,3  S1,0 |  (shift 1)
| S2,0  S2,1  S2,2  S2,3 |   | S2,2  S2,3  S2,0  S2,1 |  (shift 2)
| S3,0  S3,1  S3,2  S3,3 |   | S3,3  S3,0  S3,1  S3,2 |  (shift 3)
```

**Purpose:** Provides diffusion by spreading bytes across columns.

---

### Step 4: MixColumns (Column Mixing)

Each column is transformed using **Galois Field (GF(2⁸)) matrix multiplication**:

**Fixed Matrix:**
```
| 2  3  1  1 |   | b0 |   | b'0 |
| 1  2  3  1 | × | b1 | = | b'1 |
| 1  1  2  3 |   | b2 |   | b'2 |
| 3  1  1  2 |   | b3 |   | b'3 |
```

**Operations:**
- Multiplication by 2: Left shift, XOR with 0x1B if overflow (bit 7 set)
- Multiplication by 3: Multiply by 2, then XOR with original
- Addition: XOR operation

**Purpose:** Provides diffusion by mixing bytes within each column.

> [!IMPORTANT]
> MixColumns is **NOT performed** in the final round (Round 10).

---

### Step 5: AddRoundKey

The state is **XORed with the round key**:

```
State = State ⊕ Round_Key_i    (for round i)
```

**Purpose:** Incorporates the key material into the encryption process.

---

### Final Round (Round 10)

The final round performs only:
1. **SubBytes**
2. **ShiftRows**
3. **AddRoundKey**

**MixColumns is skipped** in the final round because:
- It simplifies decryption (symmetric structure)
- It doesn't add security for the final round

---

## Complete Round Structure

| Round | SubBytes | ShiftRows | MixColumns | AddRoundKey |
|-------|:--------:|:---------:|:----------:|:-----------:|
| Initial | - | - | - | ✓ |
| Round 1 | ✓ | ✓ | ✓ | ✓ |
| Round 2 | ✓ | ✓ | ✓ | ✓ |
| Round 3 | ✓ | ✓ | ✓ | ✓ |
| Round 4 | ✓ | ✓ | ✓ | ✓ |
| Round 5 | ✓ | ✓ | ✓ | ✓ |
| Round 6 | ✓ | ✓ | ✓ | ✓ |
| Round 7 | ✓ | ✓ | ✓ | ✓ |
| Round 8 | ✓ | ✓ | ✓ | ✓ |
| Round 9 | ✓ | ✓ | ✓ | ✓ |
| Round 10 | ✓ | ✓ | ✗ | ✓ |

---

## Security Properties

| Property | Description |
|----------|-------------|
| **Confusion** | SubBytes operation obscures the relationship between ciphertext and key |
| **Diffusion** | ShiftRows and MixColumns spread each input bit's influence across output |
| **Key Schedule** | Ensures each round uses a different key, preventing slide attacks |

---

## Example Encryption

Using NIST test vectors:

```
Key:        5b7e151628aed2a6abf7158809cf4f3c
Plaintext:  4256f6a8885a308d313198a2e0370734
Ciphertext: 3925841d02dc09fbdc118597196a0b32
```

---

## References

- [NIST FIPS 197 - AES Standard](https://csrc.nist.gov/publications/detail/fips/197/final)
- [AES on Wikipedia](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard)
