library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity slow_sampler is
port (gclk,local_rst,make_delay: in std_logic;
ctrl_rand: in std_logic_vector (3 downto 0);
w_pattern: in std_logic_vector (23 downto 0);
wmask0: in std_logic_vector (7 downto 0);
pulse_out: out std_logic);
end entity;

architecture x of slow_sampler is
signal Tsync,c_pat2,capture: std_logic;
signal wp0,wp1,c_pat1,c_pat0: std_logic_vector (7 downto 0);
signal wmask1,wp2: unsigned (7 downto 0);
signal delay: std_logic_vector (1 downto 0);

begin

process(gclk)
begin
  if rising_edge(gclk) then
    if local_rst='1' then
      wmask1<="00000001";
    else
      if make_delay='1' then
        wmask1<=wmask1-1;
      else
        if ctrl_rand="0111" then
          wmask1<=wp2;
        end if;
      end if;
    end if;
  end if;
end process;

process(Tsync,local_rst)
begin
  if local_rst='1' then
    capture<='0';
  else
    if rising_edge(Tsync) then
      capture<='1';
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if local_rst='1' then
      delay<="00";
    else
      delay(0)<=capture;
      delay(1)<=delay(0);
    end if;
  end if;
end process;

c_pat2<='1' when (local_rst='0' and make_delay='1' and wmask1="0000000") else
              '0';

c_pat1<=wp1 and wmask0 when (local_rst='0' and make_delay='1') else
              (others=>'0');

c_pat0<=wp0 and wmask0 when (local_rst='0' and make_delay='1') else
              (others=>'0');

Tsync<='0' when (local_rst='1') else
             '0' when (make_delay='0') else
             '1' when (c_pat2='1' and (c_pat1/="00000000" or c_pat0/="00000000")) else
             '0';

pulse_out<=capture and not(delay(1));
wp2<=unsigned(w_pattern(23 downto 16));
wp1<=w_pattern(15 downto 8);
wp0<=w_pattern(7 downto 0);

end x;
