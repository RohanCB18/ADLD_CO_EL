module decryption_test();

    reg clk;
    reg rst_n; // Active low reset
    reg [127:0] r_Key;
    reg [127:0] r_Cipher_Text;

    wire [127:0] w_Plain_Text;
    wire w_Done;
    wire [3:0] w_Round_Count;
    wire [127:0] w_State;

    // Instantiate Sequential AES Decryption
    aes128_decrypt AES_Decrypt(
        .clk(clk),
        .rst_n(rst_n),
        .ciphertext(r_Cipher_Text),
        .key(r_Key),
        .plaintext(w_Plain_Text),
        .done(w_Done),
        .round_count_out(w_Round_Count),
        .state_out(w_State)
    );

    // Clock generation (Period = 20ns, Freq = 50MHz)
    always #10 clk = ~clk;

    initial begin
        $dumpfile("decryption_test.vcd");
        $dumpvars(0, decryption_test);

        // Initialize signals
        clk = 0;
        rst_n = 0; // Assert reset
        r_Key = 0;
        r_Cipher_Text = 0;
        
        // Release reset
        #20 rst_n = 1;

        // ---------------------------------------------------------
        // Set 1: Inverse of Sequential Bytes
        // Key: 00..0f
        // Plaintext: 001122... (We expect this back)
        // Ciphertext: 69c4e0d86a7b0430d8cdb78070b4c55a (Output from encryption)
        // ---------------------------------------------------------
        rst_n = 0; #20; rst_n = 1;
        
        r_Key         = 128'h000002030405060708090a0b0c0d0e0f;
        r_Cipher_Text = 128'hcea3c4e0a352f54875b7e57f03cdff6d;
        
        #500; 
        $display("Set 1 Input  | Key: %h, Cipher: %h", r_Key, r_Cipher_Text);
        $display("Set 1 Output | Plain: %h (Expected: 00112233445566778899aabbccddeeff)", w_Plain_Text);

        // ---------------------------------------------------------
        // Set 2: FIPS-197 Example Vector
        // Key: 2b7e...
        // Plaintext: 6bc1... (We expect this back)
        // Ciphertext: 3ad77bb40d7a3660a89ecaf32466ef97
        // ---------------------------------------------------------
        rst_n = 0; #20; rst_n = 1;

        r_Key         = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        r_Cipher_Text = 128'h3ad77bb40d7a3660a89ecaf32466ef97;
        
        #500;
        $display("Set 2 Input  | Key: %h, Cipher: %h", r_Key, r_Cipher_Text);
        $display("Set 2 Output | Plain: %h (Expected: 6bc1bee22e409f96e93d7e117393172a)", w_Plain_Text);

        // ---------------------------------------------------------
        // Set 3: ASCII "Coding Is Fun!!!"
        // Key: "Coding Is Fun!!!"
        // Plaintext: "Hello World!!!!!"
        // Ciphertext: 025b0e5192135069c9444f9f46820556
        // ---------------------------------------------------------
        rst_n = 0; #20; rst_n = 1;

        r_Key         = 128'h436f64696e672049732046756e212121;
        r_Cipher_Text = 128'h45e85f234911a3197c16c18a1bc334b9;
        
        #500;
        $display("Set 3 Input  | Key: %h, Cipher: %h", r_Key, r_Cipher_Text);
        $display("Set 3 Output | Plain: %h (Expected: 48656c6c6f20576f726c642121212121)", w_Plain_Text);

        // End simulation
        $finish;
    end
           
endmodule
