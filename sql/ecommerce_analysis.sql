-- E-commerce SQL Analysis
-- BigQuery
--
-- Purpose:
-- Build a dataset for analyzing account creation and email activity
-- by date, country, sending interval, verification status,
-- and subscription status.
--
-- The query calculates:
--   * account_cnt
--   * sent_msg
--   * open_msg
--   * visit_msg
--   * total_country_account_cnt
--   * total_country_sent_cnt
--   * rank_total_country_account_cnt
--   * rank_total_country_sent_cnt
--
-- Account and email metrics are calculated separately because
-- their date fields have different business logic, then combined
-- with UNION ALL.

WITH account_metrics AS (
    -- Aggregate account creation metrics by account attributes.
    SELECT
        date,
        spar.country,
        ac.send_interval,
        ac.is_verified,
        ac.is_unsubscribed,
        COUNT(DISTINCT ac.id) AS account_cnt,
        NULL AS sent_msg,
        NULL AS open_msg,
        NULL AS visit_msg
    FROM DA.account AS ac
    JOIN DA.account_session AS acs
        ON ac.id = acs.account_id
    JOIN DA.session_params AS spar
        ON acs.ga_session_id = spar.ga_session_id
    JOIN data-analytics-mate.DA.session AS ses
        ON spar.ga_session_id = ses.ga_session_id
    GROUP BY
        date,
        spar.country,
        ac.send_interval,
        ac.is_verified,
        ac.is_unsubscribed
),

email_metrics AS (
    -- Aggregate email activity by email sending date and account attributes.
    SELECT
        DATE_ADD(se.date, INTERVAL es.sent_date DAY) AS date,
        sp.country,
        aco.send_interval,
        aco.is_verified,
        aco.is_unsubscribed,
        NULL AS account_cnt,
        COUNT(DISTINCT es.id_message) AS sent_msg,
        COUNT(DISTINCT eo.id_message) AS open_msg,
        COUNT(DISTINCT ev.id_message) AS visit_msg
    FROM data-analytics-mate.DA.email_sent AS es
    JOIN DA.account_session AS s
        ON es.id_account = s.account_id
    JOIN data-analytics-mate.DA.account AS aco
        ON s.account_id = aco.id
    JOIN data-analytics-mate.DA.session AS se
        ON s.ga_session_id = se.ga_session_id
    JOIN DA.session_params AS sp
        ON se.ga_session_id = sp.ga_session_id
    LEFT JOIN data-analytics-mate.DA.email_open AS eo
        ON es.id_message = eo.id_message
    LEFT JOIN data-analytics-mate.DA.email_visit AS ev
        ON es.id_message = ev.id_message
    GROUP BY
        date,
        sp.country,
        aco.send_interval,
        aco.is_verified,
        aco.is_unsubscribed
),

combined_metrics AS (
    -- Combine account and email metrics into one dataset.
    SELECT
        date,
        country,
        send_interval,
        is_verified,
        is_unsubscribed,
        account_cnt,
        sent_msg,
        open_msg,
        visit_msg
    FROM account_metrics

    UNION ALL

    SELECT
        date,
        country,
        send_interval,
        is_verified,
        is_unsubscribed,
        account_cnt,
        sent_msg,
        open_msg,
        visit_msg
    FROM email_metrics
),

fact_table AS (
    -- Re-aggregate combined data to remove duplicate dimensional rows
    -- created by the separate account and email metric calculations.
    SELECT
        date,
        country,
        send_interval,
        is_verified,
        is_unsubscribed,
        SUM(account_cnt) AS account_cnt,
        SUM(sent_msg) AS sent_msg,
        SUM(open_msg) AS open_msg,
        SUM(visit_msg) AS visit_msg
    FROM combined_metrics
    GROUP BY
        date,
        country,
        send_interval,
        is_verified,
        is_unsubscribed
),

country_totals AS (
    -- Calculate country-level totals using window functions.
    SELECT
        *,
        SUM(account_cnt) OVER (
            PARTITION BY country
        ) AS total_country_account_cnt,
        SUM(sent_msg) OVER (
            PARTITION BY country
        ) AS total_country_sent_cnt
    FROM fact_table
),

country_ranks AS (
    -- Rank countries by total accounts and total sent emails.
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY total_country_account_cnt DESC
        ) AS rank_total_country_account_cnt,
        DENSE_RANK() OVER (
            ORDER BY total_country_sent_cnt DESC
        ) AS rank_total_country_sent_cnt
    FROM country_totals
)

-- Keep records belonging to countries ranked in the top 10
-- by either total account count or total sent email count.
SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    sent_msg,
    open_msg,
    visit_msg,
    total_country_account_cnt,
    total_country_sent_cnt,
    rank_total_country_account_cnt,
    rank_total_country_sent_cnt
FROM country_ranks
WHERE rank_total_country_account_cnt <= 10
   OR rank_total_country_sent_cnt <= 10;
