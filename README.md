# Project Description
An ALU unit that performs a variety of computations based on MIPS instructions 
<br /> First take in a series of MIPS instructions and convert them into a string of binary instructions the ALU can read
<br /> Utilizing the first two bits of the select input you determine which of three instruction types to perform. A 00 or 01 means that you perform an immediate load of certain bits of select into a specific position in the destination register. A 10 means you'll be computing R4 instructions, which are a multiplying combination followed by addition or subtraction. Lastly, 11 refers to an R3 instruction which is the most diverse class of instruction varying from NOP, comparisons, and logical operations, to rotating bits
<br /> After decoding the instructions the ALU would execute the instruction based on another set of input memory, along with a forwarding unit that allows the unit to execute and output data concurrently with pipelined data

# Project Instructions

**Multimedia ALU**

- Takes up to three inputs from the Register File, and calculates the result based on the current instruction to be performed.

**Register File**

- The register file has 32 128-bit registers. On any cycle, there can be 3 reads and 1 write. When executing instructions, each cycle two/three 128-bit register values are read, and one 128-bit result can be written if a write signal is valid. This register write signal must be explicitly declared so it can be checked during the simulation and demonstration of your design.

**Instruction Buffer**

- The instruction buffer can store 64 25-bit instructions. The contents of the buffer should be loaded by the testbench instructions from a test file at the start of the simulation. On each cycle, the instruction specified by the Program Counter (PC) is fetched, and the value of PC is incremented by 1.

**Forwarding Unit**

- Every instruction must use the most recent value of a register, even if this value has not yet been written to the Register File. Be mindful of the ordering of instructions; the most recent value should be used, in the event of two consecutive writes to a register, followed by a read from that same register. Your processor should never stall in the event of hazards.

- Take extra care of which instructions require forwarding, and which ones do not. Namely, NOP and the instructions with Immediate fields do not contain one/two register sources. Only valid data and source/destination registers should be considered for forwarding.
    
**Four-Stage Pipelined Multimedia Unit**

- Clock edge-sensitive pipeline registers separate the IF, ID, EXE, and WB stages. Data should be written to the Register File after the WB Stage.

- All instructions (including li) take four cycles to complete. This pipeline must be implemented as a structural model with modules for each corresponding pipeline stages and their interstage registers. Four instructions can be at different stages of the pipeline at every cycle.

**Testbench**

- This module loads the instruction buffer using data loaded from a file, begins simulation, and upon completion, compares the contents of the register file to a file containing the expected results.

**Assembler**
- This is a separate program written in any language your team prefers (i.e. Java, C++, Python). Its purpose is to convert an assembly file to the binary format for the Instruction Buffer.

**Results File**
- This file must show the status of the pipeline for each cycle during program execution. It includes the opcodes, input operand, and results of the execution of instructions, as well as all relevant control signals and forwarding information. This should be carried out by your testbench.

# Instructions

**Instruction Formats and Opcode Description**

**Load Immediate**

- li: Load a 16-bit Immediate value from the [20:5] instruction field into the 16-bit field specified by the Load Index field [23:21] of the 128-bit register rd. Other fields of register rd are not changed. Note that a LI instruction first reads register rd and then (after inserting an immediate value into one of its fields) writes it back to register rd, i.e., register rd is both a source and destination register of the LI instruction!

**Multiply-Add and Multiply-Subtract R4-Instruction Format**

- Signed operations are performed with saturated rounding that takes the result, and sets a floor and ceiling corresponding to the max range for that data size. This means that instead of over/underflow wrapping, the max/min values are used.

- Below is shown the description for each operation:

**LI/SA/HL [22:20]**	

**000**	

- Signed Integer Multiply-Add Low with Saturation: Multiply low 16-bit-fields of each 32-bit field of registers rs3 and rs2, then add 32-bit products to 32-bit fields of register rs1, and save the result in register rd

**001**
	
- Signed Integer Multiply-Add High with Saturation: Multiply high 16-bit-fields of each 32-bit field of registers rs3 and rs2, then add 32-bit products to 32-bit fields of register rs1, and save the result in register rd

**010**

- Signed Integer Multiply-Subtract Low with Saturation: Multiply low 16-bit-fields of each 32-bit field of registers rs3 and rs2, then subtract 32-bit products from 32-bit fields of register rs1, and save the result in register rd

**011**
	
- Signed Integer Multiply-Subtract High with Saturation: Multiply high 16-bit- fields of each 32-bit field of registers rs3 and rs2, then subtract 32-bit products from 32-bit fields of register rs1, and save the result in register rd

**100**
	
- Signed Long Integer Multiply-Add Low with Saturation: Multiply low 32-bit- fields of each 64-bit field of registers rs3 and rs2, then add 64-bit products to 64-bit fields of register rs1, and save the result in register rd

**101**
	
