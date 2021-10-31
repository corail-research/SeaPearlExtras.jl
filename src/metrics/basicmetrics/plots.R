require(ggplot2)
require(dplyr)
require(tidyr)

initialize.dataframes.eval <- function(folder)
{
  files <- list.files(folder, pattern = "*.csv$")
  m <- regexpr("[A-Za-z0-9]*\\.csv$", files)
  m <- regmatches(files, m)
  names <- substr(m, 0, nchar(m) - 4)
  files <- paste(folder, files, sep="")
  
  idx.training <- grep("training[_[A-Za-z0-9]*]*\\.csv", files)
  names <- names[- idx.training]
  files <- files[- idx.training]

  df <- read.csv(files[1])
  df$Heuristic <- names[1]
  
  for(i in 2:length(files))
  {
    tmp <- read.csv(files[i])
    tmp$Heuristic <- names[i]
    df <- rbind(df, tmp)
  }
  df
}

initialize.dataframes.training <- function(folder)
{
  files <- list.files(folder, pattern = "*.csv$")
  m <- regexpr("[A-Za-z0-9]*\\.csv$", files)
  m <- regmatches(files, m)
  names <- substr(m, 0, nchar(m) - 4)
  files <- paste(folder, files, sep="")
  
  idx.training <- grep("training[_[A-Za-z0-9]*]*\\.csv", files)
  names <- names[idx.training]
  files <- files[idx.training]
  
  df <- read.csv(files[1])
  df$Heuristic <- names[1]

  if(length(files) > 1)
  {
    for(i in 2:length(files))
    {
      print(i)
      tmp <- read.csv(files[i])
      tmp$Heuristic <- names[i]
      df <- rbind(df, tmp)
    }
  }
  df
}

plot.node.total <- function(df)
{
  df$Heuristic[substr(df$Heuristic, 0, 6) == "random"] <- "random"
  df <- df %>%
    filter(Solution == 0) %>%
    group_by(Episode, Heuristic) %>%
    summarise( Median = median(Nodes), Up = quantile(Nodes, prob=.75), Down = quantile(Nodes, prob=.25))
  pl <- ggplot(data=df, aes(x=Episode, y=Median, colour=Heuristic)) + 
    geom_line() + 
    geom_ribbon(aes(ymin = Down, ymax = Up), alpha = 0.1) +
    xlab("Evaluation step") +
    ylab("Nodes visited") +
    ggtitle("Node visited until optimality") +
    scale_y_continuous(limits = function(l){c(0, l[2])})
  show(pl)
  return(pl)
}

plot.node.first <- function(df)
{
  df$Heuristic[substr(df$Heuristic, 0, 6) == "random"] <- "random"
  df <- df %>%
    filter(Solution > 0 & !is.na(Score)) %>%
    group_by(Episode, Heuristic, Instance) %>%
    slice_min(Solution, n=1, with_ties = FALSE) %>%
    ungroup() %>%
    group_by(Episode, Heuristic) %>%
    summarise( Median = median(Nodes), Up = quantile(Nodes, prob=.75), Down = quantile(Nodes, prob=.25))
  pl <- ggplot(data=df, aes(x=Episode, y=Median, colour=Heuristic)) + 
    geom_line() + 
    geom_ribbon(aes(ymin = Down, ymax = Up), alpha = 0.1) +
    xlab("Evaluation step") +
    ylab("Nodes visited") +
    ggtitle("Node visited until first solution") +
    scale_y_continuous(limits = function(l){c(0, l[2])})
  show(pl)
  return(pl)
}

plot.score.first <- function(df, normalize=TRUE)
{
  df$Heuristic[substr(df$Heuristic, 0, 6) == "random"] <- "random"
  if(normalize)
  {
    df <- df %>%
      group_by(Instance) %>%
      mutate(Score = Score/min(Score, na.rm=TRUE))
  }
  df <- df %>%
    filter(Solution > 0 & !is.na(Score)) %>%
    group_by(Episode, Heuristic, Instance) %>%
    slice_min(Solution, n=1, with_ties = FALSE) %>%
    ungroup() %>%
    group_by(Episode, Heuristic) %>%
    summarise( Median = median(Score), Up = quantile(Score, prob=.75), Down = quantile(Score, prob=.25))
  pl <- ggplot(data=df, aes(x=Episode, y=Median, colour=Heuristic)) + 
    geom_line() + 
    geom_ribbon(aes(ymin = Down, ymax = Up), alpha = 0.1) +
    xlab("Evaluation step") +
    ylab("Score obtained") +
    ggtitle("Score distribution at first solution")
  
  show(pl)
  return(pl)
}

