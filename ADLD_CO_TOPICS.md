# ADLD & CO Topics Used in This Project

This document maps the concepts used in the **AES-128 Encryption** project to the topics covered in the **Applied Digital Logic Design and Computer Organisation (ADLD & CO)** syllabus.

---

## Quick Summary

| Syllabus Unit | Topics Used | Project Component |
|--------------|-------------|-------------------|
| Unit-I | XOR Operations, Multiplication | Key mixing, Galois field math |
| Unit-II | Decoders, Multiplexers, Registers | S-Box lookup, Shift registers |
| Unit-III | Synchronous Sequential Circuits | Clock-driven encryption rounds |
| Unit-IV | Memory, Addressing | 128-bit data storage, module hierarchy |
| Unit-V | Control Signals, Hardware Components | Clock synchronization, RTL design |

---

## Unit-I: Arithmetic

### Topics from Syllabus Used:
| Syllabus Topic | How It's Used in Project |
|---------------|-------------------------|
| **Addition and Subtraction of Signed Numbers** | XOR operations in AddRoundKey step |
| **Multiplication of Unsigned Numbers** | Galois Field multiplication in MixColumns |
| **Bit-Pair Recoding of Multipliers** | S-Box uses lookup tables instead of multipliers |

### Project Files:
- `aes_galois_multiply_by_2.v` - Multiplies a byte by 2 in GF(2^8)
- `aes_galois_multiply_by_3.v` - Multiplies a byte by 3 in GF(2^8)
- `aes_galois_multiply_32bit.v` - 32-bit multiplication for MixColumns
- `aes_top_module.v` - XOR operations for AddRoundKey

### Example from Code:
```verilog
// XOR operation for AddRoundKey (aes_top_module.v)
assign w_R_Cipher_Text = i_Plain_Text ^ w_Key_S;

// Galois field multiply by 2 (aes_galois_multiply_by_2.v)
o_Data <= {i_Data[6:0],1'b0} ^ (8'h1b & {8{i_Data[7]}});
```

---

## Unit-II: Combinational Circuits & Sequential Circuits

### Topics from Syllabus Used:
| Syllabus Topic | How It's Used in Project |
|---------------|-------------------------|
| **Decoders** | S-Box decodes input byte to substituted byte |
| **Encoders** | Key expansion encodes round keys |
| **Multiplexers** | Data selection in MixColumns |
| **Registers (PIPO - Parallel In Parallel Out)** | 128-bit data registers |
| **Shift Registers** | ShiftRows operation moves data positions |
| **Flip-Flops (Edge-Triggered)** | All registers use positive edge clock |

### Project Files:
- `aes_substitution_box.v` - 8-to-8 decoder (256 entries lookup table)
- `aes_shift_rows.v` - Parallel register with shift operation
- `aes_sub_bytes.v` - 16 parallel S-Box operations
- `aes_key_expansion.v` - Round key calculation with registers

### Example from Code:
```verilog
// S-Box as Decoder (aes_substitution_box.v)
case (i_Data)          
   8'h00 : o_Data <= 8'h63;
   8'h01 : o_Data <= 8'h7c;
   // ... 256 case statements
endcase

// Shift Register operation (aes_shift_rows.v)
always@ (posedge clk) begin
    o_Data [127:120] <= i_Data [95:88];   // Shift bytes
    o_Data [119:112] <= i_Data [55:48];
    // ...
end
```

---

## Unit-III: Synchronous Sequential Networks

### Topics from Syllabus Used:
| Syllabus Topic | How It's Used in Project |
|---------------|-------------------------|
| **Synchronous Sequential Networks** | All modules are clock-synchronized |
| **State Table Reduction** | S-Box is a reduced lookup (combinational) |
| **Binary Counters** | Round counter (implicitly, 10 rounds) |
| **Clocked Synchronous Networks** | Every module uses `posedge clk` |

### Project Files:
- `aes_round.v` - Sequential encryption round
- `aes_final_round.v` - Final sequential round
- All modules use synchronized clock signals

### Example from Code:
```verilog
// Synchronous register (aes_sub_bytes.v)
always@(posedge clk) begin
    o_S_Data <= w_Tmp_Output;
end

// Round sequence (aes_top_module.v)
round Round_0 (clk, w_R_Cipher_Text, w_Key_S0, w_R0_Cipher_Text);
round Round_1 (clk, w_R0_Cipher_Text, w_Key_S1, w_R1_Cipher_Text);
// ... 10 rounds total
```

