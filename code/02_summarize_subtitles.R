## Imports ----
library(tidyverse)
library(here)
library(tidytext)
data("stop_words")
source(here("code", "mk_nytimes.R"))

## Get and clean data ----
analytic_df <- readRDS(here("data", "analytic_data.RDS"))
film_dates <- analytic_df |>
    select(film, date, runtime) |>
    distinct() |>
    arrange(date) |>
    mutate(label = sprintf("%s\n(%s)", film, lubridate::year(date)))
analytic_df <- analytic_df |>
    mutate(film_cat = factor(film,
                             levels = film_dates$film,
                             ordered = TRUE))

## Just count some words ----
token_df <- analytic_df |>
    unnest_tokens(word, subtitle) |>
    mutate(
        family = grepl("family", word) + 0,
        # fam = grepl("\\<fam\\>", word) + 0,
        families = grepl("families", word) + 0,
        brother = grepl("brother", word) + 0,
        bro = grepl("\\<bro\\>", word) + 0,
        sister = grepl("sister", word) + 0,
        sis = grepl("\\<sis\\>", word) + 0,
        blood = grepl("blood", word) + 0,
        clan = grepl("\\<clan\\>", word) + 0,
        # tribe = grepl("\\<tribe\\>", word) + 0,
        cousin = grepl("cousin", word) + 0
    )

## Summarize ----
words_df <- token_df |>
    group_by(film, film_cat, date, runtime) |>
    summarize_at(vars(family:cousin), sum) |>
    ungroup() |> 
    pivot_longer(cols = family:cousin,
                 names_to = "word",
                 values_to = "n") |>
    mutate(word_cat = factor(
        word,
        levels = c(
            "family",
            "families",
            "blood",
            "clan",
            "brother",
            "bro",
            "sister",
            "sis",
            "cousin"
        ),
        labels = c(
            "Family",
            "Families",
            "Blood",
            "Clan",
            "Brother",
            "Bro",
            "Sister",
            "Sis",
            "Cousin"
        ),
        ordered = TRUE
    ))

## Plots ----
c_words <- c(
    "#08519c",
    "#3182bd",
    "#6baed6",
    "#bdd7e7",
    "#756bb1",
    "#54278f",
    "#de2d26",
    "#a50f15",
    "#006d2c"
)

p1 <- ggplot(words_df,
       aes(
           x = film_cat,
           y = n,
           color = word_cat,
           fill = word_cat,
           group = word_cat
       )) +
    geom_col(width = .9, color = "white") +
    scale_color_manual("Family-related word", values = c_words) +
    scale_fill_manual("Family-related word", values = c_words) +
    scale_x_discrete(NULL,
                 expand = c(0, 0), 
                 labels = film_dates$label
                 ) +
    scale_y_continuous("Mentions",
                       expand = c(0, 0)) +
    mk_nytimes(legend.position = "right") + 
    labs(title = 'Number of times "family" is mentioned in Fast and Furious movies',
         caption = "More: https://github.com/mkiang/fast_furious_family")

p2 <- ggplot(words_df |> 
           select(film_cat, runtime) |> 
           distinct() |> 
           ungroup(),
       aes(
           x = film_cat,
           y = runtime, 
           group = 1
       )) +
    geom_line() + 
    geom_point() + 
    scale_x_discrete(NULL,
                 expand = c(0, .2), 
                 labels = film_dates$label
                 ) +
    scale_y_continuous("Runtime (minutes)",
                       expand = c(0, 1)) +
    mk_nytimes(legend.position = "right") + 
    labs(title = 'Runtime (in minutes) of Fast and Furious movies',
         caption = "More: https://github.com/mkiang/fast_furious_family")

p3 <- ggplot(words_df,
       aes(
           x = film_cat,
           y = n / runtime,
           color = word_cat,
           fill = word_cat,
           group = word_cat
       )) +
    geom_col(width = .9, color = "white") +
    scale_color_manual("Family-related word", values = c_words) +
    scale_fill_manual("Family-related word", values = c_words) +
    scale_x_discrete(NULL,
                 expand = c(0, 0), 
                 labels = film_dates$label
                 ) +
    scale_y_continuous("Mentions per minute",
                       expand = c(0, 0)) +
    mk_nytimes(legend.position = "right") + 
    labs(title = 'Number of times per minute "family" is mentioned in Fast and Furious movies',
         caption = "More: https://github.com/mkiang/fast_furious_family")

## Save ----
ggsave(here("plots", "01_mentions_per_movie.jpg"), 
       p1,
       width = 10,
       height = 3.5,
       scale = 1,
       dpi = 300
)
ggsave(here("plots", "02_runtime_movie.jpg"), 
       p2,
       width = 10,
       height = 3.5,
       scale = 1,
       dpi = 300
)
ggsave(here("plots", "03_mentions_per_minute.jpg"), 
       p3,
       width = 10,
       height = 3.5,
       scale = 1,
       dpi = 300
)
