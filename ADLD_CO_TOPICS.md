# Project Concept Mapping: AES-128 to ADLD & Computer Organization

This document maps the implementation details of the AES-128 hardware project to the specific units and topics covered in the **Applied Digital Logic Design (ADLD)** and **Computer Organization (CO)** syllabus.

## 1. Applied Digital Logic Design (ADLD) Mapping

### **Unit-I: Arithmetic & Simplification**
*   **Arithmetic Operations:**
    *   **Concept:** Multiplication of Unsigned Numbers / Finite Field Arithmetic.
    *   **Project Usage:** The `xtime` function and `mix_column` operation perform multiplication in the Galois Field $GF(2^8)$. This is implemented efficiently using **Left Shifts (`<<`)** and **XOR** subtraction, matching the "Fast Multiplication" concepts.
*   **Simplification:**
    *   **Concept:** Minimal Expressions/Boolean Logic.
    *   **Project Usage:** The **S-Box** implementation relies on complex boolean logic (truth tables) simplifications to substitute bytes.

### **Unit-II: Sequential Circuits & Logic Design**
*   **Encoders/Decoders:**
    *   **Concept:** Decoders and Multiplexers.
    *   **Project Usage:** The `round_counter` effectively acts as a decoder, selecting which round key (`rk[0]`, `rk[1]`, etc.) to use for the current clock cycle.
*   **Registers:**
    *   **Concept:** SISO, SIPO, PISO, PIPO, Universal Shift Register.
    *   **Project Usage:**
        *   **PIPO (Parallel-In Parallel-Out):** The `state_reg[127:0]` is a massive 128-bit PIPO register. It loads input data in parallel and updates its state every clock cycle.
        *   **Shift Register:** The `shift_rows` operation mimics the behavior of a barrel shifter or circular shift register.

### **Unit-III: Applications of Flip-Flops & Sequential Networks**
*   **Counters:**
    *   **Concept:** Synchronous Binary Counters.
    *   **Project Usage:** The `round_counter` is a **4-bit Synchronous Up-Counter**. It counts `0 -> 1 -> ... -> 10` on the rising edge of the clock to sequence the encryption steps.
*   **Synchronous Sequential Networks (FSM):**
    *   **Concept:** Structure and operation of Clocked Synchronous Sequential Networks.
    *   **Project Usage:** The entire design is a **Finite State Machine (FSM)**.
        *   **States:** `Idle/Init` (Count 0), `Processing` (Counts 1-9), `Final` (Count 10), `Done` (Count 11).
        *   **Transitions:** Controlled by the `clk` and `rst_n` signals.
        *   **Modelling:** Used `always @(posedge clk)` blocks to define the next-state logic.

---

## 2. Computer Organization (CO) Mapping

### **Unit-IV: Basic Structure of Computers**
*   **Functional Units:**
    *   **Concept:** Basic Operational Concepts.
    *   **Project Usage:** The modules `sub_bytes`, `shift_rows`, and `mix_columns` act as specialized **ALUs (Arithmetic Logic Units)** or Functional Units dedicated to cryptographic operations.
*   **Parallelism:**
    *   **Concept:** Performance & Technology.
    *   **Project Usage:** The hardware implementation is inherently **Parallel**. Unlike a CPU that processes byte-by-byte, this hardware processes the entire 128-bit (16-byte) block simultaneously in one clock cycle.

### **Unit-V: Basic Processing Unit**
*   **Instruction Execution:**
    *   **Concept:** Fetch and Execution Steps.
    *   **Project Usage:** The `round_counter` acts as a **Program Counter (PC)** equivalent. It "fetches" the next instruction (Encryption Round) and specific data (Round Key) to execute.
*   **Control Signals:**
    *   **Concept:** Hardwired Control.
    *   **Project Usage:** The design uses **Hardwired Control** (not Microprogrammed). The logic gates physically determine the next step based on the current counter value (e.g., `if (round_counter == 10)` -> Switch to Final Round logic).
*   **The Memory System:**
    *   **Concept:** Registers vs Cache.
    *   **Project Usage:** The `state_reg` serves as the **Accumulator** or internal Register File, holding the temporary results of the computation so they aren't lost between clock cycles.
