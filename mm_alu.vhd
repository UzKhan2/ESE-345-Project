library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mm_alu is
	port( 
	rs1 : in std_logic_vector(127 downto 0);
	rs2: in std_logic_vector(127 downto 0); 
	rs3: in std_logic_vector(127 downto 0);	
	rd_in: in std_logic_vector(127 downto 0);
	sel: in std_logic_vector(24 downto 0);
	rd_out: out std_logic_vector(127 downto 0)
    );
end mm_alu;

architecture behavioral of mm_alu is 		    
signal rd:std_logic_vector(127 downto 0):=(others=>'0');
begin	
	alu: process (rs2, rs3, rs1, rd_in, sel) 	
	variable mult_out : std_logic_vector(127 downto 0); --holds the output of the multiplication  
	variable clz0, clz1, clz2, clz3 : std_logic_vector(31 downto 0) := (others => '0');	--counts leading 0's in each 32 bit section of rs1
	variable ones0, ones1, ones2, ones3 : std_logic_vector(31 downto 0) := (others => '0'); --counts number of 1's in each 32 bit section of rs1
	variable rot : integer; --holds the number of rotations needed based on the 32 bit sections of rs2
	variable rs1ror : std_logic_vector(127 downto 0) := (others => '0'); --holds rs1 and rotates it	 
	begin	
		if sel(24) = '0' then  --load immediate to the sel(20 downto 5)'th section of rd's 16 bit sections
			if sel(23 downto 21) = "000" then
				rd(15 downto 0) <= sel(20 downto 5);
			elsif sel(23 downto 21) = "001" then
				rd(31 downto 16) <= sel(20 downto 5);
			elsif sel(23 downto 21) = "010" then
				rd(47 downto 32) <= sel(20 downto 5);
			elsif sel(23 downto 21) = "011" then
				rd(63 downto 48) <= sel(20 downto 5);
			elsif sel(23 downto 21) = "100" then
				rd(79 downto 64) <= sel(20 downto 5);
			elsif sel(23 downto 21) = "101" then
				rd(95 downto 80) <= sel(20 downto 5);
			elsif sel(23 downto 21) = "110" then
				rd(111 downto 96) <= sel(20 downto 5);
			elsif sel(23 downto 21) = "111" then
				rd(127 downto 112) <= sel(20 downto 5);
			end if;
		elsif sel(24 downto 23) = "10" then
			if (sel(22 downto 20) = "000" or sel(22 downto 20) = "010") then --multiplies the low 16 bits of rs3 and rs2
				mult_out(31 downto 0) := std_logic_vector(resize(signed(rs3(15 downto 0)) * signed(rs2(15 downto 0)), 32));
				mult_out(63 downto 32) := std_logic_vector(resize(signed(rs3(47 downto 32)) * signed(rs2(47 downto 32)), 32));
				mult_out(95 downto 64) := std_logic_vector(resize(signed(rs3(79 downto 64)) * signed(rs2(79 downto 64)), 32));
				mult_out(127 downto 96) := std_logic_vector(resize(signed(rs3(111 downto 96)) * signed(rs2(111 downto 96)), 32));
				if sel(22 downto 20) = "000" then --adds 32 bit product to 32 bit rs1  
					if (rs1(31) = '0' and mult_out(31) = '0' and signed(rs1(31 downto 0)) + signed(mult_out(31 downto 0)) < 0) then
						rd(31 downto 0)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(31) = '1' and mult_out(31) = '1' and signed(rs1(31 downto 0)) + signed(mult_out(31 downto 0)) > 0) then
						rd(31 downto 0)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(31 downto 0) <= std_logic_vector(resize(signed(rs1(31 downto 0)) + signed(mult_out(31 downto 0)), 32)); 
					end if;
					
					if (rs1(63) = '0' and mult_out(63) = '0' and signed(rs1(63 downto 32)) + signed(mult_out(63 downto 32)) < 0) then
						rd(63 downto 32)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(63) = '1' and mult_out(63) = '1' and signed(rs1(63 downto 32)) + signed(mult_out(63 downto 32)) > 0) then
						rd(63 downto 32)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(63 downto 32) <= std_logic_vector(resize(signed(rs1(63 downto 32)) + signed(mult_out(63 downto 32)), 32)); 
					end if;
					
					if (rs1(95) = '0' and mult_out(95) = '0' and signed(rs1(95 downto 64)) + signed(mult_out(95 downto 64)) < 0) then
						rd(95 downto 64)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(95) = '1' and mult_out(95) = '1' and signed(rs1(95 downto 64)) + signed(mult_out(95 downto 64)) > 0) then
						rd(95 downto 64)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(95 downto 64) <= std_logic_vector(resize(signed(rs1(95 downto 64)) + signed(mult_out(95 downto 64)), 32)); 
					end if;
					
					if (rs1(127) = '0' and mult_out(127) = '0' and signed(rs1(127 downto 96)) + signed(mult_out(127 downto 96)) < 0) then
						rd(127 downto 96)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(127) = '1' and mult_out(127) = '1' and signed(rs1(127 downto 96)) + signed(mult_out(127 downto 96)) > 0) then
						rd(127 downto 96)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(127 downto 96) <= std_logic_vector(resize(signed(rs1(127 downto 96)) + signed(mult_out(127 downto 96)), 32)); 
					end if;
				elsif sel(22 downto 20) = "010" then --subtracts 32 bit product from 32 bit rs1	 
					if (rs1(31) = '0' and mult_out(31) = '1' and signed(rs1(31 downto 0)) - signed(mult_out(31 downto 0)) < 0) then
						rd(31 downto 0)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(31) = '1' and mult_out(31) = '0' and signed(rs1(31 downto 0)) - signed(mult_out(31 downto 0)) > 0) then
						rd(31 downto 0)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(31 downto 0) <= std_logic_vector(resize(signed(rs1(31 downto 0)) - signed(mult_out(31 downto 0)), 32)); 
					end if;
					
					if (rs1(63) = '0' and mult_out(63) = '1' and signed(rs1(63 downto 32)) - signed(mult_out(63 downto 32)) < 0) then
						rd(63 downto 32)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(63) = '1' and mult_out(63) = '0' and signed(rs1(63 downto 32)) - signed(mult_out(63 downto 32)) > 0) then
						rd(63 downto 32)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(63 downto 32) <= std_logic_vector(resize(signed(rs1(63 downto 32)) - signed(mult_out(63 downto 32)), 32)); 
					end if;
					
					if (rs1(95) = '0' and mult_out(95) = '1' and signed(rs1(95 downto 64)) - signed(mult_out(95 downto 64)) < 0) then
						rd(95 downto 64)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(95) = '1' and mult_out(95) = '0' and signed(rs1(95 downto 64)) - signed(mult_out(95 downto 64)) > 0) then
						rd(95 downto 64)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(95 downto 64) <= std_logic_vector(resize(signed(rs1(95 downto 64)) - signed(mult_out(95 downto 64)), 32)); 
					end if;
					
					if (rs1(127) = '0' and mult_out(127) = '1' and signed(rs1(127 downto 96)) - signed(mult_out(127 downto 96)) < 0) then
						rd(127 downto 96)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(127) = '1' and mult_out(127) = '0' and signed(rs1(127 downto 96)) - signed(mult_out(127 downto 96)) > 0) then
						rd(127 downto 96)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(127 downto 96) <= std_logic_vector(resize(signed(rs1(127 downto 96)) - signed(mult_out(127 downto 96)), 32)); 
					end if;
				end if;
			elsif (sel(22 downto 20) = "001" or sel(22 downto 20) = "011") then --multiplies the high 16 bits of rs3 and rs2
				mult_out(31 downto 0) := std_logic_vector(resize(signed(rs3(31 downto 16)) * signed(rs2(31 downto 16)), 32)); 
				mult_out(63 downto 32) := std_logic_vector(resize(signed(rs3(63 downto 48)) * signed(rs2(63 downto 48)), 32));
				mult_out(95 downto 64) := std_logic_vector(resize(signed(rs3(95 downto 80)) * signed(rs2(95 downto 80)), 32));
				mult_out(127 downto 96) := std_logic_vector(resize(signed(rs3(127 downto 112)) * signed(rs2(127 downto 112)), 32));	  
				if sel(22 downto 20) = "001" then --adds 32 bit product to 32 bit rs1  
					if (rs1(31) = '0' and mult_out(31) = '0' and signed(rs1(31 downto 0)) + signed(mult_out(31 downto 0)) < 0) then
						rd(31 downto 0)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(31) = '1' and mult_out(31) = '1' and signed(rs1(31 downto 0)) + signed(mult_out(31 downto 0)) > 0) then
						rd(31 downto 0)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(31 downto 0) <= std_logic_vector(resize(signed(rs1(31 downto 0)) + signed(mult_out(31 downto 0)), 32)); 
					end if;
					
					if (rs1(63) = '0' and mult_out(63) = '0' and signed(rs1(63 downto 32)) + signed(mult_out(63 downto 32)) < 0) then
						rd(63 downto 32)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(63) = '1' and mult_out(63) = '1' and signed(rs1(63 downto 32)) + signed(mult_out(63 downto 32)) > 0) then
						rd(63 downto 32)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(63 downto 32) <= std_logic_vector(resize(signed(rs1(63 downto 32)) + signed(mult_out(63 downto 32)), 32)); 
					end if;
					
					if (rs1(95) = '0' and mult_out(95) = '0' and signed(rs1(95 downto 64)) + signed(mult_out(95 downto 64)) < 0) then
						rd(95 downto 64)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(95) = '1' and mult_out(95) = '1' and signed(rs1(95 downto 64)) + signed(mult_out(95 downto 64)) > 0) then
						rd(95 downto 64)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(95 downto 64) <= std_logic_vector(resize(signed(rs1(95 downto 64)) + signed(mult_out(95 downto 64)), 32)); 
					end if;
					
					if (rs1(127) = '0' and mult_out(127) = '0' and signed(rs1(127 downto 96)) + signed(mult_out(127 downto 96)) < 0) then
						rd(127 downto 96)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(127) = '1' and mult_out(127) = '1' and signed(rs1(127 downto 96)) + signed(mult_out(127 downto 96)) > 0) then
						rd(127 downto 96)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(127 downto 96) <= std_logic_vector(resize(signed(rs1(127 downto 96)) + signed(mult_out(127 downto 96)), 32)); 
					end if;
				elsif sel(22 downto 20) = "011" then --subtracts 32 bit product from 32 bit rs1
					if (rs1(31) = '0' and mult_out(31) = '1' and signed(rs1(31 downto 0)) - signed(mult_out(31 downto 0)) < 0) then
						rd(31 downto 0)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(31) = '1' and mult_out(31) = '0' and signed(rs1(31 downto 0)) - signed(mult_out(31 downto 0)) > 0) then
						rd(31 downto 0)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(31 downto 0) <= std_logic_vector(resize(signed(rs1(31 downto 0)) - signed(mult_out(31 downto 0)), 32)); 
					end if;
					
					if (rs1(63) = '0' and mult_out(63) = '1' and signed(rs1(63 downto 32)) - signed(mult_out(63 downto 32)) < 0) then
						rd(63 downto 32)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(63) = '1' and mult_out(63) = '0' and signed(rs1(63 downto 32)) - signed(mult_out(63 downto 32)) > 0) then
						rd(63 downto 32)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(63 downto 32) <= std_logic_vector(resize(signed(rs1(63 downto 32)) - signed(mult_out(63 downto 32)), 32)); 
					end if;
					
					if (rs1(95) = '0' and mult_out(95) = '1' and signed(rs1(95 downto 64)) - signed(mult_out(95 downto 64)) < 0) then
						rd(95 downto 64)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(95) = '1' and mult_out(95) = '0' and signed(rs1(95 downto 64)) - signed(mult_out(95 downto 64)) > 0) then
						rd(95 downto 64)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(95 downto 64) <= std_logic_vector(resize(signed(rs1(95 downto 64)) - signed(mult_out(95 downto 64)), 32)); 
					end if;
					
					if (rs1(127) = '0' and mult_out(127) = '1' and signed(rs1(127 downto 96)) - signed(mult_out(127 downto 96)) < 0) then
						rd(127 downto 96)<=std_logic_vector(to_signed(2147483647,32)); 
					elsif (rs1(127) = '1' and mult_out(127) = '0' and signed(rs1(127 downto 96)) - signed(mult_out(127 downto 96)) > 0) then
						rd(127 downto 96)<=std_logic_vector(to_signed(-2147483648,32));
					else 
						rd(127 downto 96) <= std_logic_vector(resize(signed(rs1(127 downto 96)) - signed(mult_out(127 downto 96)), 32)); 
					end if;
				  end if;
			elsif (sel(22 downto 20) = "100" or sel(22 downto 20) = "110") then --multiplies the low 32 bits of rs3 and rs2
				mult_out(63 downto 0) := std_logic_vector(resize(signed(rs3(31 downto 0)) * signed(rs2(31 downto 0)), 64));
				mult_out(127 downto 64) := std_logic_vector(resize(signed(rs3(95 downto 64)) * signed(rs2(95 downto 64)), 64));
				if sel(22 downto 20) = "100" then --add 64 bit product to 64 bit rs1 				
					if (rs1(63) = '0' and mult_out(63) = '0' and signed(rs1(63 downto 0)) + signed(mult_out(63 downto 0)) < 0) then
						rd(63)<='0';
						rd(62 downto 0)<=(others=>'1'); 
					elsif (rs1(63) = '1' and mult_out(63) = '1' and signed(rs1(63 downto 0)) + signed(mult_out(63 downto 0)) > 0) then
						rd(63)<='1';
						rd(62 downto 0)<=(others=>'0');
					else 
						rd(63 downto 0) <= std_logic_vector(resize(signed(rs1(63 downto 0)) + signed(mult_out(63 downto 0)), 64)); 
					end if;
					
					if (rs1(127) = '0' and mult_out(127) = '0' and signed(rs1(127 downto 64)) + signed(mult_out(127 downto 64)) < 0) then
						rd(127)<='0';
						rd(126 downto 64)<=(others=>'1'); 
					elsif (rs1(127) = '1' and mult_out(127) = '1' and signed(rs1(127 downto 64)) + signed(mult_out(127 downto 64)) > 0) then
						rd(127)<='1';
						rd(126 downto 64)<=(others=>'0');
					else 
						rd(127 downto 64) <= std_logic_vector(resize(signed(rs1(127 downto 64)) + signed(mult_out(127 downto 64)), 64)); 
					end if;
				elsif sel(22 downto 20) = "110" then --subtracts 64 bit product from 64 bit rs1
					if (rs1(63) = '0' and mult_out(63) = '1' and signed(rs1(63 downto 0)) - signed(mult_out(63 downto 0)) < 0) then
						rd(63)<='0';
						rd(62 downto 0)<=(others=>'1'); 
					elsif (rs1(63) = '1' and mult_out(63) = '0' and signed(rs1(63 downto 0)) - signed(mult_out(63 downto 0)) > 0) then
						rd(63)<='1';
						rd(62 downto 0)<=(others=>'0');
					else 
						rd(63 downto 0) <= std_logic_vector(resize(signed(rs1(63 downto 0)) - signed(mult_out(63 downto 0)), 64)); 
					end if;
					
					if (rs1(127) = '0' and mult_out(127) = '1' and signed(rs1(127 downto 64)) - signed(mult_out(127 downto 64)) < 0) then
						rd(127)<='0';
						rd(126 downto 64)<=(others=>'1'); 
					elsif (rs1(127) = '1' and mult_out(127) = '0' and signed(rs1(127 downto 64)) - signed(mult_out(127 downto 64)) > 0) then
						rd(127)<='1';
						rd(126 downto 64)<=(others=>'0');
					else 
						rd(127 downto 64) <= std_logic_vector(resize(signed(rs1(127 downto 64)) - signed(mult_out(127 downto 64)), 64)); 
					end if;
				end if;
			elsif (sel(22 downto 20) = "101" or sel(22 downto 20) = "111") then --multiplies the high 32 bits of rs3 and rs2
				mult_out(63 downto 0) := std_logic_vector(resize(signed(rs3(63 downto 32)) * signed(rs2(63 downto 32)), 64));
				mult_out(127 downto 64) := std_logic_vector(resize(signed(rs3(127 downto 96)) * signed(rs2(127 downto 96)), 64));
				if sel(22 downto 20) = "101" then --adds 64 bit product to 64 bit rs1 
					if (rs1(63) = '0' and mult_out(63) = '0' and signed(rs1(63 downto 0)) + signed(mult_out(63 downto 0)) < 0) then
						rd(63)<='0';
						rd(62 downto 0)<=(others=>'1'); 
					elsif (rs1(63) = '1' and mult_out(63) = '1' and signed(rs1(63 downto 0)) + signed(mult_out(63 downto 0)) > 0) then
						rd(63)<='1';
						rd(62 downto 0)<=(others=>'0');
					else 
						rd(63 downto 0) <= std_logic_vector(resize(signed(rs1(63 downto 0)) + signed(mult_out(63 downto 0)), 64)); 
					end if;
					
					if (rs1(127) = '0' and mult_out(127) = '0' and signed(rs1(127 downto 64)) + signed(mult_out(127 downto 64)) < 0) then
						rd(127)<='0';
						rd(126 downto 64)<=(others=>'1'); 
					elsif (rs1(127) = '1' and mult_out(127) = '1' and signed(rs1(127 downto 64)) + signed(mult_out(127 downto 64)) > 0) then
						rd(127)<='1';
						rd(126 downto 64)<=(others=>'0');
					else 
						rd(127 downto 64) <= std_logic_vector(resize(signed(rs1(127 downto 64)) + signed(mult_out(127 downto 64)), 64)); 
					end if;																						  
				elsif sel(22 downto 20) = "111" then --subtracts 64 bit product from 64 bit rs1
					if (rs1(63) = '0' and mult_out(63) = '1' and signed(rs1(63 downto 0)) - signed(mult_out(63 downto 0)) < 0) then
						rd(63)<='0';
						rd(62 downto 0)<=(others=>'1'); 
					elsif (rs1(63) = '1' and mult_out(63) = '0' and signed(rs1(63 downto 0)) - signed(mult_out(63 downto 0)) > 0) then
						rd(63)<='1';
						rd(62 downto 0)<=(others=>'0');
					else 
						rd(63 downto 0) <= std_logic_vector(resize(signed(rs1(63 downto 0)) - signed(mult_out(63 downto 0)), 64)); 
					end if;
					
					if (rs1(127) = '0' and mult_out(127) = '1' and signed(rs1(127 downto 64)) - signed(mult_out(127 downto 64)) < 0) then
						rd(127)<='0';
						rd(126 downto 64)<=(others=>'1'); 
					elsif (rs1(127) = '1' and mult_out(127) = '0' and signed(rs1(127 downto 64)) - signed(mult_out(127 downto 64)) > 0) then
						rd(127)<='1';
						rd(126 downto 64)<=(others=>'0');
					else 
						rd(127 downto 64) <= std_logic_vector(resize(signed(rs1(127 downto 64)) - signed(mult_out(127 downto 64)), 64)); 
					end if;																						   
				end if;
			end if;		
		elsif sel(24 downto 23) = "11" then
			if sel(18 downto 15) = "0000" then
			   --nop 
			elsif sel(18 downto 15) = "0001" then  --store counts of leading 0's from each 32 bit section of rs1 into each corresponding 32 bit section of rd
				section0: for i in 31 downto 0 loop
					if rs1(i) /= '0' then
						exit;
					else
						clz0:=std_logic_vector(unsigned(clz0) + 1);
					end if;		
				end loop section0;		
				section1: for i in 63 downto 32 loop
					if rs1(i) /= '0' then
						exit;
					else
						clz1:=std_logic_vector(unsigned(clz1) + 1);
					end if;		
				end loop section1; 
				section2: for i in 95 downto 64 loop
					if rs1(i) /= '0' then
						exit;
					else
						clz2:=std_logic_vector(unsigned(clz2) + 1);
					end if;		
				end loop section2;
				section3: for i in 127 downto 96 loop
					if rs1(i) /= '0' then
						exit;
					else
						clz3:=std_logic_vector(unsigned(clz3) + 1);
					end if;		
				end loop section3; 
				rd(31 downto 0)<=clz0;
				rd(63 downto 32)<=clz1;
				rd(95 downto 64)<=clz2;
				rd(127 downto 96)<=clz3;
			elsif sel(18 downto 15) = "0010" then --unsigned addition of rs1 and rs2 unsigned 32 bit sections
				rd(31 downto 0) <= std_logic_vector(unsigned(rs1(31 downto 0)) + unsigned(rs2(31 downto 0)));  
				rd(63 downto 32) <= std_logic_vector(unsigned(rs1(63 downto 32)) + unsigned(rs2(63 downto 32)));
				rd(95 downto 64) <= std_logic_vector(unsigned(rs1(95 downto 64)) + unsigned(rs2(95 downto 64)));
				rd(127 downto 96) <= std_logic_vector(unsigned(rs1(127 downto 96)) + unsigned(rs2(127 downto 96)));
			elsif sel(18 downto 15) = "0011" then --unsigned addition of rs1 and rs2 16 bits of 16 bit sections
				rd(15 downto 0) <= std_logic_vector(unsigned(rs2(15 downto 0)) + unsigned(rs1(15 downto 0)));
				rd(31 downto 16) <= std_logic_vector(unsigned(rs2(31 downto 16)) + unsigned(rs1(31 downto 16))); 
				rd(47 downto 32) <= std_logic_vector(unsigned(rs2(47 downto 32)) + unsigned(rs1(47 downto 32)));
				rd(63 downto 48) <= std_logic_vector(unsigned(rs2(63 downto 48)) + unsigned(rs1(63 downto 48)));
				rd(79 downto 64) <= std_logic_vector(unsigned(rs2(79 downto 64)) + unsigned(rs1(79 downto 64)));
				rd(95 downto 80) <= std_logic_vector(unsigned(rs2(95 downto 80)) + unsigned(rs1(95 downto 80)));
				rd(111 downto 96) <= std_logic_vector(unsigned(rs2(111 downto 96)) + unsigned(rs1(111 downto 96)));
				rd(127 downto 112) <= std_logic_vector(unsigned(rs2(127 downto 112)) + unsigned(rs1(127 downto 112)));   
			elsif sel(18 downto 15) = "0100" then --signed addition of rs1 and rs2 lower 16 bits of 16 bit sections with saturation
				if (rs1(15) = '0' and rs2(15) = '0' and signed(rs2(15 downto 0)) + signed(rs1(15 downto 0)) < 0) then
					rd(15 downto 0)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs1(15) = '1' and rs2(15) = '1' and signed(rs2(15 downto 0)) + signed(rs1(15 downto 0)) > 0) then
					rd(15 downto 0)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(15 downto 0) <= std_logic_vector(resize(signed(rs2(15 downto 0)) + signed(rs1(15 downto 0)), 16)); 
				end if;
				
				if (rs1(31) = '0' and rs2(31) = '0' and signed(rs2(31 downto 16)) + signed(rs1(31 downto 16)) < 0) then
					rd(31 downto 16)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs1(31) = '1' and rs2(31) = '1' and signed(rs2(31 downto 16)) + signed(rs1(31 downto 16)) > 0) then
					rd(31 downto 16)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(31 downto 16) <= std_logic_vector(resize(signed(rs2(31 downto 16)) + signed(rs1(31 downto 16)), 16)); 
				end if;
				
				if (rs1(47) = '0' and rs2(47) = '0' and signed(rs2(47 downto 32)) + signed(rs1(47 downto 32)) < 0) then
					rd(47 downto 32)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs1(47) = '1' and rs2(47) = '1' and signed(rs2(47 downto 32)) + signed(rs1(47 downto 32)) > 0) then
					rd(47 downto 32)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(47 downto 32) <= std_logic_vector(resize(signed(rs2(47 downto 32)) + signed(rs1(47 downto 32)), 16)); 
				end if;
				
				if (rs1(63) = '0' and rs2(63) = '0' and signed(rs2(63 downto 48)) + signed(rs1(63 downto 48)) < 0) then
					rd(63 downto 48)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs1(63) = '1' and rs2(63) = '1' and signed(rs2(63 downto 48)) + signed(rs1(63 downto 48)) > 0) then
					rd(63 downto 48)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(63 downto 48) <= std_logic_vector(resize(signed(rs2(63 downto 48)) + signed(rs1(63 downto 48)), 16)); 
				end if;	
				
				if (rs1(79) = '0' and rs2(79) = '0' and signed(rs2(79 downto 64)) + signed(rs1(79 downto 64)) < 0) then
					rd(79 downto 64)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs1(79) = '1' and rs2(79) = '1' and signed(rs2(79 downto 64)) + signed(rs1(79 downto 64)) > 0) then
					rd(79 downto 64)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(79 downto 64) <= std_logic_vector(resize(signed(rs2(79 downto 64)) + signed(rs1(79 downto 64)), 16)); 
				end if;	 
				
				if (rs1(95) = '0' and rs2(95) = '0' and signed(rs2(95 downto 80)) + signed(rs1(95 downto 80)) < 0) then
					rd(95 downto 80)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs1(95) = '1' and rs2(95) = '1' and signed(rs2(95 downto 80)) + signed(rs1(95 downto 80)) > 0) then
					rd(95 downto 80)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(95 downto 80) <= std_logic_vector(resize(signed(rs2(95 downto 80)) + signed(rs1(95 downto 80)), 16)); 
				end if;
				
				if (rs1(111) = '0' and rs2(111) = '0' and signed(rs2(111 downto 96)) + signed(rs1(111 downto 96)) < 0) then
					rd(111 downto 96)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs1(111) = '1' and rs2(111) = '1' and signed(rs2(111 downto 96)) + signed(rs1(111 downto 96)) > 0) then
					rd(111 downto 96)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(111 downto 96) <= std_logic_vector(resize(signed(rs2(111 downto 96)) + signed(rs1(111 downto 96)), 16)); 
				end if;
				
				if (rs1(127) = '0' and rs2(127) = '0' and signed(rs2(127 downto 112)) + signed(rs1(127 downto 112)) < 0) then
					rd(127 downto 112)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs1(127) = '1' and rs2(127) = '1' and signed(rs2(127 downto 112)) + signed(rs1(127 downto 112)) > 0) then
					rd(127 downto 112)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(127 downto 112) <= std_logic_vector(resize(signed(rs2(127 downto 112)) + signed(rs1(127 downto 112)), 16)); 
				end if;
			elsif sel(18 downto 15) = "0101" then --bitwise logical and of rs1 and rs2
				rd<=rs1 and rs2;
			elsif sel(18 downto 15) = "0110" then --place rightmost 32 bit word of rs1 into every 32 bit section of rd
				rd(31 downto 0) <= rs1(31 downto 0);  
				rd(63 downto 32) <= rs1(31 downto 0);
				rd(95 downto 64) <= rs1(31 downto 0);
				rd(127 downto 96) <= rs1(31 downto 0);				
			elsif sel(18 downto 15) = "0111" then --place larger signed value between rs1 and rs2 32 bit sections in corresponding 32 bit section of rd
				rd(31 downto 0) <= std_logic_vector(maximum(signed(rs1(31 downto 0)), signed(rs2(31 downto 0))));  
				rd(63 downto 32) <= std_logic_vector(maximum(signed(rs1(63 downto 32)), signed(rs2(63 downto 32))));
				rd(95 downto 64) <= std_logic_vector(maximum(signed(rs1(95 downto 64)), signed(rs2(95 downto 64))));
				rd(127 downto 96) <= std_logic_vector(maximum(signed(rs1(127 downto 96)), signed(rs2(127 downto 96))));
			elsif sel(19 downto 15) = "01000" then --place smaller signed value between rs1 and rs2 32 bit sections in corresponding 32 bit section of rd
				rd(31 downto 0) <= std_logic_vector(minimum(signed(rs1(31 downto 0)), signed(rs2(31 downto 0))));  
				rd(63 downto 32) <= std_logic_vector(minimum(signed(rs1(63 downto 32)), signed(rs2(63 downto 32))));
				rd(95 downto 64) <= std_logic_vector(minimum(signed(rs1(95 downto 64)), signed(rs2(95 downto 64))));
				rd(127 downto 96) <= std_logic_vector(minimum(signed(rs1(127 downto 96)), signed(rs2(127 downto 96))));
			elsif sel(18 downto 15) = "1001" then --multiply low 16 unsigned bits of each 32 bit section of rs1 and rs2 and store in corresponding 32 bit section of rd
				rd(31 downto 0) <= std_logic_vector(unsigned(rs1(15 downto 0)) * unsigned(rs2(15 downto 0)));
				rd(63 downto 32) <= std_logic_vector(unsigned(rs1(47 downto 32)) * unsigned(rs2(47 downto 32)));
				rd(95 downto 64) <= std_logic_vector(unsigned(rs1(79 downto 64)) * unsigned(rs2(79 downto 64)));
				rd(127 downto 96) <= std_logic_vector(unsigned(rs1(111 downto 96)) * unsigned(rs2(111 downto 96)));
			elsif sel(18 downto 15) = "1010" then --multiply lower unsigned 16 bits of rs1's 32 bit sections with unsigned 5 bit rs2 section from sel and store in corresponding 32 bit sections of rd  
				rd(31 downto 0) <= std_logic_vector(resize(unsigned(rs1(15 downto 0)) * unsigned(sel(14 downto 10)),32));
				rd(63 downto 32) <= std_logic_vector(resize(unsigned(rs1(47 downto 32)) * unsigned(sel(14 downto 10)),32));
				rd(95 downto 64) <= std_logic_vector(resize(unsigned(rs1(79 downto 64)) * unsigned(sel(14 downto 10)),32));
				rd(127 downto 96) <= std_logic_vector(resize(unsigned(rs1(111 downto 96)) * unsigned(sel(14 downto 10)),32));
			elsif sel(18 downto 15) = "1011" then -- bitwise logical or of rs1 and rs2
				rd <= rs1 or rs2;
			elsif sel(18 downto 15) = "1100" then -- counts 1's in each 32 bit section of rs1 and stores it in corresponding 32 bit sections of rd
				sec0: for i in 31 downto 0 loop
					if rs1(i) = '1' then
						ones0:=std_logic_vector(unsigned(ones0) + 1);
					end if;		
				end loop sec0;		
				sec1: for i in 63 downto 32 loop
					if rs1(i) = '1' then
						ones1:=std_logic_vector(unsigned(ones1) + 1);
					end if;		
				end loop sec1; 
				sec2: for i in 95 downto 64 loop
					if rs1(i) ='1' then
						ones2:=std_logic_vector(unsigned(ones2) + 1);
					end if;		
				end loop sec2;
				sec3: for i in 127 downto 96 loop
					if rs1(i) ='1' then
						ones3:=std_logic_vector(unsigned(ones3) + 1);
					end if;		
				end loop sec3; 
				rd(31 downto 0)<=ones0;
				rd(63 downto 32)<=ones1;
				rd(95 downto 64)<=ones2;
				rd(127 downto 96)<=ones3;
			elsif sel(18 downto 15) = "1101" then 
				rs1ror := rs1;	 --save a copy of rs1
				for i in 0 to 3 loop
					rot := to_integer(unsigned(rs2(((32*i)+4) downto (32*i)))); --gets the # of rotations for each section
					if rot=0 then --if 0 just save it directly to rd
						next;
					else --if not then rotate
						for j in 0 to rot-1 loop  
							rs1ror((32*(i+1))-1 downto 32*i):= rs1ror(32*i) & rs1ror((32*(i+1))-1 downto (32*i)+1);	
						end loop;
					end if;	
				end loop;
				rd(31 downto 0) <= rs1ror(31 downto 0);
				rd(63 downto 32)<= rs1ror(63 downto 32);
				rd(95 downto 64)<= rs1ror(95 downto 64);
				rd(127 downto 96)<= rs1ror(127 downto 96);
			elsif sel(18 downto 15) = "1110" then --subtract rs1 unsigned 32 bit sections from rs2 unsigned 32 bit sections and store them in the corresponding 32 bit sections of rd
				rd(31 downto 0) <= std_logic_vector(unsigned(rs2(31 downto 0)) - unsigned(rs1(31 downto 0)));  
				rd(63 downto 32) <= std_logic_vector(unsigned(rs2(63 downto 32)) - unsigned(rs1(63 downto 32)));
				rd(95 downto 64) <= std_logic_vector(unsigned(rs2(95 downto 64)) - unsigned(rs1(95 downto 64)));
				rd(127 downto 96) <= std_logic_vector(unsigned(rs2(127 downto 96)) - unsigned(rs1(127 downto 96)));		
			elsif sel(18 downto 15) = "1111" then --add signed rs1 and rs2 16 bit sections with saturation and store in the corresponding 16 bit sections of rd	 
				if (rs2(15) = '0' and rs1(15) = '1' and signed(rs2(15 downto 0)) - signed(rs1(15 downto 0)) < 0) then
					rd(15 downto 0)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs2(15) = '1' and rs1(15) = '0' and signed(rs2(15 downto 0)) - signed(rs1(15 downto 0)) > 0) then
					rd(15 downto 0)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(15 downto 0) <= std_logic_vector(resize(signed(rs2(15 downto 0)) - signed(rs1(15 downto 0)), 16)); 
				end if;
				
				if (rs2(31) = '0' and rs1(31) = '1' and signed(rs2(31 downto 16)) - signed(rs1(31 downto 16)) < 0) then
					rd(31 downto 16)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs2(31) = '1' and rs1(31) = '0' and signed(rs2(31 downto 16)) - signed(rs1(31 downto 16)) > 0) then
					rd(31 downto 16)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(31 downto 16) <= std_logic_vector(resize(signed(rs2(31 downto 16)) - signed(rs1(31 downto 16)), 16)); 
				end if;
				
				if (rs2(47) = '0' and rs1(47) = '1' and signed(rs2(47 downto 32)) - signed(rs1(47 downto 32)) < 0) then
					rd(47 downto 32)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs2(47) = '1' and rs1(47) = '0' and signed(rs2(47 downto 32)) - signed(rs1(47 downto 32)) > 0) then
					rd(47 downto 32)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(47 downto 32) <= std_logic_vector(resize(signed(rs2(47 downto 32)) - signed(rs1(47 downto 32)), 16)); 
				end if;
				
				if (rs2(63) = '0' and rs1(63) = '1' and signed(rs2(63 downto 48)) - signed(rs1(63 downto 48)) < 0) then
					rd(63 downto 48)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs2(63) = '1' and rs1(63) = '0' and signed(rs2(63 downto 48)) - signed(rs1(63 downto 48)) > 0) then
					rd(63 downto 48)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(63 downto 48) <= std_logic_vector(resize(signed(rs2(63 downto 48)) - signed(rs1(63 downto 48)), 16)); 
				end if;	
				
				if (rs2(79) = '0' and rs1(79) = '1' and signed(rs2(79 downto 64)) - signed(rs1(79 downto 64)) < 0) then
					rd(79 downto 64)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs2(79) = '1' and rs1(79) = '0' and signed(rs2(79 downto 64)) - signed(rs1(79 downto 64)) > 0) then
					rd(79 downto 64)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(79 downto 64) <= std_logic_vector(resize(signed(rs2(79 downto 64)) - signed(rs1(79 downto 64)), 16)); 
				end if;	 
				
				if (rs2(95) = '0' and rs1(95) = '1' and signed(rs2(95 downto 80)) - signed(rs1(95 downto 80)) < 0) then
					rd(95 downto 80)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs2(95) = '1' and rs1(95) = '0' and signed(rs2(95 downto 80)) - signed(rs1(95 downto 80)) > 0) then
					rd(95 downto 80)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(95 downto 80) <= std_logic_vector(resize(signed(rs2(95 downto 80)) - signed(rs1(95 downto 80)), 16)); 
				end if;
				
				if (rs2(111) = '0' and rs1(111) = '1' and signed(rs2(111 downto 96)) - signed(rs1(111 downto 96)) < 0) then
					rd(111 downto 96)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs2(111) = '1' and rs1(111) = '0' and signed(rs2(111 downto 96)) - signed(rs1(111 downto 96)) > 0) then
					rd(111 downto 96)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(111 downto 96) <= std_logic_vector(resize(signed(rs2(111 downto 96)) - signed(rs1(111 downto 96)), 16)); 
				end if;
				
				if (rs2(127) = '0' and rs1(127) = '1' and signed(rs2(127 downto 112)) - signed(rs1(127 downto 112)) < 0) then
					rd(127 downto 112)<=std_logic_vector(to_signed(32767,16)); 
				elsif (rs2(127) = '1' and rs1(127) = '0' and signed(rs2(127 downto 112)) - signed(rs1(127 downto 112)) > 0) then
					rd(127 downto 112)<=std_logic_vector(to_signed(-32768,16));
				else 
					rd(127 downto 112) <= std_logic_vector(resize(signed(rs2(127 downto 112)) - signed(rs1(127 downto 112)), 16)); 
				end if;		
			end if;
		end if;
		rd_out<=rd;
	end process alu;
	
