/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

  /*verilator lint_off UNUSEDSIGNAL*/
  /* verilator lint_off UNOPTFLAT */

`default_nettype none

module tt_um_8_bit_cpu_seyon_satheesh (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  // assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  // assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  // wire _unused = &{ena, clk, rst_n, 1'b0};
  wire _unused = &{ena, rst_n, 1'b0};

  //////////////////////////////////////

  assign uio_oe = 8'b00000000; // Always IO as input


  ////////////////  KEY INTERNAL VALUES  ////////////////

  wire [127:0] ram;

  wire [7:0] register_a;
  wire [7:0] register_b;
  wire [7:0] register_c;

  wire [3:0] instruction_address;

  wire [7:0] current_instruction = ram[(instruction_address * 8) +: 8];
  // wire [7:0] current_instruction = ram[(instruction_address << 3) +: 8];

  // wire current_instruction[7:0] = [(instruction_address << 3) - 8:(instruction_address << 3)];
  // wire instruction_address_start = instruction_address << 3;
  // wire current_instruction[7:0] = [(instruction_address << 3) +: 8];
  // wire current_instruction[7:0] = ram[(instruction_address << 3) - 8 +: 8];
  // wire instruction_address_start[7:0] = (instruction_address << 3) - 8;
  // wire current_instruction[7:0] = ram[instruction_address_start +: 8];
  // wire instruction_address_start[6:0] = instruction_address * 8;
  // wire instruction_address_start[6:0];
  // assign instruction_address_start[0] = 0;
  // assign instruction_address_start[1] = 0;
  // assign instruction_address_start[2] = 0;
  // assign instruction_address_start[3] = instruction_address[0];
  // assign instruction_address_start[4] = instruction_address[1];
  // assign instruction_address_start[5] = instruction_address[2];
  // assign instruction_address_start[6] = instruction_address[3];

  // wire current_instruction[7:0] = ram[instruction_address_start +: 8];
  // wire current_instruction[7:0];
  // assign current_instruction[0] = ram[instruction_address_start[6:0]];
  // assign current_instruction[1] = ram[instruction_address_start[6:0] + 1];
  // assign current_instruction[2] = ram[instruction_address_start[6:0] + 2];
  // assign current_instruction[3] = ram[instruction_address_start[6:0] + 3];
  // assign current_instruction[4] = ram[instruction_address_start[6:0] + 4];
  // assign current_instruction[5] = ram[instruction_address_start[6:0] + 5];
  // assign current_instruction[6] = ram[instruction_address_start[6:0] + 6];
  // assign current_instruction[7] = ram[instruction_address_start[6:0] + 7];

  // wire NOP = (!current_instruction[7]) & (!current_instruction[6]) & (!current_instruction[5]) & (!current_instruction[4]);
  wire LDA1 = (!current_instruction[7]) & (!current_instruction[6]) & (!current_instruction[5]) & current_instruction[4];
  wire LDA2 = (!current_instruction[7]) & (!current_instruction[6]) & current_instruction[5] & (!current_instruction[4]);
  wire LDB1 = (!current_instruction[7]) & (!current_instruction[6]) & current_instruction[5] & current_instruction[4];
  wire LDB2 = (!current_instruction[7]) & current_instruction[6] & (!current_instruction[5]) & (!current_instruction[4]);
  wire LDC1 = (!current_instruction[7]) & current_instruction[6] & (!current_instruction[5]) & current_instruction[4];
  wire LDC2 = (!current_instruction[7]) & current_instruction[6] & current_instruction[5] & (!current_instruction[4]);
  wire ADD = (!current_instruction[7]) & current_instruction[6] & current_instruction[5] & current_instruction[4];
  wire SUB = current_instruction[7] & (!current_instruction[6]) & (!current_instruction[5]) & (!current_instruction[4]);
  wire MUL = current_instruction[7] & (!current_instruction[6]) & (!current_instruction[5]) & current_instruction[4];
  wire OUT = current_instruction[7] & (!current_instruction[6]) & current_instruction[5] & (!current_instruction[4]);
  wire IN = current_instruction[7] & (!current_instruction[6]) & current_instruction[5] & current_instruction[4];

  ////////////////  EXTERNAL DATA WIRES  ////////////////

  wire on = uio_in[7]; // 1 - ON, 0 - OFF
  wire reset = !uio_in[6]; // 1 - RESET, 0 - DON'T RESET

  wire write_external_data_to_ram = (!uio_in[5]) & uio_in[4]; // uio_in[7] is ON/OFF, uio_in[6] is RESET/DON'T RESET, uio_out[3:0] is address

  ////////////////  INTERNAL DATA WIRES  ////////////////

  wire should_increment_instruction_address = clk & on;

  ////////////////  RESET  ////////////////

  // d_latch_8_bit dl8b_1(v, e, r);

  // d_latch_8_bit reset_a(8'b00000000, reset, register_a[7:0]);
  // d_latch_8_bit reset_b(8'b00000000, reset, register_b[7:0]);
  // d_latch_8_bit reset_c(8'b00000000, reset, register_c[7:0]);
  // d_latch_128_bit reset_ram(128'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000, reset, ram[127:0]);
  // d_latch_4_bit reset_instruction_address(4'b0000, reset, instruction_address[3:0]);

  ////////////////  EXTERNAL RAM LOADING  ////////////////

  wire load_ram_address_1 = write_external_data_to_ram & !(uio_in[3]) & !(uio_in[2]) & !(uio_in[1]) & !(uio_in[0]);
  wire load_ram_address_2 = write_external_data_to_ram & !(uio_in[3]) & !(uio_in[2]) & !(uio_in[1]) & uio_in[0];
  wire load_ram_address_3 = write_external_data_to_ram & !(uio_in[3]) & !(uio_in[2]) & uio_in[1] & !(uio_in[0]);
  wire load_ram_address_4 = write_external_data_to_ram & !(uio_in[3]) & !(uio_in[2]) & uio_in[1] & uio_in[0];
  wire load_ram_address_5 = write_external_data_to_ram & !(uio_in[3]) & uio_in[2] & !(uio_in[1]) & !(uio_in[0]);
  wire load_ram_address_6 = write_external_data_to_ram & !(uio_in[3]) & uio_in[2] & !(uio_in[1]) & uio_in[0];
  wire load_ram_address_7 = write_external_data_to_ram & !(uio_in[3]) & uio_in[2] & uio_in[1] & !(uio_in[0]);
  wire load_ram_address_8 = write_external_data_to_ram & !(uio_in[3]) & uio_in[2] & uio_in[1] & uio_in[0];
  wire load_ram_address_9 = write_external_data_to_ram & uio_in[3] & !(uio_in[2]) & !(uio_in[1]) & !(uio_in[0]);
  wire load_ram_address_10 = write_external_data_to_ram & uio_in[3] & !(uio_in[2]) & !(uio_in[1]) & uio_in[0];
  wire load_ram_address_11 = write_external_data_to_ram & uio_in[3] & !(uio_in[2]) & uio_in[1] & !(uio_in[0]);
  wire load_ram_address_12 = write_external_data_to_ram & uio_in[3] & !(uio_in[2]) & uio_in[1] & uio_in[0];
  wire load_ram_address_13 = write_external_data_to_ram & uio_in[3] & uio_in[2] & !(uio_in[1]) & !(uio_in[0]);
  wire load_ram_address_14 = write_external_data_to_ram & uio_in[3] & uio_in[2] & !(uio_in[1]) & uio_in[0];
  wire load_ram_address_15 = write_external_data_to_ram & uio_in[3] & uio_in[2] & uio_in[1] & !(uio_in[0]);
  wire load_ram_address_16 = write_external_data_to_ram & uio_in[3] & uio_in[2] & uio_in[1] & uio_in[0];

  wire [127:0] ram_loaded;

  d_latch_8_bit external_ram_loader_1(ui_in[7:0], load_ram_address_1, ram_loaded[7:0]);
  d_latch_8_bit external_ram_loader_2(ui_in[7:0], load_ram_address_2, ram_loaded[15:8]);
  d_latch_8_bit external_ram_loader_3(ui_in[7:0], load_ram_address_3, ram_loaded[23:16]);
  d_latch_8_bit external_ram_loader_4(ui_in[7:0], load_ram_address_4, ram_loaded[31:24]);
  d_latch_8_bit external_ram_loader_5(ui_in[7:0], load_ram_address_5, ram_loaded[39:32]);
  d_latch_8_bit external_ram_loader_6(ui_in[7:0], load_ram_address_6, ram_loaded[47:40]);
  d_latch_8_bit external_ram_loader_7(ui_in[7:0], load_ram_address_7, ram_loaded[55:48]);
  d_latch_8_bit external_ram_loader_8(ui_in[7:0], load_ram_address_8, ram_loaded[63:56]);
  d_latch_8_bit external_ram_loader_9(ui_in[7:0], load_ram_address_9, ram_loaded[71:64]);
  d_latch_8_bit external_ram_loader_10(ui_in[7:0], load_ram_address_10, ram_loaded[79:72]);
  d_latch_8_bit external_ram_loader_11(ui_in[7:0], load_ram_address_11, ram_loaded[87:80]);
  d_latch_8_bit external_ram_loader_12(ui_in[7:0], load_ram_address_12, ram_loaded[95:88]);
  d_latch_8_bit external_ram_loader_13(ui_in[7:0], load_ram_address_13, ram_loaded[103:96]);
  d_latch_8_bit external_ram_loader_14(ui_in[7:0], load_ram_address_14, ram_loaded[111:104]);
  d_latch_8_bit external_ram_loader_15(ui_in[7:0], load_ram_address_15, ram_loaded[119:112]);
  d_latch_8_bit external_ram_loader_16(ui_in[7:0], load_ram_address_16, ram_loaded[127:120]);

  ////////////////  PROGRAM COUNTER  ////////////////

  wire [3:0] program_counter;

  binary_counter_4_bit bc4b(should_increment_instruction_address, program_counter);

  ////////////////  ALU  ////////////////

  wire [7:0] sum;
  wire [7:0] difference;
  wire [7:0] product;

  wire should_sum = ADD & on;
  wire should_minus = SUB & on;
  wire should_multiply = MUL & on;

  wire [7:0] reg_c_alu;

  wire [7:0] reg_c_alu_sum;
  wire [7:0] reg_c_alu_difference;
  wire [7:0] reg_c_alu_product;

  adder_8_bit summer(register_a, register_b, sum);
  subtracter_8_bit minuser(register_a, register_b, difference);
  multiplier_8_bit multiplier(register_a, register_b, product);

  d_latch_8_bit load_sum(sum, should_sum, reg_c_alu_sum);
  d_latch_8_bit load_difference(difference, should_minus, reg_c_alu_difference);
  d_latch_8_bit load_product(product, should_multiply, reg_c_alu_product);

  ////////////////  REGISTER VALUE LOADER  ////////////////

  wire should_load_a_1 = LDA1 & on;
  wire should_load_a_2 = LDA2 & on;
  wire should_load_b_1 = LDB1 & on;
  wire should_load_b_2 = LDB2 & on;
  wire should_load_c_1 = LDC1 & on;
  wire should_load_c_2 = LDC2 & on;

  wire [7:0] reg_a_loader;
  wire [7:0] reg_b_loader;
  wire [7:0] reg_c_loader;

  d_latch_4_bit reg_a_load_1(current_instruction[3:0], should_load_a_1, reg_a_loader[3:0]);
  d_latch_4_bit reg_a_load_2(current_instruction[3:0], should_load_a_2, reg_a_loader[7:4]);
  d_latch_4_bit reg_b_load_1(current_instruction[3:0], should_load_b_1, reg_b_loader[3:0]);
  d_latch_4_bit reg_b_load_2(current_instruction[3:0], should_load_b_2, reg_b_loader[7:4]);
  d_latch_4_bit reg_c_load_1(current_instruction[3:0], should_load_c_1, reg_c_loader[3:0]);
  d_latch_4_bit reg_c_load_2(current_instruction[3:0], should_load_c_2, reg_c_loader[7:4]);

  ////////////////  INPUT VALUE INTO REGISTER  ////////////////

  wire should_input_reg_a = IN & on & !(current_instruction[3]) & !(current_instruction[2]) & !(current_instruction[1]) & !(current_instruction[0]);
  wire should_input_reg_b = IN & on & !(current_instruction[3]) & !(current_instruction[2]) & !(current_instruction[1]) & current_instruction[0];
  wire should_input_reg_c = IN & on & !(current_instruction[3]) & !(current_instruction[2]) & current_instruction[1] & !(current_instruction[0]);

  wire [7:0] reg_a_input;
  wire [7:0] reg_b_input;
  wire [7:0] reg_c_input;

  d_latch_8_bit reg_a_inputer(ui_in, should_input_reg_a, reg_a_input);
  d_latch_8_bit reg_b_inputer(ui_in, should_input_reg_b, reg_b_input);
  d_latch_8_bit reg_c_inputer(ui_in, should_input_reg_c, reg_c_input);

  ////////////////  OUTPUT REGISTER VALUE  ////////////////

  wire should_output_reg_a = OUT & on & !(current_instruction[3]) & !(current_instruction[2]) & !(current_instruction[1]) & !(current_instruction[0]);
  wire should_output_reg_b = OUT & on & !(current_instruction[3]) & !(current_instruction[2]) & !(current_instruction[1]) & current_instruction[0];
  wire should_output_reg_c = OUT & on & !(current_instruction[3]) & !(current_instruction[2]) & current_instruction[1] & !(current_instruction[0]);

  // d_latch_8_bit reg_a_output(register_a, should_output_reg_a, uo_out);
  // d_latch_8_bit reg_b_output(register_b, should_output_reg_b, uo_out);
  // d_latch_8_bit reg_c_output(register_c, should_output_reg_c, uo_out);

  assign uo_out = (reset) ? 8'b00000000:
                  (should_output_reg_a) ? register_a:
                  (should_output_reg_b) ? register_b:
                  (should_output_reg_c) ? register_c:
                  8'b00000000;

  ////////////////  REGISTERS  ////////////////

  assign reg_c_alu[7:0] = (reset) ? 8'b00000000:
                          (should_sum) ? reg_c_alu_sum:
                          (should_minus) ? reg_c_alu_difference:
                          (should_multiply) ? reg_c_alu_product:
                          8'b00000000;

  wire [3:0] reg_a_value_1 = (reset) ? 4'b0000:
                             (should_load_a_1) ? reg_a_loader[3:0]:
                             (should_input_reg_a) ? reg_a_input[3:0]:
                             4'b0000;
  wire [3:0] reg_a_value_2 = (reset) ? 4'b0000:
                             (should_load_a_2) ? reg_a_loader[7:4]:
                             (should_input_reg_a) ? reg_a_input[7:4]:
                             4'b0000;
  wire [3:0] reg_b_value_1 = (reset) ? 4'b0000:
                             (should_load_b_1) ? reg_b_loader[3:0]:
                             (should_input_reg_b) ? reg_b_input[3:0]:
                             4'b0000;
  wire [3:0] reg_b_value_2 = (reset) ? 4'b0000:
                             (should_load_b_2) ? reg_b_loader[7:4]:
                             (should_input_reg_b) ? reg_b_input[7:4]:
                             4'b0000;
  wire [3:0] reg_c_value_1 = (reset) ? 4'b0000:
                             (should_load_c_1) ? reg_c_loader[3:0]:
                             (should_input_reg_c) ? reg_c_input[3:0]:
                             (should_sum || should_minus || should_multiply) ? reg_c_alu[3:0]:
                             4'b0000;
  wire [3:0] reg_c_value_2 = (reset) ? 4'b0000:
                             (should_load_c_2) ? reg_c_loader[7:4]:
                             (should_input_reg_c) ? reg_c_input[7:4]:
                             (should_sum || should_minus || should_multiply) ? reg_c_alu[7:4]:
                             4'b0000;

  wire [7:0] reg_a_value;
  assign reg_a_value[3:0] = reg_a_value_1;
  assign reg_a_value[7:4] = reg_a_value_2;

  wire [7:0] reg_b_value;
  assign reg_b_value[3:0] = reg_b_value_1;
  assign reg_b_value[7:4] = reg_b_value_2;

  wire [7:0] reg_c_value;
  assign reg_c_value[3:0] = reg_c_value_1;
  assign reg_c_value[7:4] = reg_c_value_2;

  wire should_update_reg_a = reset | should_load_a_1 | should_load_a_2 | should_input_reg_a;
  wire should_update_reg_b = reset | should_load_b_1 | should_load_b_2 | should_input_reg_b;
  wire should_update_reg_c = reset | should_load_c_1 | should_load_c_2 | should_input_reg_c;

  d_latch_8_bit final_register_a(reg_a_value, should_update_reg_a, register_a);
  d_latch_8_bit final_register_b(reg_b_value, should_update_reg_b, register_b);
  d_latch_8_bit final_register_c(reg_c_value, should_update_reg_c, register_c);

  //////

  wire [127:0] ram_value;

  assign ram_value[7:0] = (reset) ? 8'b00000000:
                        (load_ram_address_1) ? ram_loaded[7:0]:
                        8'b00000000;
  assign ram_value[15:8] = (reset) ? 8'b00000000:
                        (load_ram_address_2) ? ram_loaded[15:8]:
                        8'b00000000;
  assign ram_value[23:16] = (reset) ? 8'b00000000:
                        (load_ram_address_3) ? ram_loaded[23:16]:
                        8'b00000000;
  assign ram_value[31:24] = (reset) ? 8'b00000000:
                        (load_ram_address_4) ? ram_loaded[31:24]:
                        8'b00000000;
  assign ram_value[39:32] = (reset) ? 8'b00000000:
                        (load_ram_address_5) ? ram_loaded[39:32]:
                        8'b00000000;
  assign ram_value[47:40] = (reset) ? 8'b00000000:
                        (load_ram_address_6) ? ram_loaded[47:40]:
                        8'b00000000;
  assign ram_value[55:48] = (reset) ? 8'b00000000:
                        (load_ram_address_7) ? ram_loaded[55:48]:
                        8'b00000000;
  assign ram_value[63:56] = (reset) ? 8'b00000000:
                        (load_ram_address_8) ? ram_loaded[63:56]:
                        8'b00000000;
  assign ram_value[71:64] = (reset) ? 8'b00000000:
                        (load_ram_address_9) ? ram_loaded[71:64]:
                        8'b00000000;
  assign ram_value[79:72] = (reset) ? 8'b00000000:
                        (load_ram_address_10) ? ram_loaded[79:72]:
                        8'b00000000;
  assign ram_value[87:80] = (reset) ? 8'b00000000:
                        (load_ram_address_11) ? ram_loaded[87:80]:
                        8'b00000000;
  assign ram_value[95:88] = (reset) ? 8'b00000000:
                        (load_ram_address_12) ? ram_loaded[95:88]:
                        8'b00000000;
  assign ram_value[103:96] = (reset) ? 8'b00000000:
                        (load_ram_address_13) ? ram_loaded[103:96]:
                        8'b00000000;
  assign ram_value[111:104] = (reset) ? 8'b00000000:
                        (load_ram_address_14) ? ram_loaded[111:104]:
                        8'b00000000;
  assign ram_value[119:112] = (reset) ? 8'b00000000:
                        (load_ram_address_15) ? ram_loaded[119:112]:
                        8'b00000000;
  assign ram_value[127:120] = (reset) ? 8'b00000000:
                        (load_ram_address_16) ? ram_loaded[127:120]:
                        8'b00000000;

  wire should_update_ram = reset | load_ram_address_1 | load_ram_address_2 | load_ram_address_3 | load_ram_address_4 | load_ram_address_5 | load_ram_address_6 | load_ram_address_7 | load_ram_address_8 | load_ram_address_9 | load_ram_address_10 | load_ram_address_11 | load_ram_address_12 | load_ram_address_13 | load_ram_address_14 | load_ram_address_15 | load_ram_address_16;

  d_latch_128_bit final_ram(ram_value, should_update_ram, ram);

  ////////////

  assign instruction_address[3:0] = (reset) ? 4'b0000:
                                    (should_increment_instruction_address) ? program_counter:
                                    4'b0000;

endmodule

//////////////////////////////////////////

module d_latch_128_bit (
    input wire [127:0] value,
    input wire enable,
    output wire [127:0] result
);

  d_latch_64_bit dl64b_1(value[127:64], enable, result[127:64]);
  d_latch_64_bit dl64b_2(value[63:0], enable, result[63:0]);

endmodule

module d_latch_64_bit (
    input wire [63:0] value,
    input wire enable,
    output wire [63:0] result
);

  d_latch_32_bit dl32b_1(value[63:32], enable, result[63:32]);
  d_latch_32_bit dl32b_2(value[31:0], enable, result[31:0]);

endmodule

module d_latch_32_bit (
    input wire [31:0] value,
    input wire enable,
    output wire [31:0] result
);

  d_latch_16_bit dl16b_1(value[31:16], enable, result[31:16]);
  d_latch_16_bit dl16b_2(value[15:0], enable, result[15:0]);

endmodule

module d_latch_16_bit (
    input wire [15:0] value,
    input wire enable,
    output wire [15:0] result
);

  d_latch_8_bit dl8b_1(value[15:8], enable, result[15:8]);
  d_latch_8_bit dl8b_2(value[7:0], enable, result[7:0]);

endmodule

module d_latch_8_bit (
    input wire [7:0] value,
    input wire enable,
    output wire [7:0] result
);

  d_latch_4_bit dl4b_1(value[7:4], enable, result[7:4]);
  d_latch_4_bit dl4b_2(value[3:0], enable, result[3:0]);

endmodule

module d_latch_4_bit (
    input wire [3:0] value,
    input wire enable,
    output wire [3:0] result
);

  d_latch_1_bit dl1b_1(value[3], enable, result[3]);
  d_latch_1_bit dl1b_2(value[2], enable, result[2]);
  d_latch_1_bit dl1b_3(value[1], enable, result[1]);
  d_latch_1_bit dl1b_4(value[0], enable, result[0]);

endmodule

module d_latch_1_bit (
    input wire value,
    input wire enable,
    output reg result
);

  // OLD

  wire not_value = !value;

  wire top_1, top_2;
  wire bottom_1, bottom_2;

  wire buffer_top, buffer_bottom; // NEW

  and and_1(top_1, not_value, enable);
  and and_2(bottom_1, value, enable);

  nor nor_1(buffer_top, top_1, bottom_2);
  nor nor_2(buffer_bottom, bottom_1, top_2);

  assign top_2 = buffer_top;
  assign bottom_2 = buffer_bottom;

  assign result = top_2;

  // and and_1(top_1, not_value, enable);
  // and and_2(bottom_1, value, enable);
  //
  // nor nor_1(top_2, top_1, bottom_2);
  // nor nor_2(bottom_2, bottom_1, top_2);
  //
  // assign result = top_2;

  // NEW

  // always @ (*) begin
  //   if (enable) begin
  //     result = value;
  //   end else begin
  //     result = result;
  //   end
  // end

  // wire top1 = !value & enable;
  // wire bottom1 = value & enable;
  //
  // wire top2;
  // wire bottom2;
  //
  // wire top3;
  // wire bottom3;
  //
  // assign result = ();


endmodule

////////////////////////////////////

module binary_counter_4_bit (
    input wire clock,
    output wire [3:0] counter
);

  j_k_master_slave_flip_flop jkmsff_1(1'b1, 1'b1, clock, counter[0]);
  j_k_master_slave_flip_flop jkmsff_2(1'b1, 1'b1, counter[0], counter[1]);
  j_k_master_slave_flip_flop jkmsff_3(1'b1, 1'b1, counter[1], counter[2]);
  j_k_master_slave_flip_flop jkmsff_4(1'b1, 1'b1, counter[2], counter[3]);

endmodule

module j_k_master_slave_flip_flop (
    input wire j,
    input wire k,
    input wire clock,
    output reg result
);

  // OLD

  wire inverse_result;

  wire top_1, top_2, top_3, top_4, top_5;
  wire bottom_1, bottom_2, bottom_3, bottom_4, bottom_5;

  and and_top_1(top_1, j, inverse_result);
  and and_top_2(top_2, top_1, clock);
  nor nor_top_1(top_3, top_2, bottom_3);
  and and_top_3(top_4, top_3, clock);
  nor nor_top_2(top_5, top_4, bottom_5);

  and and_bottom_1(bottom_1, k, result);
  and and_bottom_2(bottom_2, bottom_1, clock);
  nor nor_bottom_1(bottom_3, bottom_2, top_3);
  and and_bottom_3(bottom_4, bottom_3, clock);
  nor nor_bottom_2(bottom_5, bottom_4, top_5);

  assign result = top_5;
  assign inverse_result = bottom_5;

  // NEW

  // always @ (*) begin
  //   if (clock && j) begin
  //     result = 1'b1;
  //   end else if (clock && k) begin
  //     result = 1'b0;
  //   end else begin
  //     result = result;
  //   end
  // end

endmodule

////////////////////////////////////

module adder_8_bit_with_carry (
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [7:0] c
);

  wire carry_1;
  wire carry_2;
  wire carry_3;
  wire carry_4;
  wire carry_5;
  wire carry_6;
  wire carry_7;

  wire ignore;

  full_adder_1_bit fa1b_1(a[0], b[0], 1'b1, c[0], carry_1);
  full_adder_1_bit fa1b_2(a[1], b[1], carry_1, c[1], carry_2);
  full_adder_1_bit fa1b_3(a[2], b[2], carry_2, c[2], carry_3);
  full_adder_1_bit fa1b_4(a[3], b[3], carry_3, c[3], carry_4);
  full_adder_1_bit fa1b_5(a[4], b[4], carry_4, c[4], carry_5);
  full_adder_1_bit fa1b_6(a[5], b[5], carry_5, c[5], carry_6);
  full_adder_1_bit fa1b_7(a[6], b[6], carry_6, c[6], carry_7);
  full_adder_1_bit fa1b_8(a[7], b[7], carry_7, c[7], ignore);

endmodule

module adder_8_bit (
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [7:0] c
);

  wire carry_1;
  wire carry_2;
  wire carry_3;
  wire carry_4;
  wire carry_5;
  wire carry_6;
  wire carry_7;

  wire ignore;

  full_adder_1_bit fa1b_1(a[0], b[0], 1'b0, c[0], carry_1);
  full_adder_1_bit fa1b_2(a[1], b[1], carry_1, c[1], carry_2);
  full_adder_1_bit fa1b_3(a[2], b[2], carry_2, c[2], carry_3);
  full_adder_1_bit fa1b_4(a[3], b[3], carry_3, c[3], carry_4);
  full_adder_1_bit fa1b_5(a[4], b[4], carry_4, c[4], carry_5);
  full_adder_1_bit fa1b_6(a[5], b[5], carry_5, c[5], carry_6);
  full_adder_1_bit fa1b_7(a[6], b[6], carry_6, c[6], carry_7);
  full_adder_1_bit fa1b_8(a[7], b[7], carry_7, c[7], ignore);

endmodule

module full_adder_1_bit (
    input wire a,
    input wire b,
    input wire c_in,
    output wire c,
    output wire c_out
);

  wire x;
  wire y;
  wire z;

  half_adder_1_bit ha1b_1(a, b, x, y);
  half_adder_1_bit ha1b_2(x, c_in, c, z);

  or or_1(c_out, y, z);

endmodule

module half_adder_1_bit (
    input wire a,
    input wire b,
    output wire c,
    output wire c_out
);

  and and_1(c_out, a, b);
  xor xor_1(c, a, b);

endmodule

module subtracter_8_bit (
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [7:0] c
);

  wire [7:0] inverted_b;

  assign inverted_b[0] = !b[0];
  assign inverted_b[1] = !b[1];
  assign inverted_b[2] = !b[2];
  assign inverted_b[3] = !b[3];
  assign inverted_b[4] = !b[4];
  assign inverted_b[5] = !b[5];
  assign inverted_b[6] = !b[6];
  assign inverted_b[7] = !b[7];

  adder_8_bit_with_carry a8bwc(a, inverted_b, c);

endmodule

module multiplier_8_bit (
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [7:0] c
);

  // wire product_1[7:0] = {{a[7] & b[0]}, {a[6] & b[0]}, (a[5] & b[0]), (a[4] & b[0]), (a[3] & b[0]), (a[2] & b[0]), (a[1] & b[0]), (a[0] & b[0])};
  // wire product_2[7:0] = {{a[6] & b[1]}, {a[5] & b[1]}, (a[4] & b[1]), (a[3] & b[1]), (a[2] & b[1]), (a[1] & b[1]), (a[0] & b[1]), 1b'0};
  // wire product_3[7:0] = {{a[5] & b[2]}, {a[4] & b[2]}, (a[3] & b[2]), (a[2] & b[2]), (a[1] & b[2]), (a[0] & b[2]), 1b'0, 1b'0};
  // wire product_4[7:0] = {{a[4] & b[3]}, {a[3] & b[3]}, (a[2] & b[3]), (a[1] & b[3]), (a[0] & b[3]), 1b'0, 1b'0, 1b'0};
  // wire product_5[7:0] = {{a[3] & b[4]}, {a[2] & b[4]}, (a[1] & b[4]), (a[0] & b[4]), 1b'0, 1b'0, 1b'0, 1b'0};
  // wire product_6[7:0] = {{a[2] & b[5]}, {a[1] & b[5]}, (a[0] & b[5]), 1b'0, 1b'0, 1b'0, 1b'0, 1b'0};
  // wire product_7[7:0] = {{a[1] & b[6]}, {a[0] & b[6]}, 1b'0, 1b'0, 1b'0, 1b'0, 1b'0, 1b'0};
  // wire product_8[7:0] = {{a[0] & b[7]}, 1b'0, 1b'0, 1b'0, 1b'0, 1b'0, 1b'0, 1b'0};

  wire [7:0] product_1;
  wire [7:0] product_2;
  wire [7:0] product_3;
  wire [7:0] product_4;
  wire [7:0] product_5;
  wire [7:0] product_6;
  wire [7:0] product_7;
  wire [7:0] product_8;

  assign product_1[7] = {a[7] & b[0]};
  assign product_1[6] = {a[6] & b[0]};
  assign product_1[5] = {a[5] & b[0]};
  assign product_1[4] = {a[4] & b[0]};
  assign product_1[3] = {a[3] & b[0]};
  assign product_1[2] = {a[2] & b[0]};
  assign product_1[1] = {a[1] & b[0]};
  assign product_1[0] = {a[0] & b[0]};

  assign product_2[7] = {a[6] & b[1]};
  assign product_2[6] = {a[5] & b[1]};
  assign product_2[5] = {a[4] & b[1]};
  assign product_2[4] = {a[3] & b[1]};
  assign product_2[3] = {a[2] & b[1]};
  assign product_2[2] = {a[1] & b[1]};
  assign product_2[1] = {a[0] & b[1]};
  assign product_2[0] = 0;

  assign product_3[7] = {a[5] & b[2]};
  assign product_3[6] = {a[4] & b[2]};
  assign product_3[5] = {a[3] & b[2]};
  assign product_3[4] = {a[2] & b[2]};
  assign product_3[3] = {a[1] & b[2]};
  assign product_3[2] = {a[0] & b[2]};
  assign product_3[1] = 0;
  assign product_3[0] = 0;

  assign product_4[7] = {a[4] & b[3]};
  assign product_4[6] = {a[3] & b[3]};
  assign product_4[5] = {a[2] & b[3]};
  assign product_4[4] = {a[1] & b[3]};
  assign product_4[3] = {a[0] & b[3]};
  assign product_4[2] = 0;
  assign product_4[1] = 0;
  assign product_4[0] = 0;

  assign product_5[7] = {a[3] & b[4]};
  assign product_5[6] = {a[2] & b[4]};
  assign product_5[5] = {a[1] & b[4]};
  assign product_5[4] = {a[0] & b[4]};
  assign product_5[3] = 0;
  assign product_5[2] = 0;
  assign product_5[1] = 0;
  assign product_5[0] = 0;

  assign product_6[7] = {a[2] & b[5]};
  assign product_6[6] = {a[1] & b[5]};
  assign product_6[5] = {a[0] & b[5]};
  assign product_6[4] = 0;
  assign product_6[3] = 0;
  assign product_6[2] = 0;
  assign product_6[1] = 0;
  assign product_6[0] = 0;

  assign product_7[7] = {a[1] & b[6]};
  assign product_7[6] = {a[0] & b[6]};
  assign product_7[5] = 0;
  assign product_7[4] = 0;
  assign product_7[3] = 0;
  assign product_7[2] = 0;
  assign product_7[1] = 0;
  assign product_7[0] = 0;

  assign product_8[7] = {a[0] & b[7]};
  assign product_8[6] = 0;
  assign product_8[5] = 0;
  assign product_8[4] = 0;
  assign product_8[3] = 0;
  assign product_8[2] = 0;
  assign product_8[1] = 0;
  assign product_8[0] = 0;

  wire [7:0] sum_1;
  wire [7:0] sum_2;
  wire [7:0] sum_3;
  wire [7:0] sum_4;
  wire [7:0] sum_5;
  wire [7:0] sum_6;

  adder_8_bit a8b_1(product_1, product_2, sum_1);
  adder_8_bit a8b_2(sum_1, product_3, sum_2);
  adder_8_bit a8b_3(sum_2, product_4, sum_3);
  adder_8_bit a8b_4(sum_3, product_5, sum_4);
  adder_8_bit a8b_5(sum_4, product_6, sum_5);
  adder_8_bit a8b_6(sum_5, product_7, sum_6);
  adder_8_bit a8b_7(sum_6, product_8, c);

endmodule

/*verilator lint_on UNUSEDSIGNAL*/
/*verilator lint_on UNOPTFLAT*/
