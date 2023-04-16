# ESE-345-Project-Part-1
An ALU unit that performs a variety of computations based on MIPS instructions 
<br /> First take in a series of MIPS instructions and convert them into a string of binary instructions the ALU can read
<br /> Utilizing the first two bits of the select input you determine which of three instruction types to perform. A 00 or 01 means that you perform an immediate load of certain bits of select into a specific position in the destination register. A 10 means you'll be computing R4 instructions, which are a multiplying combination followed by addition or subtraction. Lastly, 11 refers to an R3 instruction which is the most diverse class of instruction varying from NOP, comparisons, and logical operations, to rotating bits
<br /> After decoding the instructions the ALU would execute the instruction based on another set of input memory, along with a forwarding unit that allows the unit to execute and output data concurrently with pipelined data
