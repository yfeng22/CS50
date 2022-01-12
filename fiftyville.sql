--find the thief
SELECT
    people.name
FROM
    people
WHERE
    -- this person left bakery lot around 1015 to 1025
    people.license_plate in
    (SELECT
        license_plate
    FROM
        bakery_security_logs
    WHERE
        year = 2021
        AND month = 7
        AND day = 28
        AND hour = 10
        AND minute > 15
        AND minute <=25
        AND activity = "exit")
AND
    -- this person called other people for less than one minute on 28/07
    people.phone_number in
    (SELECT
        phone_calls.caller
    FROM
        phone_calls
    WHERE phone_calls.year = 2021
    AND phone_calls.day = 28
    AND phone_calls.month = 7
    AND duration <60)
AND
    -- this person withdrawed from leggett street atm on 28/07
    people.name in
    (SELECT
        distinct(people.name)
    FROM
        people
        JOIN bank_accounts ON people.id = bank_accounts.person_id
    WHERE
        bank_accounts.account_number in
    (SELECT
        account_number
    FROM
        atm_transactions
    WHERE year = 2021
    AND month = 7
    AND day = 28
    AND atm_location = "Leggett Street"
    AND transaction_type = "withdraw"))
AND
    -- this person will left the city by the earliest flight on 29/07
    people.name IN
    (SELECT
        people.name
    FROM
        people
    WHERE
        people.passport_number IN
        (SELECT
            passport_number
        FROM
            passengers
        WHERE
            flight_id IN
            (SELECT
                id
            FROM
                flights
            WHERE
                year =2021
                AND day = 29
                AND month = 7
                AND origin_airport_id IN
                    (SELECT airports.id
                    FROM airports
                    where
                    airports.city = "Fiftyville")
            ORDER BY hour ASC, MINUTE ASC
            LIMIT 1)));

-- to find the accomplice. Bruce called this guy on 28/07 for less than 1 minute.
SELECT
    people.name
FROM
    people
WHERE people.phone_number IN
    (SELECT
        phone_calls.receiver
    FROM
        phone_calls
    WHERE phone_calls.caller IN
            (SELECT people.phone_number
            FROM people
            WHERE people.name = "Bruce")
    AND phone_calls.year = 2021
    AND phone_calls.month = 7
    AND phone_calls.day = 28
    AND duration < 60);

-- to find the city the thief escape to
SELECT
    city
FROM
    airports
WHERE airports.id IN
    (SELECT
        destination_airport_id
    FROM
        flights
    WHERE
        flights.id IN
        (SELECT
                id
        FROM
                flights
        WHERE
            year =2021
        AND day = 29
        AND month = 7
        AND origin_airport_id IN
            (SELECT airports.id
            FROM airports
            where
            airports.city = "Fiftyville")
        ORDER BY hour ASC, MINUTE ASC
        LIMIT 1)
    );
