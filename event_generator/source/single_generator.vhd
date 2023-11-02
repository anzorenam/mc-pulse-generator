library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_generator is
port(gclk,p0,p1,p2,p3: in std_logic;
srst_done,init_done,s_flag,valid_event: in std_logic;
delay_done,dram_ack: in std_logic;
seed: in unsigned (7 downto 0);
hit_pattern: in std_logic_vector (15 downto 0);
drnd: in unsigned (15 downto 0);
rd_en: out std_logic;
busy: out std_logic;
ctrl_rand: out std_logic_vector (3 downto 0);
din_rand: out unsigned (19 downto 0);
pulse_event: out std_logic_vector (15 downto 0));
end single_generator;

architecture x of single_generator is
signal make_delay: std_logic;
signal ctrl_signal: std_logic_vector (3 downto 0);
signal generator_sel,pulse_signal: std_logic_vector (15 downto 0);

type fix_seeds is array (15 downto 0) of unsigned (7 downto 0);
signal fsd: fix_seeds;
type urnd_address is array (15 downto 0) of unsigned (15 downto 0);
signal urnd_aux: urnd_address;
type binary_channels is array (15 downto 0) of unsigned (9 downto 0);
signal binary_aux: binary_channels;
type onehot_channels is array (15 downto 0) of std_logic_vector (23 downto 0);
signal onehot_aux: onehot_channels;

component control_generator is
port(gclk,srst_done,init_done: in std_logic;
s_flag,valid_event,delay_done,dram_ack: in std_logic;
hit_pattern: in std_logic_vector (15 downto 0);
urnd0,urnd1,urnd2,urnd3: in unsigned (15 downto 0);
urnd4,urnd5,urnd6,urnd7: in unsigned (15 downto 0);
urnd8,urnd9,urnda,urndb: in unsigned (15 downto 0);
urndc,urndd,urnde,urndf: in unsigned (15 downto 0);
din_rand: out unsigned (19 downto 0);
busy,make_delay,rd_en: out std_logic;
generator_sel: out std_logic_vector (15 downto 0);
ctrl_rand: out std_logic_vector (3 downto 0));
end component;

component density_generator is
port(gclk,gen_sel: in std_logic;
seed: in unsigned (7 downto 0);
ctrl_rand: in std_logic_vector (3 downto 0);
drnd: in unsigned (15 downto 0);
urnd: out unsigned (15 downto 0);
binary_rand: out unsigned (9 downto 0));
end component;

component bin_onehot is
port(gclk,gen_sel: in std_logic;
ctrl_rand: in std_logic_vector (3 downto 0);
binary: in unsigned (9 downto 0);
onehot: out std_logic_vector (23 downto 0));
end component;

component pulse_delay is
port (p0,p1,p2,p3: in std_logic;
make_delay: in std_logic;
ctrl_rand: in std_logic_vector (3 downto 0);
w_pat0,w_pat1,w_pat2,w_pat3: in std_logic_vector (23 downto 0);
w_pat4,w_pat5,w_pat6,w_pat7: in std_logic_vector (23 downto 0);
w_pat8,w_pat9,w_patA,w_patB: in std_logic_vector (23 downto 0);
w_patC,w_patD,w_patE,w_patF: in std_logic_vector (23 downto 0);
pulse_out: out std_logic_vector (15 downto 0));
end component;

begin

control: control_generator
  port map(gclk=>gclk,
           srst_done=>srst_done,
           init_done=>init_done,
           s_flag=>s_flag,
           valid_event=>valid_event,
           delay_done=>delay_done,
           dram_ack=>dram_ack,
           hit_pattern=>hit_pattern,
           urnd0=>urnd_aux(0),
           urnd1=>urnd_aux(1),
           urnd2=>urnd_aux(2),
           urnd3=>urnd_aux(3),
           urnd4=>urnd_aux(4),
           urnd5=>urnd_aux(5),
           urnd6=>urnd_aux(6),
           urnd7=>urnd_aux(7),
           urnd8=>urnd_aux(8),
           urnd9=>urnd_aux(9),
           urnda=>urnd_aux(10),
           urndb=>urnd_aux(11),
           urndc=>urnd_aux(12),
           urndd=>urnd_aux(13),
           urnde=>urnd_aux(14),
           urndf=>urnd_aux(15),
           din_rand=>din_rand,
           busy=>busy,
           make_delay=>make_delay,
           rd_en=>rd_en,
           generator_sel=>generator_sel,
           ctrl_rand=>ctrl_signal
);

gen_channels:
for j in 0 to 15 generate
  rand: density_generator
    port map(gclk=>gclk,
             gen_sel=>generator_sel(j),
             seed=>fsd(j),
             ctrl_rand=>ctrl_signal,
             drnd=>drnd,
             urnd=>urnd_aux(j),
             binary_rand=>binary_aux(j)
  );

  gen_deco: bin_onehot
    port map(gclk=>gclk,
             gen_sel=>generator_sel(j),
             ctrl_rand=>ctrl_signal,
             binary=>binary_aux(j),
             onehot=>onehot_aux(j)
  );

  gen_seeds:
  fsd(j)<=seed+7*j;

end generate;

gen_delay: pulse_delay
  port map(p0=>p0,
           p1=>p1,
           p2=>p2,
           p3=>p3,
           make_delay=>make_delay,
           ctrl_rand=>ctrl_signal,
           w_pat0=>onehot_aux(0),
           w_pat1=>onehot_aux(1),
           w_pat2=>onehot_aux(2),
           w_pat3=>onehot_aux(3),
           w_pat4=>onehot_aux(4),
           w_pat5=>onehot_aux(5),
           w_pat6=>onehot_aux(6),
           w_pat7=>onehot_aux(7),
           w_pat8=>onehot_aux(8),
           w_pat9=>onehot_aux(9),
           w_patA=>onehot_aux(10),
           w_patB=>onehot_aux(11),
           w_patC=>onehot_aux(12),
           w_patD=>onehot_aux(13),
           w_patE=>onehot_aux(14),
           w_patF=>onehot_aux(15),
           pulse_out=>pulse_signal
);

ctrl_rand<=ctrl_signal;
pulse_event<=pulse_signal;

end x;
