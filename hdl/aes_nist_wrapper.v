`timescale 1ns / 1ps

// NIST-compatible AES-128 wrapper
// Converts between NIST column-major byte ordering and internal representation

module aes_nist_wrapper (
    input clk,
    input [127:0] i_Key,
    input [127:0] i_Plain_Text,
    output [127:0] o_Cipher_Text
    );

    // NIST AES uses column-major byte ordering for the state matrix:
    // State matrix layout:
    //   [s0  s4  s8  s12]
    //   [s1  s5  s9  s13]
    //   [s2  s6  s10 s14]
    //   [s3  s7  s11 s15]
    //
    // NIST byte ordering in 128-bit word: s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15
    // Mapped to bits: [127:120]=s0, [119:112]=s1, ..., [7:0]=s15

    // Convert NIST format to internal format (column-major to row-major transposition)
    function [127:0] nist_to_internal;
        input [127:0] nist_data;
        begin
            // NIST: s0,s1,s2,s3 | s4,s5,s6,s7 | s8,s9,s10,s11 | s12,s13,s14,s15
            // Internal (row-major): s0,s4,s8,s12 | s1,s5,s9,s13 | s2,s6,s10,s14 | s3,s7,s11,s15
            nist_to_internal[127:120] = nist_data[127:120]; // s0
            nist_to_internal[119:112] = nist_data[95:88];   // s4
            nist_to_internal[111:104] = nist_data[63:56];   // s8
            nist_to_internal[103:96]  = nist_data[31:24];   // s12
            nist_to_internal[95:88]   = nist_data[119:112]; // s1
            nist_to_internal[87:80]   = nist_data[87:80];   // s5
            nist_to_internal[79:72]   = nist_data[55:48];   // s9
            nist_to_internal[71:64]   = nist_data[23:16];   // s13
            nist_to_internal[63:56]   = nist_data[111:104]; // s2
            nist_to_internal[55:48]   = nist_data[79:72];   // s6
            nist_to_internal[47:40]   = nist_data[47:40];   // s10
            nist_to_internal[39:32]   = nist_data[15:8];    // s14
            nist_to_internal[31:24]   = nist_data[103:96];  // s3
            nist_to_internal[23:16]   = nist_data[71:64];   // s7
            nist_to_internal[15:8]    = nist_data[39:32];   // s11
            nist_to_internal[7:0]     = nist_data[7:0];     // s15
        end
    endfunction

    // Convert internal format back to NIST format
    function [127:0] internal_to_nist;
        input [127:0] internal_data;
        begin
            // Reverse of nist_to_internal
            internal_to_nist[127:120] = internal_data[127:120]; // s0
            internal_to_nist[119:112] = internal_data[95:88];   // s1
            internal_to_nist[111:104] = internal_data[63:56];   // s2
            internal_to_nist[103:96]  = internal_data[31:24];   // s3
            internal_to_nist[95:88]   = internal_data[119:112]; // s4
            internal_to_nist[87:80]   = internal_data[87:80];   // s5
            internal_to_nist[79:72]   = internal_data[55:48];   // s6
            internal_to_nist[71:64]   = internal_data[23:16];   // s7
            internal_to_nist[63:56]   = internal_data[111:104]; // s8
            internal_to_nist[55:48]   = internal_data[79:72];   // s9
            internal_to_nist[47:40]   = internal_data[47:40];   // s10
            internal_to_nist[39:32]   = internal_data[15:8];    // s11
            internal_to_nist[31:24]   = internal_data[103:96];  // s12
            internal_to_nist[23:16]   = internal_data[71:64];   // s13
            internal_to_nist[15:8]    = internal_data[39:32];   // s14
            internal_to_nist[7:0]     = internal_data[7:0];     // s15
        end
    endfunction

    wire [127:0] internal_key;
    wire [127:0] internal_plaintext;
    wire [127:0] internal_ciphertext;

    assign internal_key = nist_to_internal(i_Key);
    assign internal_plaintext = nist_to_internal(i_Plain_Text);

    // Instantiate original encryption module
    encryption aes_core (
        .clk(clk),
        .i_Key(internal_key),
        .i_Plain_Text(internal_plaintext),
        .o_Cipher_Text(internal_ciphertext)
    );

    assign o_Cipher_Text = internal_to_nist(internal_ciphertext);

endmodule