end architecture behavioral;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_fetcher is
	port( 	
		instruction_array: in std_logic_vector(24 downto 0);
	     clk: in std_logic;
		instr: out std_logic_vector(24 downto 0)
    );
end instruction_fetcher;

architecture behavioral of instruction_fetcher is 
type instr_array is array (63 downto 0) of std_logic_vector(24 downto 0);
signal instructions : instr_array;
signal PC:integer:=0; --program counter	   
begin   
	load: process(instruction_array)   
	variable index:integer:=0;
	begin
		if(index<64) then
			instructions(index)<=instruction_array;	 
			index:=index+1;
		end if;
	end process;
	
	fetch: process (clk)
	begin
		if rising_edge(clk) then
			instr<=instructions(PC)(24 downto 0);
			if(PC<63) then
--			if(PC = 63) then
--				PC<=0;
--			else
				PC<=PC+1;
			end if;
		end if;
	end process;	
end architecture behavioral;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
	port( 			   
	done : in std_logic;
	instr : in std_logic_vector(24 downto 0);
	register_write : in std_logic_vector(127 downto 0);
	oldInstr : in std_logic_vector(24 downto 0);
	rs1: out std_logic_vector(127 downto 0); 
	rs2: out std_logic_vector(127 downto 0); 
	rs3: out std_logic_vector(127 downto 0);
	rd: out std_logic_vector(127 downto 0);
	sel: out std_logic_vector(24 downto 0);
	register_status: out std_logic_vector(127 downto 0)
    );
