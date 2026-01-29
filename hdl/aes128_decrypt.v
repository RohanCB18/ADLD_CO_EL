`timescale 1ns / 1ps

// NIST-compliant AES-128 Decryption Module
// Implements the "Inverse Cipher" as specified in FIPS-197

module aes128_decrypt (
    input wire clk,
    input wire rst_n, // Active low reset
    input wire [127:0] ciphertext,
    input wire [127:0] key,
    output reg [127:0] plaintext,
    output reg done,
    output wire [3:0] round_count_out, // Expose internal round counter
    output wire [127:0] state_out      // Expose internal state
);

    // =========================================================================
    // 1. Functions (Inverse S-Box, Inverse Math, Inverse MixColumns)
    // =========================================================================

    // Inverse S-Box lookup table
    function [7:0] inv_sbox;
        input [7:0] in;
        reg [7:0] out;
        begin
            case (in)
                8'h00: out = 8'h52;                8'h01: out = 8'h09;                8'h02: out = 8'h6a;                8'h03: out = 8'hd5;
                8'h04: out = 8'h30;                8'h05: out = 8'h36;                8'h06: out = 8'ha5;                8'h07: out = 8'h38;
                8'h08: out = 8'hbf;                8'h09: out = 8'h40;                8'h0a: out = 8'ha3;                8'h0b: out = 8'h9e;
                8'h0c: out = 8'h81;                8'h0d: out = 8'hf3;                8'h0e: out = 8'hd7;                8'h0f: out = 8'hfb;
                8'h10: out = 8'h7c;                8'h11: out = 8'he3;                8'h12: out = 8'h39;                8'h13: out = 8'h82;
                8'h14: out = 8'h9b;                8'h15: out = 8'h2f;                8'h16: out = 8'hff;                8'h17: out = 8'h87;
                8'h18: out = 8'h34;                8'h19: out = 8'h8e;                8'h1a: out = 8'h43;                8'h1b: out = 8'h44;
                8'h1c: out = 8'hc4;                8'h1d: out = 8'hde;                8'h1e: out = 8'he9;                8'h1f: out = 8'hcb;
                8'h20: out = 8'h54;                8'h21: out = 8'h7b;                8'h22: out = 8'h94;                8'h23: out = 8'h32;
                8'h24: out = 8'ha6;                8'h25: out = 8'hc2;                8'h26: out = 8'h23;                8'h27: out = 8'h3d;
                8'h28: out = 8'hee;                8'h29: out = 8'h4c;                8'h2a: out = 8'h95;                8'h2b: out = 8'h0b;
                8'h2c: out = 8'h42;                8'h2d: out = 8'hfa;                8'h2e: out = 8'hc3;                8'h2f: out = 8'h4e;
                8'h30: out = 8'h08;                8'h31: out = 8'h2e;                8'h32: out = 8'ha1;                8'h33: out = 8'h66;
                8'h34: out = 8'h28;                8'h35: out = 8'hd9;                8'h36: out = 8'h24;                8'h37: out = 8'hb2;
                8'h38: out = 8'h76;                8'h39: out = 8'h5b;                8'h3a: out = 8'ha2;                8'h3b: out = 8'h49;
                8'h3c: out = 8'h6d;                8'h3d: out = 8'h8b;                8'h3e: out = 8'hd1;                8'h3f: out = 8'h25;
                8'h40: out = 8'h72;                8'h41: out = 8'hf8;                8'h42: out = 8'hf6;                8'h43: out = 8'h64;
                8'h44: out = 8'h86;                8'h45: out = 8'h68;                8'h46: out = 8'h98;                8'h47: out = 8'h16;
                8'h48: out = 8'hd4;                8'h49: out = 8'ha4;                8'h4a: out = 8'h5c;                8'h4b: out = 8'hcc;
                8'h4c: out = 8'h5d;                8'h4d: out = 8'h65;                8'h4e: out = 8'hb6;                8'h4f: out = 8'h92;
                8'h50: out = 8'h6c;                8'h51: out = 8'h70;                8'h52: out = 8'h48;                8'h53: out = 8'h50;
                8'h54: out = 8'hfd;                8'h55: out = 8'hed;                8'h56: out = 8'hb9;                8'h57: out = 8'hda;
                8'h58: out = 8'h5e;                8'h59: out = 8'h15;                8'h5a: out = 8'h46;                8'h5b: out = 8'h57;
                8'h5c: out = 8'ha7;                8'h5d: out = 8'h8d;                8'h5e: out = 8'h9d;                8'h5f: out = 8'h84;
                8'h60: out = 8'h90;                8'h61: out = 8'hd8;                8'h62: out = 8'hab;                8'h63: out = 8'h00;
                8'h64: out = 8'h8c;                8'h65: out = 8'hbc;                8'h66: out = 8'hd3;                8'h67: out = 8'h0a;
                8'h68: out = 8'hf7;                8'h69: out = 8'he4;                8'h6a: out = 8'h58;                8'h6b: out = 8'h05;
                8'h6c: out = 8'hb8;                8'h6d: out = 8'hb3;                8'h6e: out = 8'h45;                8'h6f: out = 8'h06;
                8'h70: out = 8'hd0;                8'h71: out = 8'h2c;                8'h72: out = 8'h1e;                8'h73: out = 8'h8f;
                8'h74: out = 8'hca;                8'h75: out = 8'h3f;                8'h76: out = 8'h0f;                8'h77: out = 8'h02;
                8'h78: out = 8'hc1;                8'h79: out = 8'haf;                8'h7a: out = 8'hbd;                8'h7b: out = 8'h03;
                8'h7c: out = 8'h01;                8'h7d: out = 8'h13;                8'h7e: out = 8'h8a;                8'h7f: out = 8'h6b;
                8'h80: out = 8'h3a;                8'h81: out = 8'h91;                8'h82: out = 8'h11;                8'h83: out = 8'h41;
                8'h84: out = 8'h4f;                8'h85: out = 8'h67;                8'h86: out = 8'hdc;                8'h87: out = 8'hea;
                8'h88: out = 8'h97;                8'h89: out = 8'hf2;                8'h8a: out = 8'hcf;                8'h8b: out = 8'hce;
                8'h8c: out = 8'hf0;                8'h8d: out = 8'hb4;                8'h8e: out = 8'he6;                8'h8f: out = 8'h73;
                8'h90: out = 8'h96;                8'h91: out = 8'hac;                8'h92: out = 8'h74;                8'h93: out = 8'h22;
                8'h94: out = 8'he7;                8'h95: out = 8'had;                8'h96: out = 8'h35;                8'h97: out = 8'h85;
                8'h98: out = 8'he2;                8'h99: out = 8'hf9;                8'h9a: out = 8'h37;                8'h9b: out = 8'he8;
                8'h9c: out = 8'h1c;                8'h9d: out = 8'h75;                8'h9e: out = 8'hdf;                8'h9f: out = 8'h6e;
                8'ha0: out = 8'h47;                8'ha1: out = 8'hf1;                8'ha2: out = 8'h1a;                8'ha3: out = 8'h71;
                8'ha4: out = 8'h1d;                8'ha5: out = 8'h29;                8'ha6: out = 8'hc5;                8'ha7: out = 8'h89;
                8'ha8: out = 8'h6f;                8'ha9: out = 8'hb7;                8'haa: out = 8'h62;                8'hab: out = 8'h0e;
                8'hac: out = 8'haa;                8'had: out = 8'h18;                8'hae: out = 8'hbe;                8'haf: out = 8'h1b;
                8'hb0: out = 8'hfc;                8'hb1: out = 8'h56;                8'hb2: out = 8'h3e;                8'hb3: out = 8'h4b;
                8'hb4: out = 8'hc6;                8'hb5: out = 8'hd2;                8'hb6: out = 8'h79;                8'hb7: out = 8'h20;
                8'hb8: out = 8'h9a;                8'hb9: out = 8'hdb;                8'hba: out = 8'hc0;                8'hbb: out = 8'hfe;
                8'hbc: out = 8'h78;                8'hbd: out = 8'hcd;                8'hbe: out = 8'h5a;                8'hbf: out = 8'hf4;
                8'hc0: out = 8'h1f;                8'hc1: out = 8'hdd;                8'hc2: out = 8'ha8;                8'hc3: out = 8'h33;
                8'hc4: out = 8'h88;                8'hc5: out = 8'h07;                8'hc6: out = 8'hc7;                8'hc7: out = 8'h31;
                8'hc8: out = 8'hb1;                8'hc9: out = 8'h12;                8'hca: out = 8'h10;                8'hcb: out = 8'h59;
                8'hcc: out = 8'h27;                8'hcd: out = 8'h80;                8'hce: out = 8'hec;                8'hcf: out = 8'h5f;
                8'hd0: out = 8'h60;                8'hd1: out = 8'h51;                8'hd2: out = 8'h7f;                8'hd3: out = 8'ha9;
                8'hd4: out = 8'h19;                8'hd5: out = 8'hb5;                8'hd6: out = 8'h4a;                8'hd7: out = 8'h0d;
                8'hd8: out = 8'h2d;                8'hd9: out = 8'he5;                8'hda: out = 8'h7a;                8'hdb: out = 8'h9f;
                8'hdc: out = 8'h93;                8'hdd: out = 8'hc9;                8'hde: out = 8'h9c;                8'hdf: out = 8'hef;
                8'he0: out = 8'ha0;                8'he1: out = 8'he0;                8'he2: out = 8'h3b;                8'he3: out = 8'h4d;
                8'he4: out = 8'hae;                8'he5: out = 8'h2a;                8'he6: out = 8'hf5;                8'he7: out = 8'hb0;
                8'he8: out = 8'hc8;                8'he9: out = 8'heb;                8'hea: out = 8'hbb;                8'heb: out = 8'h3c;
                8'hec: out = 8'h83;                8'hed: out = 8'h53;                8'hee: out = 8'h99;                8'hef: out = 8'h61;
                8'hf0: out = 8'h17;                8'hf1: out = 8'h2b;                8'hf2: out = 8'h04;                8'hf3: out = 8'h7e;
                8'hf4: out = 8'hba;                8'hf5: out = 8'h77;                8'hf6: out = 8'hd6;                8'hf7: out = 8'h26;
                8'hf8: out = 8'he1;                8'hf9: out = 8'h69;                8'hfa: out = 8'h14;                8'hfb: out = 8'h63;
                8'hfc: out = 8'h55;                8'hfd: out = 8'h21;                8'hfe: out = 8'h0c;                8'hff: out = 8'h7d;
                default: out = 8'h00;
            endcase
            inv_sbox = out;
        end
    endfunction

    // Galios Field Multiplication helper: multiply by x (<< 1)
    function [7:0] xtime;
        input [7:0] b;
        begin
            xtime = (b[7]) ? ((b << 1) ^ 8'h1b) : (b << 1);
        end
    endfunction

    // Multiplication by arbitrary power helper (using xtime)
    function [7:0] mul;
        input [7:0] a;
        input [3:0] b; // Multiplier (only needed for 09, 0b, 0d, 0e)
        reg [7:0] p;
        begin
            p = 0;
            if (b[0]) p = p ^ a;
            a = xtime(a);
            if (b[1]) p = p ^ a;
            a = xtime(a);
            if (b[2]) p = p ^ a;
            a = xtime(a);
            if (b[3]) p = p ^ a;
            mul = p;
        end
    endfunction
    
    // Inverse SubBytes
    function [127:0] inv_sub_bytes;
        input [127:0] s;
        begin
            inv_sub_bytes = {inv_sbox(s[127:120]), inv_sbox(s[119:112]), inv_sbox(s[111:104]), inv_sbox(s[103:96]),
                             inv_sbox(s[95:88]), inv_sbox(s[87:80]), inv_sbox(s[79:72]), inv_sbox(s[71:64]),
                             inv_sbox(s[63:56]), inv_sbox(s[55:48]), inv_sbox(s[47:40]), inv_sbox(s[39:32]),
                             inv_sbox(s[31:24]), inv_sbox(s[23:16]), inv_sbox(s[15:8]), inv_sbox(s[7:0])};
        end
    endfunction

    // Inverse ShiftRows (Cyclic Right Shift)
    // Row 0: No shift
    // Row 1: Right shift 1 (d4 goes to d5 pos)
    // Row 2: Right shift 2
    // Row 3: Right shift 3
    function [127:0] inv_shift_rows;
        input [127:0] s;
        reg [7:0] t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15;
        begin
            t0  = s[127:120]; t1  = s[119:112]; t2  = s[111:104]; t3  = s[103:96];  // Row 0
            t4  = s[95:88];   t5  = s[87:80];   t6  = s[79:72];   t7  = s[71:64];   // Row 1
            t8  = s[63:56];   t9  = s[55:48];   t10 = s[47:40];   t11 = s[39:32];   // Row 2
            t12 = s[31:24];   t13 = s[23:16];   t14 = s[15:8];    t15 = s[7:0];     // Row 3
            
            // Reconstruct with shift
            inv_shift_rows = {t0, t13, t10, t7,     // Row 0 (t0), Row 1 (t13 rot 1 right), etc
                              t4, t1, t14, t11,
                              t8, t5, t2, t15,
                              t12, t9, t6, t3};
        end
    endfunction

    // Inverse MixColumns for one column
    function [31:0] inv_mix_column;
        input [31:0] col;
        reg [7:0] a0, a1, a2, a3;
        reg [7:0] b0, b1, b2, b3;
        begin
            a0 = col[31:24]; a1 = col[23:16]; a2 = col[15:8]; a3 = col[7:0];
            
            // Multiply by 0e, 0b, 0d, 09
            b0 = mul(a0, 4'hE) ^ mul(a1, 4'hB) ^ mul(a2, 4'hD) ^ mul(a3, 4'h9);
            b1 = mul(a0, 4'h9) ^ mul(a1, 4'hE) ^ mul(a2, 4'hB) ^ mul(a3, 4'hD);
            b2 = mul(a0, 4'hD) ^ mul(a1, 4'h9) ^ mul(a2, 4'hE) ^ mul(a3, 4'hB);
            b3 = mul(a0, 4'hB) ^ mul(a1, 4'hD) ^ mul(a2, 4'h9) ^ mul(a3, 4'hE);
            
            inv_mix_column = {b0, b1, b2, b3};
        end
    endfunction

    // Inverse MixColumns for full state
    function [127:0] inv_mix_columns;
        input [127:0] s;
        begin
            inv_mix_columns = {inv_mix_column(s[127:96]), inv_mix_column(s[95:64]), 
                               inv_mix_column(s[63:32]), inv_mix_column(s[31:0])};
        end
    endfunction

    // =========================================================================
    // 2. Key Expansion (Exactly same as Encryption, we just read backwards)
    // =========================================================================
    
    // S-Box for key expansion (Forward S-Box)
    function [7:0] sbox;
        input [7:0] in;
        // ... (We need the forward S-Box just for key expansion!)
        reg [7:0] out;
        begin
            case (in)
                8'h00: out = 8'h63;                8'h01: out = 8'h7c;                8'h02: out = 8'h77;                8'h03: out = 8'h7b;
                8'h04: out = 8'hf2;                8'h05: out = 8'h6b;                8'h06: out = 8'h6f;                8'h07: out = 8'hc5;
                8'h08: out = 8'h30;                8'h09: out = 8'h01;                8'h0a: out = 8'h67;                8'h0b: out = 8'h2b;
                8'h0c: out = 8'hfe;                8'h0d: out = 8'hd7;                8'h0e: out = 8'hab;                8'h0f: out = 8'h76;
                8'h10: out = 8'hca;                8'h11: out = 8'h82;                8'h12: out = 8'hc9;                8'h13: out = 8'h7d;
                8'h14: out = 8'hfa;                8'h15: out = 8'h59;                8'h16: out = 8'h47;                8'h17: out = 8'hf0;
                8'h18: out = 8'had;                8'h19: out = 8'hd4;                8'h1a: out = 8'ha2;                8'h1b: out = 8'haf;
                8'h1c: out = 8'h9c;                8'h1d: out = 8'ha4;                8'h1e: out = 8'h72;                8'h1f: out = 8'hc0;
                8'h20: out = 8'hb7;                8'h21: out = 8'hfd;                8'h22: out = 8'h93;                8'h23: out = 8'h26;
                8'h24: out = 8'h36;                8'h25: out = 8'h3f;                8'h26: out = 8'hf7;                8'h27: out = 8'hcc;
                8'h28: out = 8'h34;                8'h29: out = 8'ha5;                8'h2a: out = 8'he5;                8'h2b: out = 8'hf1;
                8'h2c: out = 8'h71;                8'h2d: out = 8'hd8;                8'h2e: out = 8'h31;                8'h2f: out = 8'h15;
                8'h30: out = 8'h04;                8'h31: out = 8'hc7;                8'h32: out = 8'h23;                8'h33: out = 8'hc3;
                8'h34: out = 8'h18;                8'h35: out = 8'h96;                8'h36: out = 8'h05;                8'h37: out = 8'h9a;
                8'h38: out = 8'h07;                8'h39: out = 8'h12;                8'h3a: out = 8'h80;                8'h3b: out = 8'he2;
                8'h3c: out = 8'heb;                8'h3d: out = 8'h27;                8'h3e: out = 8'hb2;                8'h3f: out = 8'h75;
                8'h40: out = 8'h09;                8'h41: out = 8'h83;                8'h42: out = 8'h2c;                8'h43: out = 8'h1a;
                8'h44: out = 8'h1b;                8'h45: out = 8'h6e;                8'h46: out = 8'h5a;                8'h47: out = 8'ha0;
                8'h48: out = 8'h52;                8'h49: out = 8'h3b;                8'h4a: out = 8'hd6;                8'h4b: out = 8'hb3;
                8'h4c: out = 8'h29;                8'h4d: out = 8'he3;                8'h4e: out = 8'h2f;                8'h4f: out = 8'h84;
                8'h50: out = 8'h53;                8'h51: out = 8'hd1;                8'h52: out = 8'h00;                8'h53: out = 8'hed;
                8'h54: out = 8'h20;                8'h55: out = 8'hfc;                8'h56: out = 8'hb1;                8'h57: out = 8'h5b;
                8'h58: out = 8'h6a;                8'h59: out = 8'hcb;                8'h5a: out = 8'hbe;                8'h5b: out = 8'h39;
                8'h5c: out = 8'h4a;                8'h5d: out = 8'h4c;                8'h5e: out = 8'h58;                8'h5f: out = 8'hcf;
                8'h60: out = 8'hd0;                8'h61: out = 8'hef;                8'h62: out = 8'haa;                8'h63: out = 8'hfb;
                8'h64: out = 8'h43;                8'h65: out = 8'h4d;                8'h66: out = 8'h33;                8'h67: out = 8'h85;
                8'h68: out = 8'h45;                8'h69: out = 8'hf9;                8'h6a: out = 8'h02;                8'h6b: out = 8'h7f;
                8'h6c: out = 8'h50;                8'h6d: out = 8'h3c;                8'h6e: out = 8'h9f;                8'h6f: out = 8'ha8;
                8'h70: out = 8'h51;                8'h71: out = 8'ha3;                8'h72: out = 8'h40;                8'h73: out = 8'h8f;
                8'h74: out = 8'h92;                8'h75: out = 8'h9d;                8'h76: out = 8'h38;                8'h77: out = 8'hf5;
                8'h78: out = 8'hbc;                8'h79: out = 8'hb6;                8'h7a: out = 8'hda;                8'h7b: out = 8'h21;
                8'h7c: out = 8'h10;                8'h7d: out = 8'hff;                8'h7e: out = 8'hf3;                8'h7f: out = 8'hd2;
                8'h80: out = 8'hcd;                8'h81: out = 8'h0c;                8'h82: out = 8'h13;                8'h83: out = 8'hec;
                8'h84: out = 8'h5f;                8'h85: out = 8'h97;                8'h86: out = 8'h44;                8'h87: out = 8'h17;
                8'h88: out = 8'hc4;                8'h89: out = 8'ha7;                8'h8a: out = 8'h7e;                8'h8b: out = 8'h3d;
                8'h8c: out = 8'h64;                8'h8d: out = 8'h5d;                8'h8e: out = 8'h19;                8'h8f: out = 8'h73;
                8'h90: out = 8'h60;                8'h91: out = 8'h81;                8'h92: out = 8'h4f;                8'h93: out = 8'hdc;
                8'h94: out = 8'h22;                8'h95: out = 8'h2a;                8'h96: out = 8'h90;                8'h97: out = 8'h88;
                8'h98: out = 8'h46;                8'h99: out = 8'hee;                8'h9a: out = 8'hb8;                8'h9b: out = 8'h14;
                8'h9c: out = 8'hde;                8'h9d: out = 8'h5e;                8'h9e: out = 8'h0b;                8'h9f: out = 8'hdb;
                8'ha0: out = 8'he0;                8'ha1: out = 8'h32;                8'ha2: out = 8'h3a;                8'ha3: out = 8'h0a;
                8'ha4: out = 8'h49;                8'ha5: out = 8'h06;                8'ha6: out = 8'h24;                8'ha7: out = 8'h5c;
                8'ha8: out = 8'hc2;                8'ha9: out = 8'hd3;                8'haa: out = 8'hac;                8'hab: out = 8'h62;
                8'hac: out = 8'h91;                8'had: out = 8'h95;                8'hae: out = 8'he4;                8'haf: out = 8'h79;
                8'hb0: out = 8'he7;                8'hb1: out = 8'hc8;                8'hb2: out = 8'h37;                8'hb3: out = 8'h6d;
                8'hb4: out = 8'h8d;                8'hb5: out = 8'hd5;                8'hb6: out = 8'h4e;                8'hb7: out = 8'ha9;
                8'hb8: out = 8'h6c;                8'hb9: out = 8'h56;                8'hba: out = 8'hf4;                8'hbb: out = 8'hea;
                8'hbc: out = 8'h65;                8'hbd: out = 8'h7a;                8'hbe: out = 8'hae;                8'hbf: out = 8'h08;
                8'hc0: out = 8'hba;                8'hc1: out = 8'h78;                8'hc2: out = 8'h25;                8'hc3: out = 8'h2e;
                8'hc4: out = 8'h1c;                8'hc5: out = 8'ha6;                8'hc6: out = 8'hb4;                8'hc7: out = 8'hc6;
                8'hc8: out = 8'he8;                8'hc9: out = 8'hdd;                8'hca: out = 8'h74;                8'hcb: out = 8'h1f;
                8'hcc: out = 8'h4b;                8'hcd: out = 8'hbd;                8'hce: out = 8'h8b;                8'hcf: out = 8'h8a;
                8'hd0: out = 8'h70;                8'hd1: out = 8'h3e;                8'hd2: out = 8'hb5;                8'hd3: out = 8'h66;
                8'hd4: out = 8'h48;                8'hd5: out = 8'h03;                8'hd6: out = 8'hf6;                8'hd7: out = 8'h0e;
                8'hd8: out = 8'h61;                8'hd9: out = 8'h35;                8'hda: out = 8'h57;                8'hdb: out = 8'hb9;
                8'hdc: out = 8'h86;                8'hdd: out = 8'hc1;                8'hde: out = 8'h1d;                8'hdf: out = 8'h9e;
                8'he0: out = 8'he1;                8'he1: out = 8'hf8;                8'he2: out = 8'h98;                8'he3: out = 8'h11;
                8'he4: out = 8'h69;                8'he5: out = 8'hd9;                8'he6: out = 8'h8e;                8'he7: out = 8'h94;
                8'he8: out = 8'h9b;                8'he9: out = 8'h1e;                8'hea: out = 8'h87;                8'heb: out = 8'he9;
                8'hec: out = 8'hce;                8'hed: out = 8'h55;                8'hee: out = 8'h28;                8'hef: out = 8'hdf;
                8'hf0: out = 8'h8c;                8'hf1: out = 8'ha1;                8'hf2: out = 8'h89;                8'hf3: out = 8'h0d;
                8'hf4: out = 8'hbf;                8'hf5: out = 8'he6;                8'hf6: out = 8'h42;                8'hf7: out = 8'h68;
                8'hf8: out = 8'h41;                8'hf9: out = 8'h99;                8'hfa: out = 8'h2d;                8'hfb: out = 8'h0f;
                8'hfc: out = 8'hb0;                8'hfd: out = 8'h54;                8'hfe: out = 8'hbb;                8'hff: out = 8'h16;
                default: out = 8'h00;
            endcase
            sbox = out;
        end
    endfunction

    // Key schedule core (RotWord + SubWord + Rcon)
    function [31:0] key_core;
        input [31:0] word;
        input [7:0] rcon;
        begin
            key_core = {sbox(word[23:16]) ^ rcon, sbox(word[15:8]), sbox(word[7:0]), sbox(word[31:24])};
        end
    endfunction

    // Round keys
    wire [127:0] rk[0:10];
    wire [31:0] w [0:43];
    
    // Initial key words
    assign w[0] = key[127:96];
    assign w[1] = key[95:64];
    assign w[2] = key[63:32];
    assign w[3] = key[31:0];
    
    // Key expansion
    assign w[4]  = w[0] ^ key_core(w[3], 8'h01); assign w[5]  = w[1] ^ w[4]; assign w[6]  = w[2] ^ w[5]; assign w[7]  = w[3] ^ w[6];
    assign w[8]  = w[4] ^ key_core(w[7], 8'h02); assign w[9]  = w[5] ^ w[8]; assign w[10] = w[6] ^ w[9]; assign w[11] = w[7] ^ w[10];
    assign w[12] = w[8] ^ key_core(w[11], 8'h04); assign w[13] = w[9] ^ w[12]; assign w[14] = w[10] ^ w[13]; assign w[15] = w[11] ^ w[14];
    assign w[16] = w[12] ^ key_core(w[15], 8'h08); assign w[17] = w[13] ^ w[16]; assign w[18] = w[14] ^ w[17]; assign w[19] = w[15] ^ w[18];
    assign w[20] = w[16] ^ key_core(w[19], 8'h10); assign w[21] = w[17] ^ w[20]; assign w[22] = w[18] ^ w[21]; assign w[23] = w[19] ^ w[22];
    assign w[24] = w[20] ^ key_core(w[23], 8'h20); assign w[25] = w[21] ^ w[24]; assign w[26] = w[22] ^ w[25]; assign w[27] = w[23] ^ w[26];
    assign w[28] = w[24] ^ key_core(w[27], 8'h40); assign w[29] = w[25] ^ w[28]; assign w[30] = w[26] ^ w[29]; assign w[31] = w[27] ^ w[30];
    assign w[32] = w[28] ^ key_core(w[31], 8'h80); assign w[33] = w[29] ^ w[32]; assign w[34] = w[30] ^ w[33]; assign w[35] = w[31] ^ w[34];
    assign w[36] = w[32] ^ key_core(w[35], 8'h1b); assign w[37] = w[33] ^ w[36]; assign w[38] = w[34] ^ w[37]; assign w[39] = w[35] ^ w[38];
    assign w[40] = w[36] ^ key_core(w[39], 8'h36); assign w[41] = w[37] ^ w[40]; assign w[42] = w[38] ^ w[41]; assign w[43] = w[39] ^ w[42];
    
    // Assign to round key array
    assign rk[0]  = {w[0], w[1], w[2], w[3]};
    assign rk[1]  = {w[4], w[5], w[6], w[7]};
    assign rk[2]  = {w[8], w[9], w[10], w[11]};
    assign rk[3]  = {w[12], w[13], w[14], w[15]};
    assign rk[4]  = {w[16], w[17], w[18], w[19]};
    assign rk[5]  = {w[20], w[21], w[22], w[23]};
    assign rk[6]  = {w[24], w[25], w[26], w[27]};
    assign rk[7]  = {w[28], w[29], w[30], w[31]};
    assign rk[8]  = {w[32], w[33], w[34], w[35]};
    assign rk[9]  = {w[36], w[37], w[38], w[39]};
    assign rk[10] = {w[40], w[41], w[42], w[43]};

    // =========================================================================
    // 3. Sequential Logic (State Machine for Decryption)
    // =========================================================================

    reg [3:0] round_counter;
    reg [127:0] state_reg;

    // Output assignments
    assign round_count_out = round_counter;
    assign state_out = state_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            round_counter <= 0;
            done <= 0;
            state_reg <= 0;
            plaintext <= 0;
        end else begin
            if (round_counter == 0) begin
                // Initial Round (Decrypt): AddRoundKey(10)
                state_reg <= ciphertext ^ rk[10];
                round_counter <= round_counter + 1;
                done <= 0;
            end else if (round_counter < 10) begin
                // Rounds 1-9 (Decrypt): 
                // InvShiftRows -> InvSubBytes -> AddRoundKey(10-round) -> InvMixColumns
                state_reg <= inv_mix_columns( (inv_sub_bytes(inv_shift_rows(state_reg)) ^ rk[10-round_counter]) );
                round_counter <= round_counter + 1;
            end else if (round_counter == 10) begin
                // Final Round (Decrypt): InvShiftRows -> InvSubBytes -> AddRoundKey(0) (No MixColumns)
                plaintext <= inv_sub_bytes(inv_shift_rows(state_reg)) ^ rk[0];
                done <= 1;
                round_counter <= 11; // Idle state
            end
        end
    end

endmodule
