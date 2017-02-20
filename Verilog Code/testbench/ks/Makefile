TOPLEVEL = state_machine_scalar_mul

PWD = $(shell pwd)
COCOTB = ~/devel/cocotb
SRC = $(PWD)/../../hdl/multipliers

VERILOG_SOURCES = $(SRC)/state_machine_scalar_mul.v $(SRC)/Ram_interface_scalar_mul.v $(SRC)/Ram_transfer_scalar_mul.v $(SRC)/state_machine_3.v $(SRC)/scalar_multiplication_module.v $(SRC)/Ram_module_scalar_mul.v $(SRC)/state_machine_inverse.v $(SRC)/Ram_transfer.v $(SRC)/Outer_Ram_interface.v $(SRC)/point_addition_module.v $(SRC)/point_double_module.v $(SRC)/Outer_Ram_Module.v $(SRC)/inverse_itoha_tsuji_module.v $(SRC)/ideal_module.v $(SRC)/dma_sample_code.v $(SRC)/Xor_new.v $(SRC)/redution_256.v $(SRC)/Square_571.v $(SRC)/multiplication_recursive_module.v $(SRC)/Ram_data_swaping_module.v $(SRC)/Ram_Interface_Module.v $(SRC)/lower_bit_implementation.v $(SRC)/Masking_Module.v $(SRC)/LOOK_UP_table_module.v $(SRC)/Xor_192.v $(SRC)/LUT.v $(SRC)/Xor_16_bit.v $(SRC)/Ram_module.v $(SRC)/Xor_module.v $(SRC)/Xor_256_module.v $(SRC)/mul_64_module.v $(SRC)/sqr_slice_testing.v 
MODULE=test_ks #cocotb,test_discovery,test_external,test_regression

SIM_ARGS=-vcd

include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim