# An example R script for using my pitcher motion data

# Any questions contact me on Twitter @Pitching_Bot

# First read in packages
require(dplyr)
require(ggplot2)

# Read in the data, could take up to a minute

data = read.csv("Pitcher_Motion_Data.csv")

# Have a look at the column names

colnames(data)

# Filter to only take the reliable data

# No missing frames means that the pitcher has been continuously captured through
# the pitching motion

# Smooth_CoM_flag means that the pitcher's torso position doesn't vary by more than
# 100 pixels between successive frames. Ensures no bad matches to players other than
# the pitcher

data_reliable = data %>% filter(no_missing_frames==1, smooth_CoM_flag==1)



data_statcast = read.csv("Pitcher_Motion_Data_Statcast_Companion.csv")


###################
# Plot of pitcher arm slots

pitcher_arm_slots_R = data_statcast %>% filter(p_throws=="R")
pitcher_arm_slots_R = unique(pitcher_arm_slots_R$pitcher)
data_R_arm_slot = data_reliable %>% filter(pitcher %in% pitcher_arm_slots_R) %>% 
  filter(normalised_frame <=120) %>% group_by(pitcher,pitch_type,pitch_id) %>% mutate(max_arm_slot_frame = normalised_frame[which.max(V31)]) %>% 
  ungroup()
hist(data_R_arm_slot$max_arm_slot_frame)

data_R_arm_slot = data_R_arm_slot %>% filter(max_arm_slot_frame >=20, max_arm_slot_frame <= 100)

# Get average arm shape at max hand width by pitcher

arm_slot_by_pitcher = data_R_arm_slot %>% filter(normalised_frame==max_arm_slot_frame) %>%
  select(pitcher,V19,V20,V25,V26,V31,V32,PLAYERNAME) %>% group_by(PLAYERNAME) %>% 
  summarise(V19 = mean(V19),
            V20 = mean(V20),
            V25 = mean(V25),
            V26 = mean(V26),
            V31 = mean(V31),
            V32 = mean(V32))


# Repeat for left handers

pitcher_arm_slots_L = data_statcast %>% filter(p_throws=="L")
pitcher_arm_slots_L = unique(pitcher_arm_slots_L$pitcher)
data_L_arm_slot = data_reliable %>% filter(pitcher %in% pitcher_arm_slots_L) %>% 
  filter(normalised_frame <=120) %>% group_by(pitcher,pitch_type,pitch_id) %>% mutate(max_arm_slot_frame = normalised_frame[which.min(V28)]) %>% 
  ungroup()
hist(data_L_arm_slot$max_arm_slot_frame)

data_L_arm_slot = data_L_arm_slot %>% filter(max_arm_slot_frame >=20, max_arm_slot_frame <= 100)

# Get average arm shape at max arm slot by pitcher

arm_slot_by_pitcher2 = data_L_arm_slot %>% filter(normalised_frame==max_arm_slot_frame) %>%
  select(pitcher,V16,V17,V22,V23,V28,V29,PLAYERNAME) %>% group_by(PLAYERNAME) %>% 
  summarise(V19 = mean(V16),
            V20 = mean(V17),
            V25 = mean(V22),
            V26 = mean(V23),
            V31 = mean(V28),
            V32 = mean(V29))

arm_slot_by_pitcher = bind_rows(mutate(arm_slot_by_pitcher,p_throws="R"),mutate(arm_slot_by_pitcher2,p_throws="L"))

require(ggrepel)

# Didn't work for Kikuchi, picked up his set position instead
# for him do a quick max hand height instead of horizontal position

data_L_arm_slot = data_reliable %>% filter(PLAYERNAME=="Yusei Kikuchi") %>% 
  filter(normalised_frame <=120) %>% group_by(pitcher,pitch_type,pitch_id) %>% mutate(max_arm_slot_frame = normalised_frame[which.min(V29)]) %>% 
  ungroup()
hist(data_L_arm_slot$max_arm_slot_frame)

data_L_arm_slot = data_L_arm_slot %>% filter(max_arm_slot_frame >=20, max_arm_slot_frame <= 100)

# Get average arm shape at max arm slot by pitcher

arm_slot_by_pitcher2 = data_L_arm_slot %>% filter(normalised_frame==max_arm_slot_frame) %>%
  select(pitcher,V16,V17,V22,V23,V28,V29,PLAYERNAME) %>% group_by(PLAYERNAME) %>% 
  summarise(V19 = mean(V16),
            V20 = mean(V17),
            V25 = mean(V22),
            V26 = mean(V23),
            V31 = mean(V28),
            V32 = mean(V29))

arm_slot_by_pitcher = bind_rows(filter(arm_slot_by_pitcher,PLAYERNAME!="Yusei Kikuchi"),mutate(arm_slot_by_pitcher2,p_throws="L"))





pixel_foot_factor = 37**-1 # Guessed roughly from player heights may be around 10% off

