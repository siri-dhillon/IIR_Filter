library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_audio_interface is
    port (
        fpga_clk : in std_logic;
        rst : in std_logic;
        b_clk: in std_logic;
        lr_clk: in std_logic;

        sdata_in: in std_logic;

        audio_valid_adau: in std_logic; 
        audio_r_adau: in std_logic_vector(23 downto 0); 
        audio_l_adau: in std_logic_vector(23 downto 0);

        sdata_out: out std_logic;
        
        audio_valid_pl: out std_logic; 
        audio_r_pl: out std_logic_vector(23 downto 0); 
        audio_l_pl: out std_logic_vector(23 downto 0)
        
    );
end i2s_audio_interface;

architecture rtl of i2s_audio_interface is
    -- FSM states
    type t_send_State is (send_0, send_1, send_2, send_3, send_4, send_5, send_6, send_7);
    signal send_State: t_send_State; 
    type t_rec_State is (rec_0, rec_1, rec_2, rec_3, rec_4, rec_5, rec_6, rec_7);
    signal rec_State: t_rec_State; 
    -- rising edge and falling edge detection signals
    signal bclk_rising_edge: std_logic :='0'; 
    signal bclk_falling_edge: std_logic:='0'; 
    signal lrclk_rising_edge: std_logic := '0'; 
    signal lrclk_falling_edge: std_logic := '0'; 

    -- signals for the syncronizer outputs
        -- these are the syncronized stable that will be used for our FSMs
    signal b_clk_sync_out : std_logic;
    signal lr_clk_sync_out : std_logic;
    signal sdata_in_sync_out : std_logic;

    --special signals i2s
    
    signal audio_r_pl_32: std_logic_vector(31 downto 0); 
    signal audio_l_pl_32: std_logic_vector(31 downto 0);

    signal audio_r_adau_32: std_logic_vector(31 downto 0):="00000000000000000000000000000000"; 
    signal audio_l_adau_32: std_logic_vector(31 downto 0):="00000000000000000000000000000000"; 

    -- signal s_data_sig: std_logic; 

    signal receive_counter: integer:=0;
    signal sending_counter: integer:=0;
    
begin

    -- port mapping syncronizer 

    PM_SYNCRONIZER : entity work.i2s_audio_syncronizer
    port map(
        fpga_clk => fpga_clk, 
        rst => rst, 
        b_clk => b_clk, 
        lr_clk => lr_clk, 
        sdata_in => sdata_in, 
        sdata_out => sdata_in_sync_out, 
        b_clk_out => b_clk_sync_out, 
        lr_clk_out=> lr_clk_sync_out, 
        bclk_is_rising_edge => bclk_rising_edge, 
        bclk_is_falling_edge => bclk_falling_edge, 
        lrclk_is_rising_edge => lrclk_rising_edge, 
        lrclk_is_falling_edge => lrclk_falling_edge
        );
    

    audio_r_adau_32(23 downto 0) <= audio_r_adau;
    audio_l_adau_32(23 downto 0) <= audio_l_adau;

    FSM_READ : process(fpga_clk)
    begin
        if rising_edge(fpga_clk) then
            if rst = '1' then
                rec_State <= rec_0;
                receive_counter <= 0;
    
            else
                case rec_State is
    
                    when rec_0 =>
                        if lrclk_falling_edge = '1' then
                            rec_State <= rec_1;
                        end if;

                    when rec_1 => 
                        audio_valid_pl <= '0';
                        if bclk_rising_edge = '1' then
                            rec_State <= rec_2;
                        end if;

                    when rec_2 =>

                        if receive_counter < 32 then 
                            if bclk_rising_edge = '1' then
                                audio_l_pl_32(31-receive_counter) <= sdata_in_sync_out;
                                receive_counter <= receive_counter + 1 ;
                            end if;
                            
                            
                            --rec_State <= rec_2;
                        else
                            rec_State <= rec_3;
                        end if;

                    when rec_3 =>
                         if lrclk_rising_edge='1' then
                            rec_State <= rec_4;
                         end if;


                    when rec_4 =>
                        if bclk_rising_edge = '1' then
                            rec_State <= rec_5;
                        end if;
                            
                    when rec_5 =>
                        if receive_counter < 64 then 
                            if (bclk_rising_edge = '1') then
                                audio_r_pl_32(63-receive_counter) <= sdata_in_sync_out;
                                receive_counter <= receive_counter + 1 ;
                            end if;
                            
                            --rec_State <= rec_5;
                        else 
                            
                            rec_State <= rec_6;
                        end if;


                    when rec_6 =>
                        if (bclk_rising_edge = '1') then
                            rec_State <= rec_7;
                        end if;

                    when rec_7 =>
                        audio_valid_pl <= '1';
                        audio_l_pl <= audio_l_pl_32(23 downto 0);
                        audio_r_pl <= audio_r_pl_32(23 downto 0);
                        receive_counter <= 0;
                        rec_State <= rec_0;
                        


                end case;
    
            end if;
        end if;
    end process;


    FSM_SEND : process(fpga_clk)
    begin
        if rising_edge(fpga_clk) then
            if rst = '1' then
                send_state <= send_0;
                sending_counter <= 0;
    
            else
                case send_state is
    
                    when send_0 =>
                        if lrclk_falling_edge = '1' then
                            send_state <= send_1;
                        end if;


                    when send_1 => 
                        if bclk_rising_edge = '1' then
                            send_state <= send_2;
                        end if;

                    when send_2 =>
                        if sending_counter < 24 then
                            if (bclk_falling_edge = '1') then
                                sdata_out <= audio_l_adau_32(23-sending_counter);
                                sending_counter <= sending_counter + 1;
                            end if;
                            --send_state <= send_2;
                        else 
                            send_state <= send_3;
                        end if;

                    when send_3 =>
                        if bclk_falling_edge = '1' then
                            send_state <= send_4;
                        end if;
                    when send_4 =>
                        if lrclk_rising_edge = '1' then
                            send_state <= send_5;
                        end if;
                    when send_5 =>
                        if bclk_rising_edge = '1' then
                            send_state <= send_6;
                        end if;

                    when send_6 =>
                        if  sending_counter < 48 then
                            if (bclk_rising_edge = '1') then
                                sdata_out <= audio_r_adau_32(47-sending_counter);
                                sending_counter <= sending_counter + 1;
                            end if;
                            --send_state <= send_6;
                        else
                            send_state <= send_7;
                        end if;
                    
                    when send_7 =>
                        sending_counter <= 0;
                        send_state <= send_0;

                end case;
    
            end if;
        end if;
    end process;


    
end architecture;