- Signed Long Integer Multiply-Add High with Saturation: Multiply high 32-bit- fields of each 64-bit field of registers rs3 and rs2, then add 64-bit products to 64-bit fields of register rs1, and save the result in register rd

**110**
	
- Signed Long Integer Multiply-Subtract Low with Saturation: Multiply low 32- bit-fields of each 64-bit field of registers rs3 and rs2, then subtract 64-bit products from 64-bit fields of register rs1, and save the result in register rd

**111**
	
- Signed Long Integer Multiply-Subtract High with Saturation: Multiply high 32- bit-fields of each 64-bit field of registers rs3 and rs2, then subtract 64-bit products from 64-bit fields of register rs1, and save the result in register rd

 
**R3-Instruction Format**

- In the table below, 16-bit signed integer add (AHS), subtract (SFHS), and multiply by sign (MLHSS) operations are performed with saturation to signed halfword rounding that takes a 16-bit signed integer X, and converts it to -32768 (the most negative 16-bit signed value) if it is less than -32768, to +32767 (the highest positive 16-bit signed value) if it is greater than 32767, and leaves it unchanged otherwise.

**Opcode [22:15]**

**xxxx0000**
	
- NOP: no operation. Make sure that a NOP instruction does not write anything to the register file!

**xxxx0001**
	
- SHRHI: shift right halfword immediate: packed 16-bit halfword shift right logical of the contents of register rs1 by the value of the 4 least significant bits of instruction field rs2. Each of the results is placed into the corresponding 16-bit slot in register rd. Bits shifted out for each halfword are dropped, and bits shifted into each halfword should be zeros. (Comments: 8 separate 16-bit values in each 128-bit register)

**xxxx0010**

- AU: add word unsigned: packed 32-bit unsigned addition of the contents of registers rs1 and rs2 (Comments: 4 separate 32-bit values in each 128-bit register)

**xxxx0011**

- CNT1H: count 1s in halfword: count 1s in each packed 16-bit halfword of the contents of register rs1. The results are placed into corresponding slots in register rd.  (Comments: 8 separate 16-bit values in each 128-bit register)

**xxxx0100**
	
- AHS: add halfword saturated: packed 16-bit halfword signed addition with saturation of the contents of registers rs1 and rs2. (Comments: 8 separate 16-bit values in each 128-bit register)

**xxxx0101**
	
- OR: bitwise logical or of the contents of registers rs1 and rs2

**xxxx0110**

- BCW: broadcast word: broadcast the rightmost 32-bit word of register rs1 to each of the four 32-bit words of register rd

**xxxx0111**
	
- MAXWS: max signed word: for each of the four 32-bit word slots, place the maximum signed value between rs1 and rs2 in register rd. (Comments: 4 separate 32-bit values in each128-bit register)

**xxx01000**
	
- MINWS: min signed word: for each of the four 32-bit word slots, place the minimum signed value between rs1 and rs2 in register rd. (Comments: 4 separate 32-bit values in each 128-bit register)

**xxxx1001**

- MLHU: multiply low unsigned: the 16 rightmost bits of each of the four 32-bit slots in register rs1 are multiplied by the 16 rightmost bits of the corresponding 32-bit slots in register rs2, treating both operands as unsigned. The four 32-bit products are placed into the corresponding slots of register rd. (Comments: 4 separate 32-bit values in each 128-bit register)

**xxxx1010**
	
- MLHSS: multiply by sign saturated: each of the eight signed 16-bit halfword values in register rs1 is multiplied by the sign of the corresponding signed 16-bit halfword value in register rs2 with saturation, and the result is placed in register rd. If a value in a 16-bit register rs2 field is zero, the corresponding 16-bit field in rd will also be zero. (Comments: 8 separate 16-bit values in each 128-bit register)

**xxxx1011**
	
- AND: bitwise logical and of the contents of registers rs1 and rs2

**xxxx1100**

- INVB: invert (flip) bits of the contents of register rs1. The result is placed in register rd.

**xxxx1101**	

- ROTW: rotate bits in word: the contents of each 32-bit field in register rs1 are rotated to the right according to the value of the 5 least significant bits of the corresponding 32-bit field in register rs2. The results are placed in register rd. Bits rotated out of the right end of each word are rotated in on the left end of the same 32-bit word field. (Comments: 4 separate 32-bit word values in each 128-bit register)

**xxxx1110**
	
- SFWU: subtract from word unsigned: packed 32-bit word unsigned subtract of the contents of rs1 from rs2 (rd = rs2 - rs1). (Comments: 4 separate 32-bit values in each 128-bit register)

**xxxx1111**
	
SFHS: subtract from halfword saturated: packed 16-bit halfword signed subtraction with the saturation of the contents of rs1 from rs2 (rd = rs2 - rs1). (Comments: 8 separate 16-bit values in each 128-bit 
