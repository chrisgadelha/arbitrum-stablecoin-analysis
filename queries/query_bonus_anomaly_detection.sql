WITH daily_data AS (
    SELECT
        date_trunc('day', evt_block_time)                   AS transfer_date,
        COUNT(*)                                            AS daily_transfers,
        SUM(value / 1e6)                                    AS daily_volume
    FROM erc20_arbitrum.evt_Transfer
    WHERE contract_address IN (
        0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9,
        0xaf88d065e77c8cC2239327C5EDb3A432268e5831,
        0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8
    )
    AND evt_block_time >= TIMESTAMP '2023-01-01'
    AND evt_block_time <  TIMESTAMP '2026-03-25'
    AND "from" != 0x0000000000000000000000000000000000000000
    AND "to"   != 0x0000000000000000000000000000000000000000
    GROUP BY 1
),

with_averages AS (
    SELECT
        transfer_date,
        daily_transfers,
        daily_volume,
        -- 30-day moving average for baseline
        AVG(daily_volume) OVER (
            ORDER BY transfer_date
            ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING
        )                                                   AS volume_30d_avg,
        AVG(CAST(daily_transfers AS DOUBLE)) OVER (
            ORDER BY transfer_date
            ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING
        )                                                   AS transfers_30d_avg
    FROM daily_data
)

SELECT
    transfer_date,
    daily_volume,
    volume_30d_avg,
    ROUND(daily_volume / NULLIF(volume_30d_avg, 0), 2)      AS volume_multiplier,
    daily_transfers,
    transfers_30d_avg,
    ROUND(daily_transfers / NULLIF(transfers_30d_avg, 0), 2) AS transfers_multiplier,
    -- Classify the anomaly type
    CASE
        WHEN daily_volume / NULLIF(volume_30d_avg, 0) >= 3
         AND daily_transfers / NULLIF(transfers_30d_avg, 0) >= 3
            THEN 'BOTH — Mass activity spike'
        WHEN daily_volume / NULLIF(volume_30d_avg, 0) >= 3
            THEN 'VOLUME ONLY — Whale/institutional'
        WHEN daily_transfers / NULLIF(transfers_30d_avg, 0) >= 3
            THEN 'TRANSFERS ONLY — Retail surge'
        ELSE 'Normal'
    END                                                     AS anomaly_type
FROM with_averages
WHERE daily_volume / NULLIF(volume_30d_avg, 0) >= 3
   OR daily_transfers / NULLIF(transfers_30d_avg, 0) >= 3
ORDER BY transfer_date
