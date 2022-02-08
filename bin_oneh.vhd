library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_oneh is
generic(bin_width: natural:= 10;
onehot_width: natural:= 1024);
port(clk,rst,hab_reg: std_logic;
binary: in unsigned(bin_width-1 downto 0);
onehot: out std_logic_vector (onehot_width-1 downto 0));
end entity;
architecture x of bin_oneh is
signal decoder: std_logic_vector (onehot_width-1 downto 0);
begin

process(binary)
variable code: std_logic_vector(onehot_width-1 downto 0);
begin
  code:=(others=>'0');
  for j in 0 to onehot_width-1 loop
    if to_integer(binary)=j then
      code(j):='1';
    else
      code(j):='0';
    end if;
  end loop;
  decoder<=code;
end process;

process(clk,rst)
begin
  if rst='1' then
    onehot<=(others=>'0');
  else
    if rising_edge(clk) then
      if hab_reg='1' then
        onehot<=decoder;
      end if;
    end if;
  end if;
end process;

end x;
