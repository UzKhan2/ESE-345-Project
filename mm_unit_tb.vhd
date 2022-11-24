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
signal done_loading, done: std_logic:='0';	
signal systemOutput, register_status: std_logic_vector(127 downto 0):=(others=>'0');
signal rs1_d1_check, rs2_d1_check, rs3_d1_check:std_logic_vector(127 downto 0);
signal instr_d1_check, instruction_d1_check, instruction_fd1_check: std_logic_vector(24 downto 0);	
signal PC:integer:=0;
begin	
	UUT : entity four_stage_pipelined_multimedia_unit port map (instruction_array => instruction_array, clk=>clk, reset=>reset, done=>done, mmOut => systemOutput, rs1_d1_check=>rs1_d1_check, rs2_d1_check=>rs2_d1_check, rs3_d1_check=>rs3_d1_check, instruction_d1_check=>instruction_d1_check, instr_d1_check=>instr_d1_check, instruction_fd1_check=>instruction_fd1_check, register_status=>register_status);
		
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
	
	--status: process(clk)	 
--	FILE results: TEXT;
--	variable ln: line;  
--	constant header:string:="Status report for cycle:";
--	constant ifid_reg:string:="Status of the IF/ID register:";
--	constant idex_reg:string:="Status of the ID/EX register:";
--	constant exwb_reg:string:="Status of the EX/WB register:";
--	constant rs1_check_status:string:="Status of rs1 is:";
--	constant rs2_check_status:string:="Status of rs2 is:";
--	constant rs3_check_status:string:="Status of rs3 is:"; 
--	constant rd_check_status:string:="Status of rd is:";
--	constant empty_line:string:=" ";
--	constant instruction_check_status:string:="Status of instruction is:";
--	constant result_file_name:string:="results_file.txt";
--	begin  
--		if(rising_edge(clk)) then
--			file_open(results, result_file_name, write_mode);
--		
--			write(ln, header);
--			writeline(results, ln);	
--			write(ln, PC);
--			writeline(results, ln);
--			write(ln, empty_line);
--			writeline(results, ln);	
--		
--		
--			write(ln, ifid_reg);
--			writeline(results, ln);
--			write(ln, instruction_check_status);
--			writeline(results, ln);
--			write(ln, instr_d1_check);
--			writeline(results, ln);
--			write(ln, empty_line);
--			writeline(results, ln);	
--		
--		
--			write(ln, idex_reg);
--			writeline(results, ln);
--			write(ln, rs1_check_status);
--			writeline(results, ln);
--			write(ln, rs1_d1_check);
--			writeline(results, ln);
--			write(ln, rs2_check_status);
--			writeline(results, ln);
--			write(ln, rs2_d1_check);
--			writeline(results, ln);
--			write(ln, rs3_check_status);
--			writeline(results, ln);
--			write(ln, rs3_d1_check);
--			writeline(results, ln);
--			write(ln, instruction_check_status);
--			writeline(results, ln);
--			write(ln, instruction_d1_check);
--			writeline(results, ln);	
--			write(ln, empty_line);
--			writeline(results, ln);	
--		
--		
--			write(ln, exwb_reg);
--			writeline(results, ln);	
--			write(ln, rd_check_status);
--			writeline(results, ln);
--			write(ln, systemOutput);
--			writeline(results, ln);
--			write(ln, instruction_check_status);
--			writeline(results, ln);
--			write(ln, instruction_fd1_check);
--			writeline(results, ln);	
--			write(ln, empty_line);
--			writeline(results, ln);
--		
--			file_close(results);
--	
--			PC<=PC+1;
--		end if;
--	end process;	

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
			if(i=100) then
				done<='1';
			end if;
			clk <= not clk;
			wait for period/2;
		end loop;
		wait;
	end process;
end testbench;
