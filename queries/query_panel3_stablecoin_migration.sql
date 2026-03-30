WITH monthly_volume AS (
    SELECT
        date_trunc('month', evt_block_time)                 AS transfer_month,
        CASE
            WHEN contract_address = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9
                THEN 'USDT'
            WHEN contract_address = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831
                THEN 'USDC (native)'
            WHEN contract_address = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8
                THEN 'USDC.e (bridged)'
        END                                                 AS stablecoin,
        SUM(value / 1e6)                                    AS monthly_volume_usd,
        COUNT(*)                                            AS monthly_transfers
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
    GROUP BY 1, 2
)

SELECT
    transfer_month,
    stablecoin,
    monthly_volume_usd,
    monthly_transfers,
    -- Percentage of monthly volume by stablecoin
    ROUND(
        100.0 * monthly_volume_usd
        / SUM(monthly_volume_usd) OVER (PARTITION BY transfer_month),
        2
    )                                                       AS pct_volume,
    -- Percentage of monthly transfers by stablecoin
    ROUND(
        100.0 * monthly_transfers
        / SUM(monthly_transfers) OVER (PARTITION BY transfer_month),
        2
    )                                                       AS pct_transfers
FROM monthly_volume
ORDER BY transfer_month, stablecoin
