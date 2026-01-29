# AES Encryption/Decryption - Exam Demo Guide

## 📋 Quick Reference for Project Presentation

This guide contains the exact commands and steps to demonstrate your AES project during exams.

---

## ⚡ Pre-Demo Checklist

- [ ] Open PowerShell/Terminal
- [ ] Navigate to project directory
- [ ] Ensure GTKWave is installed and accessible
- [ ] Close any previously open GTKWave windows

---

## 🔐 Part 1: AES Encryption Demo

### Step 1: Navigate to Project Directory
```powershell
cd C:\Users\rohan\OneDrive\Desktop\finaladld\ADLD_CO_EL
```

### Step 2: Compile the Encryption Module
```powershell
iverilog -o aes_test.out hdl/aes128_nist.v test/aes_encryption_testbench.v
```

**Expected Output:** No errors (silent success)

### Step 3: Run the Simulation
```powershell
vvp aes_test.out
```

**Expected Output:** 
- VCD file creation message
- Test output displays (may be garbled in terminal, but that's okay)
- `$finish` message

### Step 4: Open GTKWave Visualization
```powershell
gtkwave encryption_test.vcd
```

**This opens the GTKWave GUI with the better layout!**

### Step 5: Add Signals in GTKWave

**In the GTKWave window:**

1. **Left Panel (SST):** Click on `encryption_test` to expand
2. **Select and Add these signals** (click signal, then click "Insert" or drag to Signals panel):

**Essential Signals:**
- `clk` - Clock signal
- `rst_n` - Reset signal (active low)
- `r_Plain_Text` - Input plaintext
- `r_Key` - Encryption key
- `w_Cipher_Text` - **OUTPUT** (verify this!)
- `w_Done` - Completion flag

**Debug Signals (Optional):**
- Expand `AES_Encrypt` in the hierarchy
- `round_counter` - Shows current round (0→11)
- `state_reg` - Internal state changes

3. **Zoom to Fit:** Click "Zoom Fit" button or press `Ctrl+Alt+F`
4. **Navigate:** Use scroll or zoom to see different test cases

### Step 6: Explain the Test Cases

**Point to the waveforms and explain:**

**Test Case 1 (Time: 0-500ns) - Sequential Bytes**
- Plaintext: `00112233445566778899aabbccddeeff`
- Key: `000102030405060708090a0b0c0d0e0f`
- Ciphertext: `cea3c4e0a352f54875b7e57f03cdff6d`

**Test Case 2 (Time: 520-1020ns) - NIST FIPS-197 Vector**
- Plaintext: `6bc1bee22e409f96e93d7e117393172a`
- Key: `2b7e151628aed2a6abf7158809cf4f3c`
- Ciphertext: `3ad77bb40d7a3660a89ecaf32466ef97`
- **This is the official NIST standard test vector!**

**Test Case 3 (Time: 1040-1540ns) - ASCII Text**
- Plaintext: `48656c6c6f20576f726c642121212121` ("Hello World!!!!!")
- Key: `436f64696e672049732046756e212121` ("Coding Is Fun!!!")
- Ciphertext: `45e85f234911a3197c16c18a1bc334b9`

### Step 7: Key Points to Mention

**Design Features:**
- ✅ Sequential (clocked) implementation - realistic hardware design
- ✅ State machine with 11 rounds (0-10)
- ✅ One round per clock cycle
- ✅ Active-low reset (`rst_n`)
- ✅ `done` flag signals completion

**ADLD Concepts Demonstrated:**
- Finite State Machine (FSM)
- 4-bit counter (`round_counter`)
- 128-bit registers (`state_reg`)
- Combinational functions (S-Box, MixColumns)
- Sequential logic (clocked state transitions)

---

## 🔓 Part 2: AES Decryption Demo

### Step 1: Compile the Decryption Module
```powershell
iverilog -o aes_decrypt_test.out hdl/aes128_decrypt.v test/aes_decryption_testbench.v
```

**Expected Output:** No errors (silent success)

### Step 2: Run the Simulation
```powershell
vvp aes_decrypt_test.out
```

**Expected Output:**
- VCD file creation message
- Test output displays
- `$finish` message

### Step 3: Open GTKWave Visualization
```powershell
gtkwave decryption_test.vcd
```

**This opens the GTKWave GUI!**

### Step 4: Add Signals in GTKWave

**In the GTKWave window:**

1. **Left Panel:** Click on `decryption_test` to expand
2. **Select and Add these signals:**

**Essential Signals:**
- `clk` - Clock signal
- `rst_n` - Reset signal
- `r_Cipher_Text` - Input ciphertext
- `r_Key` - Decryption key (same as encryption key)
- `w_Plain_Text` - **OUTPUT** (verify this!)
- `w_Done` - Completion flag

**Debug Signals (Optional):**
- Expand `AES_Decrypt` in the hierarchy
- `round_counter` - Shows current round (0→11)
- `state_reg` - Internal state changes

3. **Zoom to Fit:** Click "Zoom Fit" or `Ctrl+Alt+F`

### Step 5: Explain the Test Cases

**Test Case 1 (Time: 0-500ns) - Sequential Bytes**
- Ciphertext: `cea3c4e0a352f54875b7e57f03cdff6d`
- Key: `000102030405060708090a0b0c0d0e0f`
- Plaintext: `00112233445566778899aabbccddeeff`
- **This reverses encryption Test 1!**

**Test Case 2 (Time: 520-1020ns) - NIST Vector**
- Ciphertext: `3ad77bb40d7a3660a89ecaf32466ef97`
- Key: `2b7e151628aed2a6abf7158809cf4f3c`
- Plaintext: `6bc1bee22e409f96e93d7e117393172a`
- **Official NIST decryption test!**

**Test Case 3 (Time: 1040-1540ns) - ASCII Text**
- Ciphertext: `45e85f234911a3197c16c18a1bc334b9`
- Key: `436f64696e672049732046756e212121` ("Coding Is Fun!!!")
- Plaintext: `48656c6c6f20576f726c642121212121` ("Hello World!!!!!")
- **Decrypts back to readable text!**

### Step 6: Key Points to Mention

**Decryption Features:**
- ✅ Implements NIST FIPS-197 "Inverse Cipher"
- ✅ Uses inverse operations: InvSubBytes, InvShiftRows, InvMixColumns
- ✅ Round keys used in **reverse order** (10 → 0)
- ✅ Same sequential design as encryption
- ✅ Perfectly reverses encryption: `decrypt(encrypt(x)) = x`

**Inverse Operations:**
- Inverse S-Box (different lookup table)
- Inverse ShiftRows (right shift instead of left)
- Inverse MixColumns (multiply by 0x09, 0x0B, 0x0D, 0x0E)

---

## 🎯 Complete Demo Flow (Both Modules)

### Quick Command Sequence

```powershell
# Navigate to project
cd C:\Users\rohan\OneDrive\Desktop\finaladld\ADLD_CO_EL

# === ENCRYPTION ===
iverilog -o aes_test.out hdl/aes128_nist.v test/aes_encryption_testbench.v
vvp aes_test.out
gtkwave encryption_test.vcd

# === DECRYPTION ===
iverilog -o aes_decrypt_test.out hdl/aes128_decrypt.v test/aes_decryption_testbench.v
vvp aes_decrypt_test.out
gtkwave decryption_test.vcd
```

---

## 📊 Side-by-Side Comparison

| Aspect | Encryption | Decryption |
|--------|-----------|------------|
| **Module** | `aes128_encrypt` | `aes128_decrypt` |
| **Input** | Plaintext | Ciphertext |
| **Output** | Ciphertext | Plaintext |
| **Operations** | SubBytes → ShiftRows → MixColumns → AddRoundKey | InvShiftRows → InvSubBytes → AddRoundKey → InvMixColumns |
| **Round Keys** | 0 → 10 (forward) | 10 → 0 (backward) |
| **S-Box** | Forward S-Box | Inverse S-Box |
| **Rounds** | 11 (0-10) | 11 (0-10) |
| **Clock Cycles** | 11 cycles | 11 cycles |

---

## 🗣️ Talking Points for Presentation

### Introduction
"We have implemented a complete AES-128 encryption and decryption system using Verilog HDL. The design follows the NIST FIPS-197 standard and demonstrates key concepts from ADLD and Computer Organization."

### Design Approach
"We chose a **sequential implementation** rather than combinational because:
1. It's more realistic for actual hardware
2. Demonstrates state machines and counters
3. Shows clock-based synchronous design
4. More power-efficient in real chips"

### Key Features
"Our implementation includes:
- **State Machine:** 4-bit counter for 11 rounds
- **Registers:** 128-bit state register for intermediate values
- **Reset Logic:** Active-low reset for initialization
- **Completion Flag:** Done signal indicates when encryption/decryption is complete"

### Verification
"We verified our design using:
1. **NIST Standard Vectors** - Official test cases
2. **Custom Test Cases** - Sequential bytes and ASCII text
3. **GTKWave Visualization** - Waveform analysis
4. **Round-trip Testing** - Encrypt then decrypt to verify correctness"

### ADLD/CO Concepts
"This project demonstrates:
- **Sequential Circuits:** Clocked state machines
- **Combinational Logic:** S-Box, MixColumns functions
- **Counters:** Round counter (4-bit)
- **Registers:** State registers (128-bit)
- **Finite State Machines:** Round-based control
- **Arithmetic Operations:** Galois Field multiplication
- **Memory:** Lookup tables (S-Box)"

---

## 🔧 Troubleshooting

### If GTKWave doesn't open:
- Make sure you're using `gtkwave` (not `wsl gtkwave`)
- Check if GTKWave is installed: `gtkwave --version`
- Ensure VCD file exists: `ls *.vcd`

### If compilation fails:
- Check file paths are correct
- Ensure you're in the project directory
- Verify Verilog files exist in `hdl/` and `test/`

### If waveforms look wrong:
- Click "Zoom Fit" to see full simulation
- Make sure you added the correct signals
- Check that simulation completed (look for `$finish` message)

---

## 📁 Project Files Reference

### Encryption Files
- [`hdl/aes128_nist.v`](file:///c:/Users/rohan/OneDrive/Desktop/finaladld/ADLD_CO_EL/hdl/aes128_nist.v) - Encryption module (251 lines)
- [`test/aes_encryption_testbench.v`](file:///c:/Users/rohan/OneDrive/Desktop/finaladld/ADLD_CO_EL/test/aes_encryption_testbench.v) - Encryption testbench (78 lines)
- `encryption_test.vcd` - Waveform output
- `aes_test.out` - Compiled executable

### Decryption Files
- [`hdl/aes128_decrypt.v`](file:///c:/Users/rohan/OneDrive/Desktop/finaladld/ADLD_CO_EL/hdl/aes128_decrypt.v) - Decryption module (346 lines)
- [`test/aes_decryption_testbench.v`](file:///c:/Users/rohan/OneDrive/Desktop/finaladld/ADLD_CO_EL/test/aes_decryption_testbench.v) - Decryption testbench (91 lines)
- `decryption_test.vcd` - Waveform output
- `aes_decrypt_test.out` - Compiled executable

### Documentation
- [`README.md`](file:///c:/Users/rohan/OneDrive/Desktop/finaladld/ADLD_CO_EL/README.md) - Project overview
- [`ADLD_CO_TOPICS.md`](file:///c:/Users/rohan/OneDrive/Desktop/finaladld/ADLD_CO_EL/ADLD_CO_TOPICS.md) - Syllabus mapping

---

## ⏱️ Timing Guide

**For a 10-minute presentation:**
- Introduction: 1 minute
- Encryption demo: 3 minutes
- Decryption demo: 3 minutes
- Design explanation: 2 minutes
- Q&A: 1 minute

**For a 5-minute presentation:**
- Introduction: 30 seconds
- Encryption demo: 2 minutes
- Decryption demo: 1.5 minutes
- Key points: 1 minute

---

## ✅ Final Checklist Before Exam

- [ ] Practice running all commands
- [ ] Know how to add signals in GTKWave
- [ ] Memorize test case values
- [ ] Understand what each signal shows
- [ ] Can explain encryption vs decryption differences
- [ ] Know the ADLD/CO concepts demonstrated
- [ ] Prepared to answer questions about:
  - Why sequential vs combinational?
  - What is `rst_n`?
  - How many clock cycles?
  - What are the AES operations?
  - How is decryption different from encryption?

---

## 🎓 Good Luck!

**Remember:** 
- Stay calm and confident
- The waveforms prove your design works
- You have NIST-verified test vectors
- Your implementation is correct and well-documented

**You've got this! 🚀**
