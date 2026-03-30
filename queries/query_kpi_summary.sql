WITH stablecoin_transfers AS (
    SELECT
        date_trunc('day', evt_block_time)    AS transfer_date,
        value / 1e6                          AS amount_usd
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
),

daily_stats AS (
    SELECT
        transfer_date,
        COUNT(*)        AS daily_transfers,
        SUM(amount_usd) AS daily_volume
    FROM stablecoin_transfers
    GROUP BY transfer_date
)

SELECT
    -- Total volume across entire period
    SUM(daily_volume)                                        AS total_volume_usd,
    -- Total number of transfers
    SUM(daily_transfers)                                     AS total_transfers,
    -- Number of days in dataset
    COUNT(DISTINCT transfer_date)                            AS days_analyzed,
    -- Average daily volume
    AVG(daily_volume)                                        AS avg_daily_volume,
    -- Average daily transfers
    AVG(daily_transfers)                                     AS avg_daily_transfers,
    -- Peak volume day
    MAX(daily_volume)                                        AS peak_daily_volume,
    -- Peak transfers day
    MAX(daily_transfers)                                     AS peak_daily_transfers
FROM daily_stats
