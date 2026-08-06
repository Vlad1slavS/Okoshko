package io.github.vlad1slavs.okoshko.appointment.data;

import io.github.vlad1slavs.okoshko.appointment.api.CalendarAppointmentResponse;
import org.jooq.DSLContext;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static io.github.vlad1slavs.okoshko.jooq.Tables.APPOINTMENTS;
import static io.github.vlad1slavs.okoshko.jooq.Tables.BUSINESS_ACCOUNTS;
import static io.github.vlad1slavs.okoshko.jooq.Tables.BUSINESS_LOCATIONS;

@Repository
public class ProfessionalCalendarRepository {

    private final DSLContext dsl;

    public ProfessionalCalendarRepository(DSLContext dsl) {
        this.dsl = dsl;
    }

    public Optional<String> findTimezone(UUID professionalId) {
        return dsl.select(BUSINESS_LOCATIONS.TIMEZONE)
                .from(BUSINESS_ACCOUNTS)
                .join(BUSINESS_LOCATIONS)
                .on(BUSINESS_LOCATIONS.BUSINESS_ACCOUNT_ID.eq(BUSINESS_ACCOUNTS.ID)
                        .and(BUSINESS_LOCATIONS.IS_ACTIVE.isTrue()))
                .where(BUSINESS_ACCOUNTS.SOLO_PROFESSIONAL_ID.eq(professionalId)
                        .and(BUSINESS_ACCOUNTS.STATUS.eq("ACTIVE")))
                .orderBy(BUSINESS_LOCATIONS.CREATED_AT.asc())
                .limit(1)
                .fetchOptional(BUSINESS_LOCATIONS.TIMEZONE);
    }

    public List<CalendarAppointmentResponse> findAppointments(
            UUID professionalId,
            OffsetDateTime from,
            OffsetDateTime toExclusive,
            ZoneId zone
    ) {
        return dsl.select(
                        APPOINTMENTS.ID,
                        APPOINTMENTS.CLIENT_NAME_SNAPSHOT,
                        APPOINTMENTS.SERVICE_NAME_SNAPSHOT,
                        APPOINTMENTS.STARTS_AT,
                        APPOINTMENTS.ENDS_AT,
                        APPOINTMENTS.STATUS,
                        APPOINTMENTS.PRICE_MINOR,
                        APPOINTMENTS.CURRENCY
                )
                .from(APPOINTMENTS)
                .where(APPOINTMENTS.PROFESSIONAL_ID.eq(professionalId)
                        .and(APPOINTMENTS.STARTS_AT.ge(from))
                        .and(APPOINTMENTS.STARTS_AT.lt(toExclusive)))
                .orderBy(APPOINTMENTS.STARTS_AT.asc(), APPOINTMENTS.ID.asc())
                .fetch(record -> {
                    var startsAt = record.get(APPOINTMENTS.STARTS_AT);
                    var endsAt = record.get(APPOINTMENTS.ENDS_AT);
                    var localStart = startsAt.atZoneSameInstant(zone);
                    var localEnd = endsAt.atZoneSameInstant(zone);
                    return new CalendarAppointmentResponse(
                            record.get(APPOINTMENTS.ID),
                            record.get(APPOINTMENTS.CLIENT_NAME_SNAPSHOT),
                            record.get(APPOINTMENTS.SERVICE_NAME_SNAPSHOT),
                            startsAt,
                            endsAt,
                            localStart.toLocalDate(),
                            localStart.toLocalTime(),
                            localEnd.toLocalTime(),
                            record.get(APPOINTMENTS.STATUS),
                            record.get(APPOINTMENTS.PRICE_MINOR),
                            record.get(APPOINTMENTS.CURRENCY)
                    );
                });
    }
}
