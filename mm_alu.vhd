library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mm_alu is
	port( 
	rs1 : in std_logic_vector(127 downto 0);
	rs2: in std_logic_vector(127 downto 0); 
	rs3: in std_logic_vector(127 downto 0);
	sel: in std_logic_vector(24 downto 0);
	rd: out std_logic_vector(127 downto 0)
    );
end mm_alu;

architecture behavioral of mm_alu is  
begin	
	r4: process (rs2, rs3, sel) 	--all the multiplication is done here
	variable mult_out : std_logic_vector(127 downto 0); --holds the output of the multiplication  
	variable clz0, clz1, clz2, clz3 : std_logic_vector(31 downto 0) := (others => '0');	--counts leading 0's in each 32 bit section of rs1
	variable ones0, ones1, ones2, ones3 : std_logic_vector(31 downto 0) := (others => '0'); --counts number of 1's in each 32 bit section of rs1
	variable rot : std_logic_vector(31 downto 0);
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
			if sel(22 downto 20) = ("000" or "010") then --multiplies the low 16 bits of rs3 and rs2
				mult_out(31 downto 0) := std_logic_vector(resize(signed(rs3(15 downto 0)) * signed(rs2(15 downto 0)), 32));
				mult_out(63 downto 32) := std_logic_vector(resize(signed(rs3(47 downto 32)) * signed(rs2(47 downto 32)), 32));
				mult_out(95 downto 64) := std_logic_vector(resize(signed(rs3(79 downto 64)) * signed(rs2(79 downto 64)), 32));
				mult_out(127 downto 96) := std_logic_vector(resize(signed(rs3(111 downto 96)) * signed(rs2(111 downto 96)), 32));
				if sel(22 downto 20) = "000" then --adds 32 bit product to 32 bit rs1
					rd(31 downto 0) <= std_logic_vector(resize(signed(rs1(31 downto 0)) + signed(mult_out(31 downto 0)), 32));  
					rd(63 downto 32) <= std_logic_vector(resize(signed(rs1(63 downto 32)) + signed(mult_out(63 downto 32)), 32));
					rd(95 downto 64) <= std_logic_vector(resize(signed(rs1(95 downto 64)) + signed(mult_out(95 downto 64)), 32));
					rd(127 downto 96) <= std_logic_vector(resize(signed(rs1(127 downto 96)) + signed(mult_out(127 downto 96)), 32));
				elsif sel(22 downto 20) = "010" then --subtracts 32 bit product from 32 bit rs1
					rd(31 downto 0) <= std_logic_vector(resize(signed(rs1(31 downto 0)) - signed(mult_out(31 downto 0)), 32));  
					rd(63 downto 32) <= std_logic_vector(resize(signed(rs1(63 downto 32)) - signed(mult_out(63 downto 32)), 32));
					rd(95 downto 64) <= std_logic_vector(resize(signed(rs1(95 downto 64)) - signed(mult_out(95 downto 64)), 32));
					rd(127 downto 96) <= std_logic_vector(resize(signed(rs1(127 downto 96)) - signed(mult_out(127 downto 96)), 32));
				end if;
			elsif sel(22 downto 20) = ("001" or "011") then --multiplies the high 16 bits of rs3 and rs2
				mult_out(31 downto 0) := std_logic_vector(resize(signed(rs3(31 downto 16)) * signed(rs2(31 downto 16)), 32)); 
				mult_out(63 downto 32) := std_logic_vector(resize(signed(rs3(63 downto 48)) * signed(rs2(63 downto 48)), 32));
				mult_out(95 downto 64) := std_logic_vector(resize(signed(rs3(95 downto 80)) * signed(rs2(95 downto 80)), 32));
				mult_out(127 downto 96) := std_logic_vector(resize(signed(rs3(127 downto 112)) * signed(rs2(127 downto 112)), 32));	  
				if sel(22 downto 20) = "001" then --adds 32 bit product to 32 bit rs1
					rd(31 downto 0) <= std_logic_vector(resize(signed(rs1(31 downto 0)) + signed(mult_out(31 downto 0)), 32));  
					rd(63 downto 32) <= std_logic_vector(resize(signed(rs1(63 downto 32)) + signed(mult_out(63 downto 32)), 32));
					rd(95 downto 64) <= std_logic_vector(resize(signed(rs1(95 downto 64)) + signed(mult_out(95 downto 64)), 32));
					rd(127 downto 96) <= std_logic_vector(resize(signed(rs1(127 downto 96)) + signed(mult_out(127 downto 96)), 32));
				elsif sel(22 downto 20) = "011" then --subtracts 32 bit product from 32 bit rs1
					rd(31 downto 0) <= std_logic_vector(resize(signed(rs1(31 downto 0)) - signed(mult_out(31 downto 0)), 32));  
					rd(63 downto 32) <= std_logic_vector(resize(signed(rs1(63 downto 32)) - signed(mult_out(63 downto 32)), 32));
					rd(95 downto 64) <= std_logic_vector(resize(signed(rs1(95 downto 64)) - signed(mult_out(95 downto 64)), 32));
					rd(127 downto 96) <= std_logic_vector(resize(signed(rs1(127 downto 96)) - signed(mult_out(127 downto 96)), 32));
				end if;
			elsif sel(22 downto 20) = ("100" or "110") then --multiplies the low 32 bits of rs3 and rs2
				mult_out(63 downto 0) := std_logic_vector(resize(signed(rs3(31 downto 0)) * signed(rs2(31 downto 0)), 64));
				mult_out(127 downto 64) := std_logic_vector(resize(signed(rs3(95 downto 64)) * signed(rs2(95 downto 64)), 64));
				if sel(22 downto 20) = "100" then --add 64 bit product to 64 bit rs1
					rd(63 downto 0) <= std_logic_vector(resize(signed(rs1(63 downto 0)) + signed(mult_out(63 downto 0)), 64));
					rd(127 downto 64) <= std_logic_vector(resize(signed(rs1(127 downto 64)) + signed(mult_out(127 downto 64)), 64));
				elsif sel(22 downto 20) = "110" then --subtracts 64 bit product from 64 bit rs1
					rd(63 downto 0) <= std_logic_vector(resize(signed(rs1(63 downto 0)) - signed(mult_out(63 downto 0)), 64));
					rd(127 downto 64) <= std_logic_vector(resize(signed(rs1(127 downto 64)) - signed(mult_out(127 downto 64)), 64));
				end if;
			elsif sel(22 downto 20) = ("101" or "111") then --multiplies the high 32 bits of rs3 and rs2
				mult_out(63 downto 0) := std_logic_vector(resize(signed(rs3(63 downto 32)) * signed(rs2(63 downto 32)), 64));
				mult_out(127 downto 64) := std_logic_vector(resize(signed(rs3(127 downto 96)) * signed(rs2(127 downto 96)), 64));
				if sel(22 downto 20) = "101" then --adds 64 bit product to 64 bit rs1
					rd(63 downto 0) <= std_logic_vector(resize(signed(rs1(63 downto 0)) + signed(mult_out(63 downto 0)), 64));
					rd(127 downto 64) <= std_logic_vector(resize(signed(rs1(127 downto 64)) + signed(mult_out(127 downto 64)), 64));
				elsif sel(22 downto 20) = "111" then --subtracts 64 bit product from 64 bit rs1
					rd(63 downto 0) <= std_logic_vector(resize(signed(rs1(63 downto 0)) - signed(mult_out(63 downto 0)), 64));
					rd(127 downto 64) <= std_logic_vector(resize(signed(rs1(127 downto 64)) - signed(mult_out(127 downto 64)), 64));
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
				rd(15 downto 0) <= std_logic_vector(resize(signed(rs2(15 downto 0)) + signed(rs1(15 downto 0)), 16));
				rd(31 downto 16) <= std_logic_vector(resize(signed(rs2(31 downto 16)) + signed(rs1(31 downto 16)), 16)); 
				rd(47 downto 32) <= std_logic_vector(resize(signed(rs2(47 downto 32)) + signed(rs1(47 downto 32)), 16));
				rd(63 downto 48) <= std_logic_vector(resize(signed(rs2(63 downto 48)) + signed(rs1(63 downto 48)), 16));
				rd(79 downto 64) <= std_logic_vector(resize(signed(rs2(79 downto 64)) + signed(rs1(79 downto 64)), 16));
				rd(95 downto 80) <= std_logic_vector(resize(signed(rs2(95 downto 80)) + signed(rs1(95 downto 80)), 16));
				rd(111 downto 96) <= std_logic_vector(resize(signed(rs2(111 downto 96)) + signed(rs1(111 downto 96)), 16));
				rd(127 downto 112) <= std_logic_vector(resize(signed(rs2(127 downto 112)) + signed(rs1(127 downto 112)), 16));
			elsif sel(18 downto 15) = "0101" then --bitwise logical and of rs1 and rs2
				rd<=rs1 and rs2;
			elsif sel(18 downto 15) = "0110" then --place rightmost 32 bit word of rs1 into every 32 bit section of rd
				rd(31 downto 0) <= rs1(31 downto 0);  
				rd(63 downto 32) <= rs1(31 downto 0);
				rd(95 downto 64) <= rs1(31 downto 0);
				rd(127 downto 96) <= rs1(31 downto 0);				
			elsif sel(18 downto 15) = "0111" then --place larger signed value between rs1 and rs2 32 bit sections in corresponding 32 bit section of rd
				rd(31 downto 0) <= maximum(rs1(31 downto 0), rs2(31 downto 0));  
				rd(63 downto 32) <= maximum(rs1(63 downto 32), rs2(63 downto 32));
				rd(95 downto 64) <= maximum(rs1(95 downto 64), rs2(95 downto 64));
				rd(127 downto 96) <= maximum(rs1(127 downto 96), rs2(127 downto 96));
			elsif sel(18 downto 15) = "1000" then --place smaller signed value between rs1 and rs2 32 bit sections in corresponding 32 bit section of rd
				rd(31 downto 0) <= minimum(rs1(31 downto 0), rs2(31 downto 0));  
				rd(63 downto 32) <= minimum(rs1(63 downto 32), rs2(63 downto 32));
				rd(95 downto 64) <= minimum(rs1(95 downto 64), rs2(95 downto 64));
				rd(127 downto 96) <= minimum(rs1(127 downto 96), rs2(127 downto 96));
			elsif sel(19 downto 15) = "01001" then --multiply low 16 unsigned bits of each 32 bit section of rs1 and rs2 and store in corresponding 32 bit section of rd
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
				rot <= to_integer(unsigned(rot));
				for i in rot downto 0 loop
					rs1 <= rs1(0) &  rs1(31 downto 1);
					rs1 <= rs1(32) &  rs1(62 downto 33);
					rs1 <= rs1(64) &  rs1(95 downto 65);
					rs1 <= rs1(96) &  rs1(127 downto 97);
				end loop;
			rd(31 downto 0) <= rs1(31 downto 0);
			rd(63 downto 32)<= rs1(63 downto 32);
			rd(95 downto 64)<= rs1(95 downto 64);
			rd(127 downto 96)<= rs1(127 downto 96);
			
			elsif sel(18 downto 15) = "1110" then
				rd(31 downto 0) <= std_logic_vector(unsigned(rs2(31 downto 0)) - unsigned(rs1(31 downto 0)));  
				rd(63 downto 32) <= std_logic_vector(unsigned(rs2(63 downto 32)) - unsigned(rs1(63 downto 32)));
				rd(95 downto 64) <= std_logic_vector(unsigned(rs2(95 downto 64)) - unsigned(rs1(95 downto 64)));
				rd(127 downto 96) <= std_logic_vector(unsigned(rs2(127 downto 96)) - unsigned(rs1(127 downto 96)));
			
			elsif sel(18 downto 15) = "1111" then
				rd(15 downto 0) <= std_logic_vector(resize(signed(rs2(15 downto 0)) - signed(rs1(15 downto 0)), 16));
				rd(31 downto 16) <= std_logic_vector(resize(signed(rs2(31 downto 16)) - signed(rs1(31 downto 16)), 16)); 
				rd(47 downto 32) <= std_logic_vector(resize(signed(rs2(47 downto 32)) - signed(rs1(47 downto 32)), 16));
				rd(63 downto 48) <= std_logic_vector(resize(signed(rs2(63 downto 48)) - signed(rs1(63 downto 48)), 16));
				rd(79 downto 64) <= std_logic_vector(resize(signed(rs2(79 downto 64)) - signed(rs1(79 downto 64)), 16));
				rd(95 downto 80) <= std_logic_vector(resize(signed(rs2(95 downto 80)) - signed(rs1(95 downto 80)), 16));
				rd(111 downto 96) <= std_logic_vector(resize(signed(rs2(111 downto 96)) - signed(rs1(111 downto 96)), 16));
				rd(127 downto 112) <= std_logic_vector(resize(signed(rs2(127 downto 112)) - signed(rs1(127 downto 112)), 16));
				
			end if;
		end if;
	end process r4;
	
	
