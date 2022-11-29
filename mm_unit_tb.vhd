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
signal instruction_array:std_logic_vector(24 downto 0);											--holds each instruction from the text file and then feeds it into the UUT
constant period : time := 20 ns;	
signal done_loading, done: std_logic:='0';														--done loading is 1 when all instructions have been loaded into the buffer. done is 1 when the clock finishes all its cycles
signal systemOutput, register_status: std_logic_vector(127 downto 0):=(others=>'0');		              --systemOutput is the ALU output after it passes through the final register. Register status shows every register's contents after the clock is done, so the final values of the registers, which are to be compared with the expected values for those registers
signal rs1_d1_check, rs2_d1_check, rs3_d1_check:std_logic_vector(127 downto 0);						--Shows the values of rs1, rs2, and rs3 after they pass through the 2nd register
signal instr_d1_check, instruction_d1_check, instruction_fd1_check: std_logic_vector(24 downto 0);	     --shows the value of the instruction that is output from each register
signal PC:integer:=0;																	    --program counter
type reg_array is array (0 to 100) of std_logic_vector(127 downto 0);
signal rs1_status_history : reg_array; 														  --stores the value of rs1 that passes through the 2nd register at every cycle of the program
signal rs2_status_history : reg_array;															 --stores the value of rs2 that passes through the 2nd register at every cycle of the program
signal rs3_status_history : reg_array;															   --stores the value of rs3 that passes through the 2nd register at every cycle of the program
signal rd_status_history : reg_array;															 --stores the output of the the ALU after the final register at every cycle of the program
type instr_array is array (0 to 100) of std_logic_vector(24 downto 0);	
signal instr_d1_status_history: instr_array;													 --stores every instruction through the 1st register at every cycle of the program
signal instruction_d1_status_history: instr_array;												 --stores every instruction through the 2nd register at every cycle of the program
signal instruction_fd1_status_history: instr_array;												  --stores every instruction through the 3rd register at every cycle of the program
begin	
	UUT : entity four_stage_pipelined_multimedia_unit port map (instruction_array => instruction_array, clk=>clk, reset=>reset, done=>done, mmOut => systemOutput, rs1_d1_check=>rs1_d1_check, rs2_d1_check=>rs2_d1_check, rs3_d1_check=>rs3_d1_check, instruction_d1_check=>instruction_d1_check, instr_d1_check=>instr_d1_check, instruction_fd1_check=>instruction_fd1_check, register_status=>register_status);
		
	reset <= '1', '0' after 2 * period;	 
	
	loading: process	 --loads all the instructions from the text file into the instruction buffer
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
	
	store: process(clk)				 --saves all the values of the outputs of the registers every cycle so they can be printed to a file later on
	begin		
		if(rising_edge(clk)) then
			rs1_status_history(PC) <= rs1_d1_check; 
			rs2_status_history(PC) <= rs2_d1_check; 
			rs3_status_history(PC) <= rs3_d1_check; 
			rd_status_history(PC) <= systemOutput; 
			instr_d1_status_history(PC) <= instr_d1_check;
			instruction_d1_status_history(PC) <= instruction_d1_check;
			instruction_fd1_status_history(PC) <= instruction_fd1_check;
			PC<=PC+1;	 
		end if;
	end process;
	
	
	print_result_history: process      --prints all the vaed values for every cycle into a file that depicts the cycle by cycle values of every register
	FILE results: TEXT;
	variable ln: line;  
	variable header:string:="Status report for cycle:";
	variable ifid_reg:string:="Status of the IF/ID register:";
	variable idex_reg:string:="Status of the ID/EX register:";
	variable exwb_reg:string:="Status of the EX/WB register:";
	variable rs1_check_status:string:="Status of rs1 is:";
	variable rs2_check_status:string:="Status of rs2 is:";
	variable rs3_check_status:string:="Status of rs3 is:"; 
	variable rd_check_status:string:="Status of rd is:";
	variable empty_line:string:=" ";
	variable instruction_check_status:string:="Status of instruction is:";
	constant result_file_name:string:="results_file.txt"; 
	variable count:integer:=0;
	begin
		wait until done = '1'; 
		file_open(results, result_file_name, write_mode);
		file_open(results, "results_file.txt", append_mode);
		for i in 0 to PC loop
			write(ln, header);
			writeline(results, ln);	
			write(ln, i);
			writeline(results, ln);
			write(ln, empty_line);
			writeline(results, ln);	
		
		
			write(ln, ifid_reg);
			writeline(results, ln);
			write(ln, instruction_check_status);
			writeline(results, ln);
			write(ln, instr_d1_status_history(i));
			writeline(results, ln);
			write(ln, empty_line);
			writeline(results, ln);	
		
		
			write(ln, idex_reg);
			writeline(results, ln);
			write(ln, rs1_check_status);
			writeline(results, ln);
			write(ln, rs1_status_history(i));
			writeline(results, ln);
			write(ln, rs2_check_status);
			writeline(results, ln);
			write(ln, rs2_status_history(i));
			writeline(results, ln);
			write(ln, rs3_check_status);
			writeline(results, ln);
			write(ln, rs3_status_history(i));
			writeline(results, ln);
			write(ln, instruction_check_status);
			writeline(results, ln);
			write(ln, instruction_d1_status_history(i));
			writeline(results, ln);	
			write(ln, empty_line);
			writeline(results, ln);	
		
		
			write(ln, exwb_reg);
			writeline(results, ln);	
			write(ln, rd_check_status);
			writeline(results, ln);
			write(ln, rd_status_history(i));
			writeline(results, ln);
			write(ln, instruction_check_status);
			writeline(results, ln);
			write(ln, instruction_fd1_status_history(i));
			writeline(results, ln);	
			write(ln, empty_line);
			writeline(results, ln);	
		end loop;	 
		file_close(results); 
		wait;
	end process;

	clock: process						--clock
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
