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

# Look at the available pitchers:

pitchers = unique(data_reliable$pitcher)

# pitcher column contains the mlb id of the pitcher

# Take Tyler Glasnow as an example

Glasnow_data = data_reliable %>% filter(pitcher == 607192)

# Look at his available pitch types:

unique(Glasnow_data$pitch_type)

# Look at which pitch_ids of each type were reliably measured

unique(filter(Glasnow_data,pitch_type=="FF")$pitch_id)
unique(filter(Glasnow_data,pitch_type=="CU")$pitch_id)
unique(filter(Glasnow_data,pitch_type=="SL")$pitch_id)

# Three of each

# Make a plot of his right hand height through the pitching motion of his Fastball:

ggplot(filter(Glasnow_data,pitch_type=="FF"),aes(x = normalised_frame,y = 720 - V32,color = factor(pitch_id)))+
  geom_line()+
  xlim(-25,60)+
  labs(color = "Pitch id")+
  xlab("Frame Number (60fps)")+
  ylab("Right Hand Height /pixels")+
  geom_vline(xintercept = 0)+
  theme_minimal()+
  theme(text = element_text(size = 15))

# What about across the different pitch types? Are they all the same motion?

ggplot(Glasnow_data,aes(x = normalised_frame,y = 720 - V32,color = factor(pitch_type),fill = factor(pitch_id)))+
  geom_line()+
  xlim(-25,60)+
  labs(color = "Pitch Type")+
  xlab("Frame Number (60fps)")+
  ylab("Right Hand Height /pixels")+
  geom_vline(xintercept = 0)+
  theme_minimal()+
  theme(text = element_text(size = 15))


# Plot the position of Glasnow's body at frame 0 for a single pitch

plot_body = function(plot_data,animate = FALSE){
  fig = ggplot(plot_data,aes(x=V1,y=720-V2))+
    geom_point(color = "black",size=10)+
    geom_point(aes(x=V4,y=720-V5),color="pink",size=10)+ # head points
    geom_point(aes(x=V7,y=720-V8),color="red",size=10)+ # head points
    geom_point(aes(x=V10,y=720-V11),color="blue",size=10)+ # head points
    geom_point(aes(x=V13,y=720-V14),color="brown",size=10)+ # head points
    geom_point(aes(x=V16,y=720-V17),color="orange",size=10)+# left shoulder
    geom_point(aes(x=V19,y=720-V20),color="yellow",size=10)+ # right shoulder
    geom_point(aes(x=V22,y=720-V23),color="green",size=10)+ # left elbow
    geom_point(aes(x=V25,y=720-V26),color="lightgreen",size=10)+ # right elbow
    geom_point(aes(x=V28,y=720-V29),color="pink",size=10)+ # left hand
    geom_point(aes(x=V31,y=720-V32),color="red",size=10)+ # right hand
    geom_point(aes(x=V34,y=720-V35),color="blue",size=10)+ # left hip
    geom_point(aes(x=V37,y=720-V38),color="brown",size=10)+ # right hip
    geom_point(aes(x=V40,y=720-V41),color="orange",size=10)+ # left knee
    geom_point(aes(x=V43,y=720-V44),color="yellow",size=10)+ # right knee
    geom_point(aes(x=V46,y=720-V47),color="darkgreen",size=10)+ # left foot
    geom_point(aes(x=V49,y=720-V50),color="lightgreen",size=10)+ # right foot
    coord_fixed()+
    geom_segment(aes(x=V16,y=720-V17,xend=V19,yend=720-V20),color="black",size=2)+ # body shoulder
    geom_segment(aes(x=V34,y=720-V35,xend=V37,yend=720-V38),color="black",size=2)+ # body waist
    geom_segment(aes(x=V34,y=720-V35,xend=V16,yend=720-V17),color="black",size=2)+ # body left
    geom_segment(aes(x=V37,y=720-V38,xend=V19,yend=720-V20),color="black",size=2)+ # body right
    geom_segment(aes(x=V16,y=720-V17,xend=V22,yend=720-V23),color="black",size=2)+ # left arm up
    geom_segment(aes(x=V28,y=720-V29,xend=V22,yend=720-V23),color="black",size=2)+ # left arm low
    geom_segment(aes(x=V19,y=720-V20,xend=V25,yend=720-V26),color="black",size=2)+ # right arm up
    geom_segment(aes(x=V31,y=720-V32,xend=V25,yend=720-V26),color="black",size=2)+ # right arm low
    geom_segment(aes(x=V34,y=720-V35,xend=V40,yend=720-V41),color="black",size=2)+ # left leg up
    geom_segment(aes(x=V46,y=720-V47,xend=V40,yend=720-V41),color="black",size=2)+ # left leg low
    geom_segment(aes(x=V37,y=720-V38,xend=V43,yend=720-V44),color="black",size=2)+ # right leg up
    geom_segment(aes(x=V49,y=720-V50,xend=V43,yend=720-V44),color="black",size=2)+ # right leg low
    xlab("")+ylab("")+theme_minimal()
  
  if(animate){fig = fig+transition_states(normalised_frame)}
  return(fig)
}

plot_body(filter(Glasnow_data,pitch_id==2,pitch_type=="FF",normalised_frame==0))
plot_body(filter(Glasnow_data,pitch_id==3,pitch_type=="FF",normalised_frame==0))
plot_body(filter(Glasnow_data,pitch_id==4,pitch_type=="FF",normalised_frame==0))

# And why not animate it! Takes a minute or two to render
require(gganimate)

fig = plot_body(filter(Glasnow_data,pitch_id==2,pitch_type=="FF"),animate = TRUE)
animate(fig,fps = 60,nframes = dim(filter(Glasnow_data,pitch_id==2,pitch_type=="FF"))[1])


# And it's possible to overlay multiple pitches:
fig = plot_body(filter(Glasnow_data,pitch_type=="FF",normalised_frame >=-45,normalised_frame <=100),animate = TRUE)
animate(fig,fps = 60,nframes = 146)

# This should give you an idea of how to explore this data, let me know if you find anything interesting!

