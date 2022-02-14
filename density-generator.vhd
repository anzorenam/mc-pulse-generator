library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity density_generator is
generic(init_seed: natural:= 1;
bin_width: natural:= 10;
urnd_width: natural:= 14);
port(gclk: in std_logic;
ctrl_rand: in std_logic_vector (2 downto 0);
binary_random: out unsigned (bin_width-1 downto 0));
end entity;

architecture x of density_generator is
constant seed: natural:= init_seed;
signal lfsr: unsigned (63+urnd_width downto 0);
signal urnd: unsigned (urnd_width-1 downto 0);
signal drnd: std_logic_vector (bin_width-1 downto 0);

component inverse_sample is
port(clock: in std_logic;
address:in std_logic_vector (urnd_width-1 downto 0);
q: out std_logic_vector (bin_width-1 downto 0));
end component;

begin

sampler: inverse_sample
port map(clock=>gclk,
         address=>std_logic_vector(urnd),
         q=>drnd
);

process(gclk,ctrl_rand)
begin
  if ctrl_rand="001" then
    lfsr<=to_unsigned(seed,63+urnd_width+1);
  else
    if rising_edge(gclk) then
      lfsr(63+urnd_width downto urnd_width)<=lfsr(63 downto 0);
      for j in 0 to urnd_width-1 loop
        lfsr(urnd_width-j-1)<=lfsr(77-j) xor lfsr(76-j) xor lfsr(58-j) xor lfsr(57-j);
      end loop;
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if ctrl_rand="010" then
      urnd<=lfsr(urnd_width-1 downto 0);
    elsif ctrl_rand="001" or ctrl_rand="101" then
      urnd<=(others=>'0');
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if ctrl_rand="011" then
      binary_random<=unsigned(drnd);
    elsif ctrl_rand="001" or ctrl_rand="101" then
      binary_random<=(others=>'0');
    end if;
  end if;
end process;

end x;
