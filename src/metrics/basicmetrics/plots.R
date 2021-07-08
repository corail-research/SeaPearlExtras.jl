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
  
  n <- grep("^training$", names)
  if(n >= 0)
  {
    names <- names[-n]
    files <- files[-n]
  }

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
  
  n <- grep("^training$", names)
  file <- files[n]
  
  df <- read.csv(file)
  df$Heuristic <- "trained"
  df
}


plot.nodevisited.total <- function(folder)
{
  df <- initialize.dataframes.eval(folder)
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
  pl
}

plot.nodevisited.first <- function(folder)
{
  df <- initialize.dataframes.eval(folder)
  df$Heuristic[substr(df$Heuristic, 0, 6) == "random"] <- "random"
  df <- df %>%
    filter(Solution == 1) %>%
    group_by(Episode, Heuristic) %>%
    summarise( Median = median(Nodes), Up = quantile(Nodes, prob=.75), Down = quantile(Nodes, prob=.25))
  pl <- ggplot(data=df, aes(x=Episode, y=Median, colour=Heuristic)) + 
    geom_line() + 
    geom_ribbon(aes(ymin = Down, ymax = Up), alpha = 0.1) +
    xlab("Evaluation step") +
    ylab("Nodes visited") +
    ggtitle("Node visited until first solution") +
    scale_y_continuous(limits = function(l){c(0, l[2])})
  pl
}

plot.scorevariation <- function(folder)
{
  df <- initialize.dataframes.eval(folder)
  df$Heuristic[substr(df$Heuristic, 0, 6) == "random"] <- "random"
  n.episodes <- max(df$Episode)
  df <- df %>%
    filter(Solution > 0) %>%
    filter(Heuristic != "trained" | Episode == n.episodes)
  heuristics <- unique(df$Heuristic)
  for(h in heuristics){
    tmp <- df %>% filter(Heuristic == h)
    model <- nls(Score ~ 1 + exp(-gamma*(Nodes-tau)), start=c(gamma=0.01, tau = 0), data=tmp, control = nls.control(tol=1e-04, minFactor = 1e-04, warnOnly = TRUE))
    df$Pred[df$Heuristic == h] <- predict(model)
    
    fgh <- deriv(y ~ 1 + exp(-gamma*(x-tau)), c("gamma", "tau"), function(gamma,tau,x){})
    beta <- coef(model)
    f <- fgh(beta[1], beta[2], tmp$Nodes)
    g <- attr(f, "gradient")
    V.beta <- vcov(model)
    GS=rowSums((g%*%V.beta)*g)
    alpha <- 0.05
    deltaf <- sqrt(GS)*qt(1-alpha/2,summary(model)$df[2])
    df$Up[df$Heuristic == h] <- f+deltaf
    df$Down[df$Heuristic == h] <- f-deltaf
  }
  pl <- ggplot(data=df, aes(x=Nodes, y=Score, colour=Heuristic)) +
    geom_line(aes(y=Pred)) +
    geom_ribbon(aes(ymin = Down, ymax = Up), alpha=0.1) +
    xlab("Nodes visited") +
    ylab("Relative score") +
    ggtitle("Relative score variation during search")
  pl
}

plot.rewardvariation <- function(folder, binwidth = c(100, 0.02))
{
  df <- initialize.dataframes.training(folder)
  
  pl <- ggplot(data = df, aes(x = Episode, y = Reward)) +
    geom_hex(binwidth = c(100, 0.02)) +
    scale_fill_viridis_c() +
    geom_smooth(aes(color = "Local approximation")) +
    labs(
      x = "Training episode",
      y = "Nodes visited",
      color = "curves",
      title = "Reward evolution during training"
    )
  pl
}

plot.nodesvariation <- function(folder, binwidth = c(110, 1.1))
{
  df <- initialize.dataframes.training(folder)
  
  pl <- ggplot(data = df, aes(x = Episode, y = Nodes)) +
    geom_hex(binwidth = binwidth) +
    scale_fill_viridis_c() +
    geom_smooth(aes(color = "Local approximation")) +
    labs(
      x = "Training episode",
      y = "Nodes visited",
      color = "curves",
      title = "Nodes visited during training"
    )
  pl
}