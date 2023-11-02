library ieee;
library xpm;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity density_generator is
port(gclk,gen_sel: in std_logic;
seed: in unsigned (7 downto 0);
ctrl_rand: in std_logic_vector (3 downto 0);
drnd: in unsigned (15 downto 0);
urnd: out unsigned (15 downto 0);
binary_rand: out unsigned (9 downto 0));
end entity;

architecture x of density_generator is
signal local_rst: std_logic;
signal local_hab: std_logic_vector (1 downto 0);
signal drnd_aux: unsigned (15 downto 0);

signal lfsr,init_seed: unsigned (79 downto 0);

begin

process(gclk)
begin
  if rising_edge(gclk) then
    if ctrl_rand="0001" then
      lfsr<=init_seed;
    else
      if local_hab="01" then
        lfsr(79 downto 16)<=lfsr(63 downto 0);
        for j in 0 to 15 loop
          lfsr(15-j)<=lfsr(79-j) xor lfsr(78-j) xor lfsr(42-j) xor lfsr(41-j);
        end loop;
      end if;
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if local_rst='1' then
      urnd<=(others=>'0');
    else
      if local_hab="10" then
        urnd<=lfsr(15 downto 0);
      end if;
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if local_rst='1' then
      binary_rand<=(others=>'0');
    else
      if local_hab="11" then
        binary_rand<=drnd_aux(9 downto 0);
      end if;
    end if;
  end if;
end process;

init_seed(79 downto 8)<=(others=>'0');
init_seed(7 downto 0)<=seed;

local_rst<='1' when (ctrl_rand="0001" or ctrl_rand="1000") else
                 '0';

local_hab<="01" when (ctrl_rand="0010" and gen_sel='1') else
                  "10" when (ctrl_rand="0011" and gen_sel='1') else
                  "11" when (ctrl_rand="0101" and gen_sel='1') else
                  "00";

drnd_aux<=drnd;


end x;
