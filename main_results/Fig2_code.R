################
## FIGURE 2 ####
################

library(tidyverse)
library(ggplot2)

# set working directory -- USERS MUST EDIT
setwd("")

enter_df <- 
  tibble(
    group = c("men","men","men","men","men","men","men","men","men","men","men",
          "women","women","women","women","women","women","women","women","women","women","women"),
    at = c(-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5,
           -0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5),
    fit = c(0.4861124,
            0.4887437,
            0.4913757,
            0.4940081,
            0.4966409,
            0.4992738,
            0.5019068,
            0.5045397,
            0.5071724,
            0.5098046,
            0.5124363,
            0.6094184,
            0.5880963,
            0.5664383,
            0.5445235,
            0.5224349,
            0.5002582,
            0.4780805,
            0.4559889,
            0.4340691,
            0.4124042,
            0.3910734
    ),
    se = c(0.0012856,
           0.0010292,
           0.0007727,
           0.0005161,
           0.0002593,
           0.0000063,
           0.0002544,
           0.0005111,
           0.0007678,
           0.0010244,
           0.0012808,
           0.0019227,
           0.0015654,
           0.0011903,
           0.0008014,
           0.0004033,
           0.0000168,
           0.0004037,
           0.0008019,
           0.0011909,
           0.0015663,
           0.0019239
    )
  )

enter_df <- as.data.frame(enter_df)
enter_df$group <- as.factor(enter_df$group)
enter_df

enter_plot <- 
  ggplot(enter_df, aes(x = at, y = fit, group = group, color = group)) +
  geom_ribbon(aes(ymin = fit - se, ymax = fit + se, fill = group), alpha = .2) +
  geom_line(aes(color=group), size=0.25) +
  scale_y_continuous(
    breaks = seq(from = 0.25, to = 0.75, by = .10),
    limits = c(0.25, 0.75)
    ) +
  scale_x_continuous(
    breaks = seq(from = -0.5, to = 0.5, by = 0.5),
    labels = c("-1 SD","mean","+1 SD")
    ) +
  labs(x = "\nFAB of Field Being Entered", y = "P(Enter)\n", group = "group", linetype = "group", fill = "group") +
  scale_color_manual(values = c("dodgerblue", "red")) +
  scale_fill_manual(values = c("dodgerblue", "red")) +
  theme_classic() +
  theme(panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      axis.title=element_text(size=20),
      axis.text=element_text(size=18,colour="black"),
      axis.line=element_line(colour="black"),
      panel.background = element_rect(fill = 'white'),
      strip.text.x = element_text(size = 18, colour = "black"),
      legend.text=element_text(size=18),
      legend.title=element_blank(),
      legend.position = c(0.9, 0.9)) 

enter_plot 

ggsave("Fig2_enter_v01.pdf", plot = enter_plot, device="pdf", scale=1, width=7, height=6, dpi=300)

