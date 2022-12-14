library ieee;
library xpm;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use xpm.vcomponents.all;

entity density_generator is
generic(init_seed: natural:= 1;
bin_width: natural:= 10;
urnd_width: natural:= 12;
rom_init: string:= "inverse_sample.mem");
port(gclk: in std_logic;
ctrl_rand: in std_logic_vector (2 downto 0);
binary_random: out unsigned (bin_width-1 downto 0));
end entity;

architecture x of density_generator is
constant seed: natural:= init_seed;
signal lfsr: unsigned (63+urnd_width downto 0);
signal urnd: unsigned (urnd_width-1 downto 0);
signal drnd: std_logic_vector (bin_width-1 downto 0);

begin

sampler: xpm_memory_sprom
generic map(ADDR_WIDTH_A=>urnd_width,
AUTO_SLEEP_TIME=>0,
CASCADE_HEIGHT=>0,
ECC_MODE=>"no_ecc",
MEMORY_INIT_FILE=>rom_init,
MEMORY_INIT_PARAM=>"",
MEMORY_OPTIMIZATION=>"true",
MEMORY_PRIMITIVE=>"distributed",
MEMORY_SIZE=>bin_width*(2**urnd_width),
MESSAGE_CONTROL=>0,
READ_DATA_WIDTH_A=>bin_width,
READ_LATENCY_A=>1,
READ_RESET_VALUE_A=>"0",
RST_MODE_A=>"SYNC",
SIM_ASSERT_CHK=>0,
USE_MEM_INIT=>0,
WAKEUP_TIME=>"disable_sleep")
port map(dbiterra=>open,
         douta=>drnd,
         sbiterra=>open,
         addra=>std_logic_vector(urnd),
         clka=>gclk,
         injectdbiterra=>'0',
         injectsbiterra=>'0',
         regcea=>'0',
         ena=>'1',
         rsta=>'0',
         sleep=>'0'
);

process(gclk)
begin
  if rising_edge(gclk) then
    if ctrl_rand="001" then
      lfsr<=to_unsigned(seed,63+urnd_width+1);
    else
      lfsr(63+urnd_width downto urnd_width)<=lfsr(63 downto 0);
      for j in 0 to urnd_width-1 loop
        lfsr(urnd_width-j-1)<=lfsr(75-j) xor lfsr(74-j) xor lfsr(65-j) xor lfsr(64-j);
      end loop;
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if ctrl_rand="010" then
      urnd<=lfsr(urnd_width-1 downto 0);
    elsif ctrl_rand="001" or ctrl_rand="110" then
      urnd<=(others=>'0');
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if ctrl_rand="011" then
      binary_random<=unsigned(drnd);
    elsif ctrl_rand="001" or ctrl_rand="110" then
      binary_random<=(others=>'0');
    end if;
  end if;
end process;

end x;
