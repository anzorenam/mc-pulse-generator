library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity poisson_generator is
generic(rate_mask: natural:= 25770;  -- default rate = 1.5 kHz at 250 MHz clk
init_seed: natural:= 100);
port(gclk,grst: in std_logic;
trigger_signal: out std_logic);
end entity;
architecture x of poisson_generator is
constant pvalue: unsigned:= to_unsigned(rate_mask,96);
constant seed: natural:= init_seed;
signal lfsr: unsigned(95 downto 0);
signal urnd: unsigned(31 downto 0);
signal trigger: std_logic;
begin

process(gclk)
begin
  if rising_edge(gclk) then
    if grst='0' then
      lfsr<=to_unsigned(seed,96);
    else
      lfsr(95 downto 32)<=lfsr(63 downto 0);
      for j in 0 to 31 loop
        lfsr(31-j)<=lfsr(95-j) xor lfsr(93-j) xor lfsr(48-j) xor lfsr(46-j);
      end loop;
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if grst='0' then
      trigger<='0';
    else
      if urnd<=pvalue then
        trigger<='1';
      else
        trigger<='0';
      end if;
    end if;
  end if;
end process;

trigger_signal<=trigger;
urnd<=lfsr(31 downto 0);

end x;
