library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main_control is
port(gclk,srst_done,init_done: in std_logic;
write_ack,busy,tcp_rx: in std_logic;
mode: in std_logic_vector (7 downto 0);
seed: in unsigned (7 downto 0);
rate_mask: in unsigned (31 downto 0);
din_tcp: in std_logic_vector (7 downto 0);
s_flag,valid_event,delay_done,mux_sel: out std_logic;
wr_data_count: out std_logic_vector (11 downto 0);
hit_pattern: out std_logic_vector (15 downto 0));
end main_control;

architecture x of main_control is
signal hab_reg,event_flag,read_enable,empty: std_logic;
signal hab_count: std_logic_vector (1 downto 0);
signal dout,hit_reg: std_logic_vector (15 downto 0);
constant T0: natural:= 2;
constant T1: natural:= 150;
constant tmax: natural := T1-1;
signal timer: natural range 0 to tmax;

type state is (s0,wait_dram,sel_evt,wevt0,wevt1,read_evt0,read_evt1,start_evt,wait_sync,valid_evt,dead_time,done,u0,u1,u2,u3);
signal presente,futuro: state;

component fifosync is
port(clk,srst,wr_en,rd_en: in std_logic;
din: in std_logic_vector (7 downto 0);
full,empty: out std_logic;
wr_data_count: out std_logic_vector (11 downto 0);
dout: out std_logic_vector (15 downto 0));
end component;

component poisson_generator is
port(gclk,srst_done: in std_logic;
mode: in std_logic_vector (7 downto 0);
seed: in unsigned (7 downto 0);
hab_count: in std_logic_vector (1 downto 0);
rate_mask: in unsigned (31 downto 0);
event_flag: out std_logic);
end component;

begin

fifo_sync: fifosync
port map(clk=>gclk,
         srst=>srst_done,
         din=>din_tcp,
         wr_en=>tcp_rx,
         rd_en=>read_enable,
         dout=>dout,
         full=>open,
         empty=>empty,
         wr_data_count=>wr_data_count
);

poisson: poisson_generator
  port map(gclk=>gclk,
           srst_done=>srst_done,
           mode=>mode,
           seed=>seed,
           hab_count=>hab_count,
           rate_mask=>rate_mask,
           event_flag=>event_flag
);

process(gclk)
begin
  if rising_edge(gclk) then
    if srst_done='1' then
      presente<=s0;
    else
      presente<=futuro;
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if srst_done='1' then
      timer<=0;
    else
      if presente/=futuro then
        timer<=0;
      elsif timer/=tmax then
        timer<=timer+1;
      end if;
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if srst_done='1' then
      hit_reg<="0000000000000000";
    else
      if hab_reg='1' then
        hit_reg<=dout;
      end if;
    end if;
  end if;
end process;

process(presente,init_done,write_ack,mode,event_flag,empty,timer,busy,hit_reg)
begin
  mux_sel<='1';
  hab_count<="00";
  read_enable<='0';
  hab_reg<='0';
  hit_pattern<="0000000000000000";
  s_flag<='0';
  valid_event<='0';
  delay_done<='0';
  case presente is
    when s0=>
      mux_sel<='0';
      if init_done='1' then
        futuro<=wait_dram;
      else
        futuro<=s0;
      end if;
    when wait_dram=>
      mux_sel<='0';
      if write_ack='1' then
        futuro<=sel_evt;
      else
        futuro<=wait_dram;
      end if;
    when sel_evt=>
      if mode="10000111" then
        futuro<=wevt0;
      elsif mode="10010101" then
        futuro<=wevt1;
      else
        futuro<=sel_evt;
      end if;
    when wevt0=>
      hab_count<="01";
      if event_flag='1' then
        futuro<=read_evt0;
      else
        futuro<=wevt0;
      end if;
    when wevt1=>
      hab_count<="10";
      if event_flag='1' then
        futuro<=read_evt0;
      else
        futuro<=wevt1;
      end if;
    when read_evt0=>
      read_enable<='1';
      if empty='0' then
        futuro<=read_evt1;
      else
        futuro<=read_evt0;
      end if;
    when read_evt1=>
      hab_reg<='1';
      futuro<=start_evt;
    when start_evt=>
      hit_pattern<=hit_reg;
      s_flag<='1';
      if timer>=T0-1 then
        futuro<=wait_sync;
      else
        futuro<=start_evt;
      end if;
    when wait_sync=>
      hit_pattern<=hit_reg;
      if busy='0' then
        futuro<=valid_evt;
      else
        futuro<=wait_sync;
      end if;
    when valid_evt=>
      hit_pattern<=hit_reg;
      valid_event<='1';
      if timer>=T0-1 then
        futuro<=dead_time;
      else
        futuro<=valid_evt;
      end if;
    when dead_time=>
      hit_pattern<=hit_reg;
      if timer>=T1-1 then
        futuro<=done;
      else
        futuro<=dead_time;
      end if;
    when done=>
      delay_done<='1';
      futuro<=sel_evt;
    when others=>
      futuro<=s0;
  end case;
end process;

end x;
