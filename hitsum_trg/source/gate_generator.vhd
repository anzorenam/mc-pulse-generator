library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gate_generator is
generic(gwidth: natural:= 20;
any: natural:=4);
port(gclk,grst: in std_logic;
trg_any: in unsigned (3 downto 0);
trg_gate: out std_logic);
end entity;

architecture x of gate_generator is
type state is (init,wait_trg,wait_timer,done);
signal presente,futuro: state;
signal gate,trg_sgnl: std_logic;
constant T0: natural:= gwidth-1;
signal timer: natural range 0 to T0;
begin

process(gclk)
begin
  if rising_edge(gclk) then
    if grst='1' then
      presente<=init;
    else
      presente<=futuro;
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if grst='1' then
      timer<=0;
    else
      if presente/=futuro then
        timer<=0;
      elsif timer/=T0 then
        timer<=timer+1;
      end if;
    end if;
  end if;
end process;

process(presente,trg_sgnl,timer)
begin
  gate<='0';
  case presente is
    when init=>
      futuro<=wait_trg;
    when wait_trg=>
      if trg_sgnl='1' then
        futuro<=wait_timer;
      else
        futuro<=wait_trg;
      end if;
    when wait_timer=>
      gate<='1';
      if timer>=T0 then
        futuro<=done;
      else
        futuro<=wait_timer;
      end if;
    when done=>
      futuro<=wait_trg;
  end case;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if grst='1' then
      trg_sgnl<='0';
    else
      if trg_any>=any then
        trg_sgnl<='1';
      else
        trg_sgnl<='0';
      end if;
    end if;
  end if;
end process;

trg_gate<=gate;

end x;
