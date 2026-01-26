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

        // ---------------------------------------------------------
        // Set 1: Sequential Bytes
        // ---------------------------------------------------------
        r_Key        = 128'h000102030405060708090a0b0c0d0e0f;
        r_Plain_Text = 128'h00112233445566778899aabbccddeeff;
        #100;
        $display("Set 1 Input  | Key: %h, Plain: %h", r_Key, r_Plain_Text);
        $display("Set 1 Output | Cipher: %h", w_Cipher_Text);

        // ---------------------------------------------------------
        // Set 2: FIPS-197 Example Vector
        // ---------------------------------------------------------
        r_Key        = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        r_Plain_Text = 128'h6bc1bee22e409f96e93d7e117393172a;
        #100;
        $display("Set 2 Input  | Key: %h, Plain: %h", r_Key, r_Plain_Text);
        $display("Set 2 Output | Cipher: %h", w_Cipher_Text);

        // ---------------------------------------------------------
        // Set 3: ASCII "Coding Is Fun!!!" / "Hello World!!!!!"
        // ---------------------------------------------------------
        r_Key        = 128'h436f64696e672049732046756e212121; // "Coding Is Fun!!!"
        r_Plain_Text = 128'h48656c6c6f20576f726c642121212121; // "Hello World!!!!!"
        #100;
        $display("Set 3 Input  | Key: %h, Plain: %h", r_Key, r_Plain_Text);
        $display("Set 3 Output | Cipher: %h", w_Cipher_Text);

        // End simulation
        $finish;
    end
           
endmodule