end decoder;

architecture behavioral of decoder is 
type register_array is array (31 downto 0) of std_logic_vector(127 downto 0);
signal reg : register_array:= (
"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
"01101100000010101111000001001100011001010010010100010011111010010111100001000001001111110001010011111010010101010001110000000001",
"00101010101011011100011110101100110101010001101110001010100000100111010100101001101001001100101010011101000001101000110110101011",
"01000110111010011010001111000101111100101001101111101100011101101101110001100000000101100110000110101010111000010101110001111010",
"00101011100101011100010011100111101100001100001011000011010111001101110110000101111001000000000111100000000111101110011011110000",
"10111000100010000100010111111001000000001110111011111011000010101101101100100011010100101110100111000000111001010111000000011101",
"11011010101100100011001001110101100001100101100100000101011101110100001010010110100010110000110100001000110100001111110011001001",
"11100011111111001000110110001110111100001100111100101101011101001010110001011100001101010111101010100010111111100100101010100111",
"10101000101110100101001000111101110110100101001010001111011001100100110110110110111100111010011011010101001000001111100001001011",
"00110111011101110110011100110100111001010010110101001110001011011010011111011111110100000101001010000000110000110101011100110100",
"00101000010000111010001001010001101010000000111101110110000001001110000111100101011001101111011100001111111101110010000011100110",
"11001011011010111110101101101110000101110111010101100111101010100010100011000111000000100011011011101010101000000000010001101001",
"00000100110100000010010101100101011111111110111010110011110101000110101001100010011000011110001001000000000011000010000000110011",
"11010101100011111011011000011110011101110100000010110110101001001000001110000000011000101100011001000010001001110110001010001000",
"00010011000001101100011100001110110100111101001111000000001111011110000001110010110000101100111010100010001010100100011011011110",
"00001100001110010110010010110001100100111110101011100111000101100101001101111101011011110101011001110111111111100001010111000001",
"11010001001111010101101011111111100010000000000100110011010100001111110110011111101111110110100011111101101100110011000100101000",
"00010101010001110010101011011101111100000110100100010110001100111111110001101011101110010111011101010000000101100111001100001101",
"11000101110111011110000101000101011011110010010011011000100011110101100110011111111001011100010011100000100011000010101101101100",
"01001010000100000111000110001001000101101111000110101001110011000101100111010111100100101000111011101100100110111100000010101111",
"00001110011111100110111010100100111100010000011000101001001110000011000100001100010010100010011110110001101111100110101101100100",
"00111011000110010111000001000111011001100101001100100111001001100110110010101000101111001111101100101001110111000001010111100111",
"11111010111100010000100100001100011001000001100101010101011100011000010111100100100100101100010101011110101000101010000101110101",
"10001100111110110100110101111110000000101010100011011101010110101100100111001101110010001010110011000100011110100101001001011010",
"11111111100101100001000010011101100110001110001010111010101001001111001101011100000000000001011110010111110001010010101001000110",
"10000100100011110100001010110000101010001111011001111000000001001101001100010010010010111010011011011101011001000010011100000100",
"01110010011000010100111110000111111100111010101001011001011111101000111000110101010110111100001011001100100100000100100000110110",
"01110001101011110111110010000111001110010000110001000100010110011110101110100101000001101011000110101001000010101001110101010111",
"11101110010000000110101101010100010110101011111100101101111000111111000011101111010000001111111011011111001010001100000001001110",
"00101001010011000110110101001001011010110011000011011111011001100000101000000010000111000110001111001010111010010011110110001111",
"10000111010111001100111011011000101000101011111011100011000000011100101100100101000010110111111000010010101111110100100000110110",
"00011010010100000010101110000100111101111001111000100110000011010000101010000111101110100110111110001111101010011010010011001010");  		 --array of all 32 128-bit registers					
begin
	decode: process (instr, register_write, oldInstr)
	variable index:integer:=0;			--stores the index of which register to be accessed
	begin	   
		index:= to_integer(unsigned(instr(9 downto 5)));
		rs1 <= std_logic_vector(reg(index)); 		   
		index:= to_integer(unsigned(instr(14 downto 10)));
		rs2 <= std_logic_vector(reg(index));	 
		index:= to_integer(unsigned(instr(19 downto 15)));
		rs3 <= std_logic_vector(reg(index));   
		index:= to_integer(unsigned(instr(4 downto 0)));
		rd <= std_logic_vector(reg(index));
		sel <= instr;
		if(oldInstr = "0000000000000000000000000") then	  --when there is no old instruction, bc the default is all 0's, then there is no write back
			--do nothing
		else											  --otherwise using the rd of the old instruction, save the write back to that register
			index:= to_integer(unsigned(oldInstr(4 downto 0)));
			reg(index) <= register_write;
		end if;																  
	end process;	  
	
	show_regs: process
	begin 
		wait until done = '1';
		for reg_num in 0 to 31 loop
			register_status<=reg(reg_num);
			wait for 20 ns;
		end loop; 
		wait;
	end process;	
	
