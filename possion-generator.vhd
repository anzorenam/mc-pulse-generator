library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity event_generator is
port(gclk,rst: in std_logic;
make_event: out std_logic);
end entity;
architecture x of event_generator is
signal lfsr: unsigned(95 downto 0);
signal urdn: unsigned(31 downto 0);
begin

process(gclk,rst)
begin
  if rst='1' then
    lfsr<=(5=>'1',others=>'0');
  else
    if rising_edge(gclk) then
      lfsr(95 downto 32)<=lfsr(63 downto 0);
      for j in 0 to 31 loop
        lfsr(31-j)<=lfsr(95-j) xor lfsr(93-j) xor lfsr(48-j) xor lfsr(46-j);
      end loop;
    end if;
  end if;
end process;

process(gclk,rst)
begin
  if rst='1' then
    make_event<='0';
  else
    if rising_edge(gclk) then
      if urdn<="00000000010000011000100100110111" then
        make_event<='1';
      else
        make_event<='0';
      end if;
    end if;
  end if;
end process;

urdn<=lfsr(31 downto 0);

end x;