end architecture behavioral;




--signal mult_out : std_logic_vector(127 downto 0); --holds the output of the multiplication
--begin	
--	mult: process (rs2, rs3, sel) 	--all the multiplication is done here
--	begin													  
--		if sel = ("000" or "010") then --multiplies the low 16 bits of rs3 and rs2
--			mult_out(31 downto 0) <= std_logic_vector(resize(signed(rs3(15 downto 0)) * signed(rs2(15 downto 0)), 32));
--			mult_out(63 downto 32) <= std_logic_vector(resize(signed(rs3(47 downto 32)) * signed(rs2(47 downto 32)), 32));
--			mult_out(95 downto 64) <= std_logic_vector(resize(signed(rs3(79 downto 64)) * signed(rs2(79 downto 64)), 32));
--			mult_out(127 downto 96) <= std_logic_vector(resize(signed(rs3(111 downto 96)) * signed(rs2(111 downto 96)), 32));
--		elsif sel = ("001" or "011") then --multiplies the high 16 bits of rs3 and rs2
--			mult_out(31 downto 0) <= std_logic_vector(resize(signed(rs3(31 downto 16)) * signed(rs2(31 downto 16)), 32)); 
--			mult_out(63 downto 32) <= std_logic_vector(resize(signed(rs3(63 downto 48)) * signed(rs2(63 downto 48)), 32));
--			mult_out(95 downto 64) <= std_logic_vector(resize(signed(rs3(95 downto 80)) * signed(rs2(95 downto 80)), 32));
--			mult_out(127 downto 96) <= std_logic_vector(resize(signed(rs3(127 downto 112)) * signed(rs2(127 downto 112)), 32));	 
--		elsif sel = ("100" or "110") then --multiplies the low 32 bits of rs3 and rs2
--			mult_out(63 downto 0) <= std_logic_vector(resize(signed(rs3(31 downto 0)) * signed(rs2(31 downto 0)), 64));
--			mult_out(127 downto 64) <= std_logic_vector(resize(signed(rs3(95 downto 64)) * signed(rs2(95 downto 64)), 64));
--		elsif sel = ("101" or "111") then --multiplies the high 32 bits of rs3 and rs2
--			mult_out(63 downto 0) <= std_logic_vector(resize(signed(rs3(63 downto 32)) * signed(rs2(63 downto 32)), 64));
--			mult_out(127 downto 64) <= std_logic_vector(resize(signed(rs3(127 downto 96)) * signed(rs2(127 downto 96)), 64));	
--		end if;	  
--	end process mult;		 
--	
--	secondHalf: process (mult_out, rs1)	--all the addition/subtraction is done here
--	begin
--		if sel = ("000" or "001") then --adding 32 bits of mult_out to rs1
--			rd(31 downto 0) <= std_logic_vector(resize(signed(rs1(31 downto 0)) + signed(mult_out(31 downto 0)), 32));  
--			rd(63 downto 32) <= std_logic_vector(resize(signed(rs1(63 downto 32)) + signed(mult_out(63 downto 32)), 32));
--			rd(95 downto 64) <= std_logic_vector(resize(signed(rs1(95 downto 64)) + signed(mult_out(95 downto 64)), 32));
--			rd(127 downto 96) <= std_logic_vector(resize(signed(rs1(127 downto 96)) + signed(mult_out(127 downto 96)), 32));
--		elsif sel = ("010" or "011") then --subtracting 32 bits of mult_out from rs1
--			rd(31 downto 0) <= std_logic_vector(resize(signed(rs1(31 downto 0)) - signed(mult_out(31 downto 0)), 32));  
--			rd(63 downto 32) <= std_logic_vector(resize(signed(rs1(63 downto 32)) - signed(mult_out(63 downto 32)), 32));
--			rd(95 downto 64) <= std_logic_vector(resize(signed(rs1(95 downto 64)) - signed(mult_out(95 downto 64)), 32));
--			rd(127 downto 96) <= std_logic_vector(resize(signed(rs1(127 downto 96)) - signed(mult_out(127 downto 96)), 32));
--		elsif sel = ("100" or "101") then --adding 64 bits of mult_out to rs1
--			rd(63 downto 0) <= std_logic_vector(resize(signed(rs1(63 downto 0)) + signed(mult_out(63 downto 0)), 64));
--			rd(127 downto 64) <= std_logic_vector(resize(signed(rs1(127 downto 64)) + signed(mult_out(127 downto 64)), 64));
--		elsif sel = ("110" or "111") then --subtracting 64 bits of mult_out from rs1
--			rd(63 downto 0) <= std_logic_vector(resize(signed(rs1(63 downto 0)) - signed(mult_out(63 downto 0)), 64));
--			rd(127 downto 64) <= std_logic_vector(resize(signed(rs1(127 downto 64)) - signed(mult_out(127 downto 64)), 64));
--		end if;
--	end	process secondHalf;
	
--end architecture behavioral;
