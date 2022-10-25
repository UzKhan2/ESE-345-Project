library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mm_alu is
	port( 
	rs1 : in std_logic_vector(127 downto 0);
	rs2: in std_logic_vector(127 downto 0); 
	rs3: in std_logic_vector(127 downto 0);
	--sel: in std_logic_vector(24 downto 0);
	sel: in std_logic_vector(2 downto 0);
	rd: out std_logic_vector(127 downto 0)
    );
end mm_alu;

architecture behavioral of mm_alu is  
begin	
	r4: process (rs2, rs3, sel) 	--all the multiplication is done here
	variable mult_out : std_logic_vector(127 downto 0); --holds the output of the multiplication  
	variable clz0, clz1, clz2, clz3 : std_logic_vector(31 downto 0) := 0;
	begin	
		if sel(24) = "0" then
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
		elsif sel(24 downto 23) = "10"
			if sel(22 downto 20) = ("000" or "010") then --multiplies the low 16 bits of rs3 and rs2
				mult_out(31 downto 0) := std_logic_vector(resize(signed(rs3(15 downto 0)) * signed(rs2(15 downto 0)), 32));
				mult_out(63 downto 32) := std_logic_vector(resize(signed(rs3(47 downto 32)) * signed(rs2(47 downto 32)), 32));
				mult_out(95 downto 64) := std_logic_vector(resize(signed(rs3(79 downto 64)) * signed(rs2(79 downto 64)), 32));
				mult_out(127 downto 96) := std_logic_vector(resize(signed(rs3(111 downto 96)) * signed(rs2(111 downto 96)), 32));
				if sel(22 downto 20) = "000" then
					rd(31 downto 0) <= std_logic_vector(resize(signed(rs1(31 downto 0)) + signed(mult_out(31 downto 0)), 32));  
					rd(63 downto 32) <= std_logic_vector(resize(signed(rs1(63 downto 32)) + signed(mult_out(63 downto 32)), 32));
					rd(95 downto 64) <= std_logic_vector(resize(signed(rs1(95 downto 64)) + signed(mult_out(95 downto 64)), 32));
					rd(127 downto 96) <= std_logic_vector(resize(signed(rs1(127 downto 96)) + signed(mult_out(127 downto 96)), 32));
				elsif sel(22 downto 20) = "010" then
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
				if sel(22 downto 20) = "001" then
					rd(31 downto 0) <= std_logic_vector(resize(signed(rs1(31 downto 0)) + signed(mult_out(31 downto 0)), 32));  
					rd(63 downto 32) <= std_logic_vector(resize(signed(rs1(63 downto 32)) + signed(mult_out(63 downto 32)), 32));
					rd(95 downto 64) <= std_logic_vector(resize(signed(rs1(95 downto 64)) + signed(mult_out(95 downto 64)), 32));
					rd(127 downto 96) <= std_logic_vector(resize(signed(rs1(127 downto 96)) + signed(mult_out(127 downto 96)), 32));
				elsif sel(22 downto 20) = "011" then
					rd(31 downto 0) <= std_logic_vector(resize(signed(rs1(31 downto 0)) - signed(mult_out(31 downto 0)), 32));  
					rd(63 downto 32) <= std_logic_vector(resize(signed(rs1(63 downto 32)) - signed(mult_out(63 downto 32)), 32));
					rd(95 downto 64) <= std_logic_vector(resize(signed(rs1(95 downto 64)) - signed(mult_out(95 downto 64)), 32));
					rd(127 downto 96) <= std_logic_vector(resize(signed(rs1(127 downto 96)) - signed(mult_out(127 downto 96)), 32));
				end if;
			elsif sel(22 downto 20) = ("100" or "110") then --multiplies the low 32 bits of rs3 and rs2
				mult_out(63 downto 0) := std_logic_vector(resize(signed(rs3(31 downto 0)) * signed(rs2(31 downto 0)), 64));
				mult_out(127 downto 64) := std_logic_vector(resize(signed(rs3(95 downto 64)) * signed(rs2(95 downto 64)), 64));
				if sel(22 downto 20) = "100" then
					rd(63 downto 0) <= std_logic_vector(resize(signed(rs1(63 downto 0)) + signed(mult_out(63 downto 0)), 64));
					rd(127 downto 64) <= std_logic_vector(resize(signed(rs1(127 downto 64)) + signed(mult_out(127 downto 64)), 64));
				elsif sel(22 downto 20) = "110" then
					rd(63 downto 0) <= std_logic_vector(resize(signed(rs1(63 downto 0)) - signed(mult_out(63 downto 0)), 64));
					rd(127 downto 64) <= std_logic_vector(resize(signed(rs1(127 downto 64)) - signed(mult_out(127 downto 64)), 64));
				end if;
			elsif sel(22 downto 20) = ("101" or "111") then --multiplies the high 32 bits of rs3 and rs2
				mult_out(63 downto 0) := std_logic_vector(resize(signed(rs3(63 downto 32)) * signed(rs2(63 downto 32)), 64));
				mult_out(127 downto 64) := std_logic_vector(resize(signed(rs3(127 downto 96)) * signed(rs2(127 downto 96)), 64));
				if sel(22 downto 20) = "101" then
					rd(63 downto 0) <= std_logic_vector(resize(signed(rs1(63 downto 0)) + signed(mult_out(63 downto 0)), 64));
					rd(127 downto 64) <= std_logic_vector(resize(signed(rs1(127 downto 64)) + signed(mult_out(127 downto 64)), 64));
				elsif sel(22 downto 20) = "111" then
					rd(63 downto 0) <= std_logic_vector(resize(signed(rs1(63 downto 0)) - signed(mult_out(63 downto 0)), 64));
					rd(127 downto 64) <= std_logic_vector(resize(signed(rs1(127 downto 64)) - signed(mult_out(127 downto 64)), 64));
				end if;
			end if;		
		elsif sel(24 downto 23) = "11" then
			if sel(18 downto 15) = "0000" then
			   --nop 
			elsif sel(18 downto 15) = "0001" then
				section0: for i in 31 downto 0 loop
					if rs1(i)!='0' then
						exit;
					else
						clz0:=clz0+1;
					end if;		
				end loop section0;		
				section1: for i in 63 downto 32 loop
					if rs1(i)!='0' then
						exit;
					else
						clz1:=clz1+1;
					end if;		
				end loop section1; 
				section2: for i in 95 downto 64 loop
					if rs1(i)!='0' then
						exit;
					else
						clz2:=clz2+1;
					end if;		
				end loop section2;
				section3: for i in 127 downto 96 loop
					if rs1(i)!='0' then
						exit;
					else
						clz3:=clz3+1;
					end if;		
				end loop section3; 
				rd(31 downto 0)<=clz0;
				rd(63 downto 32)<=clz1;
				rd(95 downto 64)<=clz2;
				rd(127 downto 96)<=clz3;
			elsif sel(18 downto 15) = "0010" then
				rd(31 downto 0) <= std_logic_vector(unsigned(rs1(31 downto 0)) + unsigned(rs2(31 downto 0)));  
				rd(63 downto 32) <= std_logic_vector(unsigned(rs1(63 downto 32)) + unsigned(rs2(63 downto 32)));
				rd(95 downto 64) <= std_logic_vector(unsigned(rs1(95 downto 64)) + unsigned(rs2(95 downto 64)));
				rd(127 downto 96) <= std_logic_vector(unsigned(rs1(127 downto 96)) + unsigned(rs2(127 downto 96)));
			elsif sel(18 downto 15) = "0011" then
				rd(31 downto 0) <= std_logic_vector(resize(unsigned(rs1(31 downto 0)) + unsigned(rs2(31 downto 0)), 32));  
				rd(63 downto 32) <= std_logic_vector(resize(unsigned(rs1(63 downto 32)) + unsigned(rs2(63 downto 32)), 32));
				rd(95 downto 64) <= std_logic_vector(resize(unsigned(rs1(95 downto 64)) + unsigned(rs2(95 downto 64)), 32));
				rd(127 downto 96) <= std_logic_vector(resize(unsigned(rs1(127 downto 96)) + unsigned(rs2(127 downto 96)), 32));	   
			elsif sel(18 downto 15) = "0100" then
				rd(31 downto 0) <= std_logic_vector(resize(unsigned(rs1(31 downto 0)) + unsigned(rs2(31 downto 0)), 32));  
				rd(63 downto 32) <= std_logic_vector(resize(unsigned(rs1(63 downto 32)) + unsigned(rs2(63 downto 32)), 32));
				rd(95 downto 64) <= std_logic_vector(resize(unsigned(rs1(95 downto 64)) + unsigned(rs2(95 downto 64)), 32));
				rd(127 downto 96) <= std_logic_vector(resize(unsigned(rs1(127 downto 96)) + unsigned(rs2(127 downto 96)), 32));
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
