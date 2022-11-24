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
