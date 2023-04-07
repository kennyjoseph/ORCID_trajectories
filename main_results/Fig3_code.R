################
## FIGURE 3 ####
################

library(tidyverse)
library(ggplot2)

# set working directory -- USERS MUST EDIT
setwd("")

exit_df <- 
  tibble(
    group = c("men","men","men","men","men","men","men","men","men","men","men",
              "women","women","women","women","women","women","women","women","women","women","women"),
    at = c(-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5,
           -0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5),
    fit = c(0.1608528,
            0.1615254,
            0.1622003,
            0.1628775,
            0.1635569,
            0.1642386,
            0.1649226,
            0.1656088,
            0.1662974,
            0.1669882,
            0.1676814,
            0.1569906,
            0.1616121,
            0.1663428,
            0.1711837,
            0.1761357,
            0.1811996,
            0.1863762,
            0.1916661,
            0.1970697,
            0.2025876,
            0.2082198
    ),
    se = c(0.0010147,
           0.000912,
           0.0008202,
           0.0007438,
           0.0006886,
           0.0006605,
           0.0006637,
           0.0006983,
           0.0007607,
           0.0008451,
           0.0009462,
           0.001236,
           0.0011691,
           0.0011147,
           0.0010781,
           0.0010646,
           0.0010786,
           0.0011229,
           0.0011977,
           0.0013014,
           0.0014311,
           0.0015836
    )
  )

exit_df <- as.data.frame(exit_df)
exit_df$group <- as.factor(exit_df$group)
exit_df

exit_plot <- 
  ggplot(exit_df, aes(x = at, y = fit, group = group, color = group)) +
  geom_ribbon(aes(ymin = fit - se, ymax = fit + se, fill = group), alpha = .2) +
  geom_line(aes(color=group), size=0.25) +
  scale_y_continuous(
    breaks = seq(from = 0, to = 0.5, by = .10),
    limits = c(0, 0.5)
  ) +
  scale_x_continuous(
    breaks = seq(from = -0.5, to = 0.5, by = 0.5),
    labels = c("-1 SD","mean","+1 SD")
  ) +
  labs(x = "\nFAB of Current Field", y = "P(Exit)\n", group = "group", linetype = "group", fill = "group") +
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

exit_plot

ggsave("Fig3_exit_v01.pdf", plot = exit_plot, device="pdf", scale=1, width=7, height=6, dpi=300)