end architecture behavioral;	


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_forwarding is
	port( 	 
		rs1: in std_logic_vector(127 downto 0);
		rs2: in std_logic_vector(127 downto 0);
		rs3: in std_logic_vector(127 downto 0);	 
		rd: in std_logic_vector(127 downto 0);
		newInstr: in std_logic_vector(24 downto 0);	  
		currentInstr: in std_logic_vector(24 downto 0);	
		mmAluOut: in std_logic_vector(127 downto 0);  
		rs1_out: out std_logic_vector(127 downto 0);
		rs2_out: out std_logic_vector(127 downto 0);
		rs3_out: out std_logic_vector(127 downto 0); 
		rd_out: out std_logic_vector(127 downto 0);
		instruction_out: out std_logic_vector(24 downto 0)
    );
end data_forwarding;

architecture behavioral of data_forwarding is 
begin
	forward: process (newInstr, currentInstr)
	begin	
		if (currentInstr(4 downto 0) = newInstr(4 downto 0)) then
			rd_out <= mmAluOut;
			rs1_out <= rs1;
			rs2_out <= rs2;
			rs3_out <= rs3;
			instruction_out <= newInstr;	   
		elsif (currentInstr(4 downto 0) = newInstr(9 downto 5)) then
			rs1_out <= mmAluOut;
			rs2_out <= rs2;
			rs3_out <= rs3;
			rd_out <= rd;
			instruction_out <= newInstr;
		elsif (currentInstr(4 downto 0) = newInstr(14 downto 10)) then		
			rs2_out <= mmAluOut;
			rs1_out <= rs1;
			rs3_out <= rs3;
			rd_out <= rd;
			instruction_out <= newInstr;
		elsif (currentInstr(4 downto 0) = newInstr(19 downto 15)) then
			rs3_out <= mmAluOut;
			rs1_out <= rs1;
			rs2_out <= rs2;	
			rd_out <= rd;
			instruction_out <= newInstr;
		else
			rs1_out <= rs1;
			rs2_out <= rs2;
			rs3_out <= rs3;	
			rd_out <= rd;
			instruction_out <= newInstr;
		end if;	
	end process;	