ggplot(arm_slot_by_pitcher,aes(x = pixel_foot_factor*(V19-V19),y=pixel_foot_factor*(V20 - V20),color = factor(PLAYERNAME)))+
  geom_point(show.legend = FALSE)+
  geom_point(aes(x = pixel_foot_factor*(V25-V19),y=pixel_foot_factor*(V20 - V26)),show.legend = FALSE)+
  geom_point(aes(x = pixel_foot_factor*(V31-V19),y=pixel_foot_factor*(V20 - V32)),show.legend = FALSE)+
  geom_segment(aes(x = pixel_foot_factor*(V25-V19),y=pixel_foot_factor*(V20 - V26),xend=pixel_foot_factor*(V19-V19),yend=pixel_foot_factor*(V20 - V20)),show.legend = FALSE)+
  geom_segment(aes(x = pixel_foot_factor*(V25-V19),y=pixel_foot_factor*(V20 - V26),xend=pixel_foot_factor*(V31-V19),yend=pixel_foot_factor*(V20 - V32)),show.legend = FALSE)+
  coord_fixed()+
  geom_label_repel(aes(x=pixel_foot_factor*(V31-V19),y=pixel_foot_factor*(V20-V32),label = PLAYERNAME),show.legend = FALSE,max.overlaps = 50)+
  theme_minimal()+
  xlab("Horizontal Position of Hand relative to Shoulder [Feet]")+
  ylab("Vertical Position of Hand relative to Shoulder [Feet]")+
  theme(text = element_text(size = 15))




##########################
##########################
##########################
##########################

# Animation of a few specific arm slots

# Robbie Ray, Chris Sale, Tyler Glasnow, Sandy Alcantara



pitcher_arm_slots_R = data_statcast %>% filter(p_throws=="R")
pitcher_arm_slots_R = unique(pitcher_arm_slots_R$pitcher)
data_R_arm_slot = data_reliable %>% filter(PLAYERNAME %in% c("Tyler Glasnow","Sandy Alcantara")) %>% 
  filter(normalised_frame <=120) %>% group_by(pitcher,pitch_type,pitch_id) %>% mutate(max_arm_slot_frame = normalised_frame[which.max(V31)]) %>% 
  ungroup()
hist(data_R_arm_slot$max_arm_slot_frame)

data_R_arm_slot = data_R_arm_slot %>% filter(max_arm_slot_frame >=40, max_arm_slot_frame <= 100)

# Get average arm shape at max hand width by pitcher

arm_slot_by_pitcher = data_R_arm_slot %>% mutate(normalised_frame= normalised_frame - max_arm_slot_frame) %>%
  filter(normalised_frame >=-30,normalised_frame <=30) %>% 
  select(pitcher,V19,V20,V25,V26,V31,V32,PLAYERNAME,normalised_frame) %>% group_by(PLAYERNAME,normalised_frame) %>% 
  summarise(V19 = mean(V19),
            V20 = mean(V20),
            V25 = mean(V25),
            V26 = mean(V26),
            V31 = mean(V31),
            V32 = mean(V32),
            .groups="drop")


pitcher_arm_slots_L = data_statcast %>% filter(p_throws=="L")
pitcher_arm_slots_L = unique(pitcher_arm_slots_L$pitcher)
data_L_arm_slot = data_reliable %>% filter(PLAYERNAME %in% c("Robbie Ray","Chris Sale")) %>% 
  filter(normalised_frame <=120) %>% group_by(pitcher,pitch_type,pitch_id) %>% mutate(max_arm_slot_frame = normalised_frame[which.min(V28)]) %>% 
  ungroup()
hist(data_L_arm_slot$max_arm_slot_frame)

data_L_arm_slot = data_L_arm_slot %>% filter(max_arm_slot_frame >=40, max_arm_slot_frame <= 100)

# Get average arm shape at max arm slot by pitcher

arm_slot_by_pitcher2 = data_L_arm_slot %>% mutate(normalised_frame= normalised_frame - max_arm_slot_frame) %>%
  filter(normalised_frame >=-30,normalised_frame <=30) %>% 
  select(pitcher,V16,V17,V22,V23,V28,V29,PLAYERNAME,normalised_frame) %>% group_by(PLAYERNAME,normalised_frame) %>% 
  summarise(V19 = mean(V16),
            V20 = mean(V17),
            V25 = mean(V22),
            V26 = mean(V23),
            V31 = mean(V28),
            V32 = mean(V29),
            .groups="drop")

arm_slot_by_pitcher = bind_rows(mutate(arm_slot_by_pitcher,p_throws="R"),mutate(arm_slot_by_pitcher2,p_throws="L"))

library(gganimate)
fig = ggplot(filter(arm_slot_by_pitcher,normalised_frame>=-6,normalised_frame<=2),aes(x = pixel_foot_factor*(V19-V19),y=pixel_foot_factor*(V20 - V20),color = factor(PLAYERNAME)))+
  geom_point(size=6)+
  geom_point(aes(x = pixel_foot_factor*(V25-V19),y=pixel_foot_factor*(V20 - V26)),show.legend = FALSE,size=6)+
  geom_point(aes(x = pixel_foot_factor*(V31-V19),y=pixel_foot_factor*(V20 - V32)),show.legend = FALSE,size=6)+
  geom_segment(aes(x = pixel_foot_factor*(V25-V19),y=pixel_foot_factor*(V20 - V26),xend=pixel_foot_factor*(V19-V19),yend=pixel_foot_factor*(V20 - V20)),show.legend = FALSE,size=4)+
  geom_segment(aes(x = pixel_foot_factor*(V25-V19),y=pixel_foot_factor*(V20 - V26),xend=pixel_foot_factor*(V31-V19),yend=pixel_foot_factor*(V20 - V32)),show.legend = FALSE,size=4)+
  coord_fixed()+
  theme_minimal()+
  xlab("Horizontal Position /ft")+
  ylab("Vertical Position /ft")+
  theme(text = element_text(size = 15))+
  transition_states(normalised_frame,transition_length=10,state_length = 0,wrap = FALSE)+
  ease_aes('linear')+
  labs(color = "Pitcher")

anim = animate(fig,fps=50,nframes = 90*2 + 200,start_pause = 100,end_pause = 100)
anim_save("arm_slot_gif_3.gif",anim)