plot.time.total <- function(df)
{
  df$Heuristic[substr(df$Heuristic, 0, 6) == "random"] <- "random"
  df <- df %>%
    filter(Solution == 0) %>%
    group_by(Episode, Heuristic) %>%
    summarise( Median = median(Time), Up = quantile(Time, prob=.75), Down = quantile(Time, prob=.25))
  pl <- ggplot(data=df, aes(x=Episode, y=Median, colour=Heuristic)) + 
    geom_line() + 
    geom_ribbon(aes(ymin = Down, ymax = Up), alpha = 0.1) +
    xlab("Evaluation step") +
    ylab("Time needed") +
    ggtitle("Time needed to prove optimatility") +
    scale_y_continuous(limits = function(l){c(0, l[2])})
  show(pl)
  return(pl)
}

plot.area.variation <- function(df, binwidth = c(100, 1), normalize=TRUE)
{
  if(normalize)
  {
    df <- df %>%
      group_by(Instance) %>%
      mutate(Score = Score/min(Score, na.rm=TRUE))
  }
  n.episodes <- max(df$Episode)
  df <- df %>% 
    drop_na(Score) %>% 
    group_by(Heuristic, Episode, Instance) %>% 
    mutate(diff.area = ifelse( Nodes == min(Nodes), Nodes*Score, (Nodes - lag(Nodes)) * Score))
  df$Heuristic[substr(df$Heuristic, 0, 6) == "random"] <- "random"
  df <- df %>%
    ungroup() %>%
    group_by(Heuristic, Episode) %>%
    summarise( Median = median(diff.area), Up = quantile(diff.area, prob=.75), Down = quantile(diff.area, prob=.25))
  
  pl <- ggplot(data=df, aes(x=Episode, y=Median, colour=Heuristic)) +
    geom_line() + 
    geom_ribbon(aes(ymin = Down, ymax = Up), alpha = 0.1) +
    labs(
      x = "Training episode",
      y = "Area under the objective curve",
      color = "curves",
      title = "Area under the objective curve during training"
    ) +
    scale_y_continuous(limits = function(l){c(0, l[2])})
  show(pl)
  return(pl)
}

plot.reward.variation <- function(df)
{
  pl <- ggplot(data = df, aes(x = Episode, y = Reward)) +
    geom_hex() +
    scale_fill_viridis_c() +
    geom_smooth(aes(color = "Local approximation")) +
    labs(
      x = "Training episode",
      y = "Reward obtained",
      color = "curves",
      title = "Reward evolution during training"
    )
  show(pl)
  return(pl)
}

plot.node.variation <- function(df)
{
  pl <- ggplot(data = df, aes(x = Episode, y = Nodes)) +
    geom_hex() +
    scale_fill_viridis_c() +
    geom_smooth(aes(color = "Local approximation")) +
    labs(
      x = "Training episode",
      y = "Nodes visited",
      color = "curves",
      title = "Nodes visited during training"
    )
  show(pl)
  return(pl)
}

plot.all <- function(path)
{
  train <- initialize.dataframes.training(path)
  eval <- initialize.dataframes.eval(path)
  plot.node.total(eval)
  ggsave(paste(path,"eval_total_nodes.png"))
  plot.node.first(eval)
  ggsave(paste(path,"eval_first_nodes.png"))
  plot.time.total(eval)
  ggsave(paste(path,"eval_total_time.png"))
  plot.score.first(eval)
  ggsave(paste(path,"eval_first_score.png"))
  plot.area.variation(eval)
  ggsave(paste(path,"eval_area.png"))
  plot.reward.variation(train)
  ggsave(paste(path,"train_reward.png"))
  plot.node.variation(train)
  ggsave(paste(path,"train_nodes.png"))
}