---

## Unit-IV: Basic Structure of Computers & Instruction Set Architecture

### Topics from Syllabus Used:
| Syllabus Topic | How It's Used in Project |
|---------------|-------------------------|
| **Memory Locations and Addresses** | 128-bit key and data storage |
| **Basic Operational Concepts** | Input → Process → Output flow |
| **Instruction Sequencing** | Sequential round execution (R0 → R1 → ... → R9) |
| **Assembly and Execution** | Module instantiation hierarchy |

### Project Files:
- `aes_top_module.v` - Shows complete data flow
- `aes_key_expansion.v` - Memory for all 11 round keys (44 words)
- `aes_encryption_testbench.v` - Memory initialization

### Example from Code:
```verilog
// Memory storage for round keys (aes_key_expansion.v)
reg [31:0] r_W_0, r_W_1, r_W_2, r_W_3;  // 128 bits = 4 x 32-bit words
reg [31:0] r_W_4, r_W_5, r_W_6, r_W_7;
// ... 44 words total for all round keys

// Instruction sequencing - Round after round (aes_top_module.v)
round Round_0 (clk, input_data, key0, output0);
round Round_1 (clk, output0, key1, output1);
// Sequential flow: output of one is input to next
```

---

## Unit-V: Basic Processing Unit & Memory System

### Topics from Syllabus Used:
| Syllabus Topic | How It's Used in Project |
|---------------|-------------------------|
| **Instruction Execution** | Round-by-round execution |
| **Hardware Components** | Verilog modules = Hardware blocks |
| **Control Signals** | Clock signal synchronizes all operations |
| **Hardwired Control** | Direct module connections (no microcode) |
| **Register Files** | Multiple 128-bit registers for keys |

### Project Files:
- `aes_top_module.v` - Controls data flow through rounds
- `aes_round_constant.v` - Fixed constants (like ROM)
- All modules - Hardware implementation

### Example from Code:
```verilog
// Hardwired control - Direct module connections (aes_round.v)
sub_bytes Sub_Bytes(clk, i_Data, w_Sub_Data_Out);
shift_rows Shift_Rows(clk, w_Sub_Data_Out, w_Shift_Data_Out);
mix_column Mix_Column(clk, w_Shift_Data_Out, w_Mix_Data_Out);
assign o_Data = w_Mix_Data_Out ^ i_Key;

// Fixed constants (aes_round_constant.v)
function [7:0] frcon;
   case(i)    
      4'h0: frcon=8'h01;  // Round constant 1
      4'h1: frcon=8'h02;  // Round constant 2
      // ...
   endcase
endfunction
```

---

## Complete Mapping Table

| Verilog File | ADLD Topics | CO Topics |
|-------------|-------------|-----------|
| `aes_top_module.v` | XOR gates, Module hierarchy | Instruction sequencing |
| `aes_substitution_box.v` | Decoder (256-entry) | Lookup table memory |
| `aes_sub_bytes.v` | Parallel registers | Parallel processing |
| `aes_shift_rows.v` | Shift registers, PIPO | Data movement |
| `aes_mix_columns.v` | Multiplexers, Arithmetic | Matrix operations |
| `aes_round.v` | Sequential circuits | Round execution |
| `aes_final_round.v` | Sequential circuits | Final stage |
| `aes_key_expansion.v` | Registers, XOR | Memory, Key schedule |
| `aes_round_constant.v` | Constants | ROM equivalent |
| `aes_galois_multiply_by_2.v` | Multiplication | GF math |
| `aes_galois_multiply_by_3.v` | Multiplication | GF math |
| `aes_galois_multiply_32bit.v` | Arithmetic | Matrix multiplication |
| `aes_encryption_testbench.v` | Simulation | Verification |

---

## Key Takeaways

1. **Unit-I (Arithmetic)**: Used in XOR operations and Galois field multiplication
2. **Unit-II (Combinational & Sequential)**: Used in S-Box, Shift Rows, and Registers
3. **Unit-III (Synchronous Networks)**: The entire design is clock-synchronized
4. **Unit-IV (ISA)**: Memory organization and sequential execution
5. **Unit-V (Processing Unit)**: Hardware implementation with hardwired control

This project is an excellent example of how **Digital Logic Design** concepts come together to build a real-world **cryptographic hardware system**.
