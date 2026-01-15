module encryption_test();

    reg clk;
    reg [127:0] r_Key;
    reg [127:0] r_Plain_Text;

    wire [127:0] w_Cipher_Text;

    // Use the NIST-compliant AES-128 (combinational, no clock needed)
    aes128_encrypt AES(
        .plaintext(r_Plain_Text),
        .key(r_Key),
        .ciphertext(w_Cipher_Text)
    );

    always #10 
        clk = ~clk;

    initial begin
        $dumpfile("encryption_test.vcd");
        $dumpvars(0, encryption_test);

        // Initialize signals
        clk = 0;
        r_Key = 128'h5b7e151628aed2a6abf7158809cf4f3c;  // NIST test key
        r_Plain_Text = 128'h4256f6a8885a308d313198a2e0370734;  // NIST test plaintext
        // Expected ciphertext: 3925841d02dc09fbdc118597196a0b32
        
        // Small delay for combinational logic to settle
        #100;
        
        // Display results
        $display("============================================");
        $display("AES-128 ECB Encryption Result");
        $display("============================================");
        $display("Key:        %h", r_Key);
        $display("Plaintext:  %h", r_Plain_Text);
        $display("Ciphertext: %h", w_Cipher_Text);
        $display("Expected:   3925841d02dc09fbdc118597196a0b32");
        $display("============================================");
        
        if (w_Cipher_Text == 128'h3925841d02dc09fbdc118597196a0b32)
            $display("SUCCESS: Output matches NIST standard!");
        else
            $display("MISMATCH: Output does not match expected value");
        
        // End simulation
        $finish;
    end
           
endmodule