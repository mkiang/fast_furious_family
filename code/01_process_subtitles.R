library(tidyverse)
library(here)
library(fs)
library(srt)

film_df <- tibble(
    filename = c(
        "2 Fast 2 Furious (2003) 2160p.UHD.BluRay.x265-TERMiNAL.Hi.srt",
        "Fast . Furious 6.[2013].R5.LINE.DVDRIP.DIVX.[Eng]-DUQA®.srt",
        "Fast and Furious 7 2015 HD-TS XVID AC3 HQ Hive-CM8.srt",
        "Fast.Five.2011.EXTENDED.UHD.BluRay.x264-Pahe.in.srt",
        "Fast.X.2023.720p.AMZN.WEBRip.900MB.x264-GalaxyRG.Hi.srt",
        "Fast.and.Furious.9.The.Fast.Saga.2021.HDRip.XviD.AC3-EVO.v2.srt",
        "Fast.and.Furious[2009]BRRip[Eng]-K3LtZ.srt",
        "The.Fast.And.The.Furious.2001.2160p.4K.BluRay.x265.10bit.AAC5.1-[YTS.MX].srt",
        "The.Fate.Of.The.Furious.2017.HC.HDRip.XViD.AC3-EVO-All Releases.srt",
        "the.fast.and.the.furious.tokyo.drift.(2006).eng.1cd.(9029895).srt"
    ),
    film = c(
        "2 Fast\n2 Furious",
        "Fast &\nFurious 6",
        "Furious 7",
        "Fast Five",
        "Fast X",
        "F9",
        "Fast &\nFurious",
        "The Fast and\nThe Furious",
        "The Fate of\nthe Furious",
        "The Fast and\nThe Furious:\nTokyo Drift"
    ),
    date = lubridate::ymd(c(
        "2003/06/06",
        "2013/05/24",
        "2015/04/03",
        "2011/04/29",
        "2023/05/19",
        "2021/06/25",
        "2009/04/03",
        "2001/06/22",
        "2017/04/17",
        "2006/06/16"
    )),
    runtime = 
        c(108, 
          130,
          137,
          130,
          141,
          143,
          107,
          106,
          136,
          104))
    
raw_paths <- dir_ls(here("data_raw"), glob = "*.srt")
line_df <- map_dfr(.x = raw_paths,
                   .f = ~ srt::read_srt(.x) |>
                       mutate(filename = basename(.x)))

analytic_df <- left_join(line_df, film_df)
saveRDS(analytic_df, here("data", "analytic_data.RDS"))
