#TOOL INPUT
SRC = hdl/AES/*.v hdl/aes_top_module.v
TESTBENCH = test/aes_encryption_testbench.v
TBOUTPUT = aes_encryption_testbench.vcd

#TOOLS
COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave

#TOOL OPTIONS
COFLAGS = -v -o
SFLAGS = -v

#TOOL OUTPUT
COUTPUT = compiler.out         

###############################################################################

simulate: $(COUTPUT)

	$(SIMULATOR) $(SFLAGS) $(COUTPUT) 

display: 
	$(VIEWER) $(TBOUTPUT) 

$(COUTPUT): $(TESTBENCH) $(SRC)
	$(COMPILER) $(COFLAGS) $(COUTPUT) $(TESTBENCH) $(SRC) 

clean:
	rm *.vcd
	rm *.out