end architecture behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity four_stage_pipelined_multimedia_unit is
	port(	
	instruction_array: in std_logic_vector(24 downto 0);
	clk: in std_logic;
	reset: in std_logic;   
	done: in std_logic;
	mmOut: out std_logic_vector(127 downto 0);
	rs1_d1_check: out std_logic_vector(127 downto 0);
	rs2_d1_check: out std_logic_vector(127 downto 0);
	rs3_d1_check: out std_logic_vector(127 downto 0);
	instruction_d1_check: out std_logic_vector(24 downto 0);
	instr_d1_check: out std_logic_vector(24 downto 0);
	instruction_fd1_check: out std_logic_vector(24 downto 0);
	register_status: out std_logic_vector(127 downto 0)
	);
end four_stage_pipelined_multimedia_unit;

architecture structural of four_stage_pipelined_multimedia_unit is	 
signal instr, instr_d1, instruction, instruction_d1, instruction_f, instruction_fd1: std_logic_vector(24 downto 0):=(others=>'0'); 
signal rs1, rs2, rs3, rd, rs1_d1, rs2_d1, rs3_d1, rd_d1, rs1_f, rs2_f, rs3_f, rd_f, rd_out, write_back: std_logic_vector(127 downto 0):=(others=>'0'); 
begin		
	u0: entity instruction_fetcher port map(instruction_array=>instruction_array, clk=>clk, instr=>instr);
	
	ifid_reg: process (reset, clk)
	begin 
		if(reset='1') then
			instr_d1<=(others=>'0');
		elsif(rising_edge(clk)) then
			instr_d1<=instr;
			instr_d1_check<=instr;
		end if;
	end process;  
								  
	u1: entity decoder port map(done=>done, instr=>instr_d1, register_write=>write_back, oldInstr=>instruction_fd1 , rs1=>rs1, rs2=>rs2, rs3=>rs3, rd=>rd, sel=>instruction, register_status=>register_status);
		
	idex_reg: process (reset, clk)
	begin 
		if(reset='1') then
			rs1_d1<=(others=>'0');
			rs2_d1<=(others=>'0');
			rs3_d1<=(others=>'0');
			rd_d1<=(others=>'0');
			instruction_d1<=(others=>'0');
		elsif(rising_edge(clk)) then
			rs1_d1<=rs1;
			rs2_d1<=rs2;
			rs3_d1<=rs3; 
			rd_d1<=rd;
			instruction_d1<=instruction; 
			rs1_d1_check<=rs1;	
			rs2_d1_check<=rs2;
			rs3_d1_check<=rs3;
			instruction_d1_check<=instruction;
		end if;
	end process;
	
	u2: entity data_forwarding port map(rs1=>rs1_d1, rs2=>rs2_d1, rs3=>rs3_d1, rd=> rd_d1, newInstr=>instruction_d1, currentInstr=>instruction_fd1, mmAluOut=>write_back, rs1_out=>rs1_f, rs2_out=>rs2_f, rs3_out=>rs3_f, rd_out=>rd_f, instruction_out=>instruction_f);
		
	u3: entity mm_alu port map(rs1=>rs1_f, rs2=>rs2_f, rs3=>rs3_f, rd_in=>rd_f, sel=>instruction_f, rd_out=>rd_out);
		
	exwb_reg: process (reset, clk)
	begin 
		if(reset='1') then
			instruction_fd1<=(others=>'0');
			write_back<=(others=>'0');
			mmOut<=(others=>'0');
		elsif(rising_edge(clk)) then
			write_back<=rd_out;
			instruction_fd1<=instruction_f;
			mmOut<=rd_out; 
			instruction_fd1_check<=instruction_f;
		end if;
	end process;
	
end architecture structural;
