library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.all;

entity mm_unit_tb is
end mm_unit_tb;

architecture testbench of mm_unit_tb is
signal clk: std_logic:='0';	
signal reset: std_logic:='0';  									   
signal instruction_array:std_logic_vector(24 downto 0);
constant period : time := 20 ns;	
signal done_loading: std_logic:='0';	
signal systemOutput: std_logic_vector(127 downto 0):=(others=>'0');												  

type ia is array (24 downto 0) of std_logic_vector(24 downto 0);
signal i_array : ia:= (
"0000011101010011000010001",
"1000001001100010100000001",
"1000100111111000010000110",
"1001010101011001100011110",
"1001100101101111101011101",
"1010000111000111001110000",
"1010101110011100001000001",
"1011000110110111000011110",
"1011101110001011011011111",
"1100000000000000000000000",
"1100000001100111101100001",
"1100000010100111110000110",
"1100000011101000011001011",
"1100000100010100010101010",
"1100000101100010100101110",
"1100000110001111000010001",
"1100000111010010100000100",
"1100001000100111000001100",
"1100001001111111101101101",
"1100001010000111100000101",
"1100001011110010010100011",
"1100001100100111000101111",
"1100001101011101010010101",
"1100001110111101101001000",
"1100001111010010101100111"	 
);
begin	
	UUT : entity four_stage_pipelined_multimedia_unit port map (instruction_array => instruction_array, clk=>clk, reset=>reset, mmOut => systemOutput);
		
	reset <= '1', '0' after 2 * period;	 
	
	loading: process
	variable row : line; 
	variable vect : std_logic_vector(24 downto 0);	
	FILE instr_vector: TEXT;
	constant file_name:string:="binary_instructions.txt";
	variable h:integer:=0;
	begin  						  
		if(h = 0) then 
			file_open(instr_vector, file_name, read_mode);						   
			while((not endfile(instr_vector)) and (h<25)) loop
				readline(instr_vector, row);   
				read(row, vect);
				instruction_array <= vect; --add value from test file  
				if (h = 24) then
					done_loading <= '1';
				end if;
				h:=h+1;	
				wait for period;
			end loop; 		   
			h:=0;
			file_close(instr_vector);   
			wait;
		end if;
	end process;		 

--	check: process(systemOutput)
--	variable row2 : line; 
--	variable vect2 : std_logic_vector(24 downto 0);
--	FILE expected_out: TEXT;
--	constant file_name2:string:="expected_out.txt";
--	variable counter:integer:=0;
--	begin 
--		if (counter = 0) then
--			file_open(expected_out, file_name2, read_mode);	
--		end if;
--		
--		readline(expected_out, row2);   
--		read(row2, vect2);
--		assert systemOutput = vect2
--		report "Error when counter is " & integer'image(counter) 
--		severity error;
--		counter:=counter+1;	 
--		
--		if (counter>63) then
--			file_close(instr_vector);
--		end if;
--	end process;

	clock: process
	begin  
		wait until done_loading = '1';
		for i in 0 to 100 loop
			clk <= not clk;
			wait for period/2;
		end loop;
		wait;
	end process;
end testbench;