library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity event_scaler is
generic(daqtime: unsigned (31 downto 0):= to_unsigned(1000000000,32));
port(gclk,grst: in std_logic;
init_done,tcp_open: in std_logic;
t_valid,e_valid: in std_logic;
wout: out std_logic;
scaler0,scaler1: out unsigned (15 downto 0));
end entity;

architecture x of event_scaler is
signal rst_reg,rst_scaler,hab_reg,hab_scaler: std_logic;
signal count0,count1,sreg0,sreg1: unsigned (15 downto 0);
type state is (s0,wait_open,wait_timer,copy,reset,w_fifo,u0,u1);
signal presente,futuro: state;
constant T0: unsigned (31 downto 0):= daqtime-1;
signal timer: unsigned (31 downto 0);
begin

process(gclk)
begin
  if rising_edge(gclk) then
    if grst='1' then
      presente<=s0;
    else
      presente<=futuro;
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if grst='1' then
      timer<=(others=>'0');
    else
      if presente/=futuro then
        timer<=(others=>'0');
      elsif timer/=T0 then
        timer<=timer+1;
      end if;
    end if;
  end if;
end process;

process(presente,tcp_open,init_done,timer)
begin
  hab_reg<='0';
  hab_scaler<='0';
  rst_reg<='0';
  rst_scaler<='0';
  wout<='0';
  case presente is
    when s0=>
      rst_reg<='1';
      rst_scaler<='1';
      if init_done='1' then
        futuro<=wait_open;
      else
        futuro<=s0;
      end if;
    when wait_open=>
      if tcp_open='0' then
        futuro<=wait_timer;
      else
        futuro<=wait_open;
      end if;
    when wait_timer=>
      hab_scaler<='1';
      if timer>=T0 then
        futuro<=copy;
      else
        futuro<=wait_timer;
      end if;
    when copy=>
      hab_reg<='1';
      futuro<=reset;
    when reset=>
      rst_scaler<='1';
      futuro<=w_fifo;
    when w_fifo=>
      wout<='1';
      futuro<=wait_open;
    when others=>
      futuro<=s0;
  end case;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if rst_scaler='1' then
      count0<="0000000000000000";
    else
      if hab_scaler='1' then
        if e_valid='1' then
          count0<=count0+1;
        end if;
      end if;
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if rst_scaler='1' then
      count1<="0000000000000000";
    else
      if hab_scaler='1' then
        if t_valid='1' then
          count1<=count1+1;
        end if;
      end if;
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if rst_reg='1' then
      sreg0<="0000000000000000";
      sreg1<="0000000000000000";
    else
      if hab_reg='1' then
        sreg0<=count0;
        sreg1<=count1;
      end if;
    end if;
  end if;
end process;

scaler0<=sreg0;
scaler1<=sreg1;

end x;
