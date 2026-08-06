package io.github.vlad1slavs.okoshko.schedule.data;

import io.github.vlad1slavs.okoshko.schedule.api.AvailabilityResponse;
import org.jooq.DSLContext;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static io.github.vlad1slavs.okoshko.jooq.Tables.APPOINTMENTS;
import static io.github.vlad1slavs.okoshko.jooq.Tables.BUSINESS_ACCOUNTS;
import static io.github.vlad1slavs.okoshko.jooq.Tables.BUSINESS_LOCATIONS;
import static io.github.vlad1slavs.okoshko.jooq.Tables.PROFESSIONAL_AVAILABILITY_STARTS;
import static io.github.vlad1slavs.okoshko.jooq.Tables.SERVICE_PROFESSIONALS;
import static io.github.vlad1slavs.okoshko.jooq.Tables.SERVICES;

@Repository
public class ProfessionalAvailabilityRepository {

    private final DSLContext dsl;

    public ProfessionalAvailabilityRepository(DSLContext dsl) {
        this.dsl = dsl;
    }

    public Optional<ScheduleContext> findContext(UUID professionalId) {
        return dsl.select(BUSINESS_LOCATIONS.ID, BUSINESS_LOCATIONS.TIMEZONE)
                .from(BUSINESS_ACCOUNTS)
                .join(BUSINESS_LOCATIONS)
                .on(BUSINESS_LOCATIONS.BUSINESS_ACCOUNT_ID.eq(BUSINESS_ACCOUNTS.ID)
                        .and(BUSINESS_LOCATIONS.IS_ACTIVE.isTrue()))
                .where(BUSINESS_ACCOUNTS.SOLO_PROFESSIONAL_ID.eq(professionalId)
                        .and(BUSINESS_ACCOUNTS.STATUS.eq("ACTIVE")))
                .orderBy(BUSINESS_LOCATIONS.CREATED_AT.asc())
                .limit(1)
                .fetchOptional(record -> new ScheduleContext(
                        record.get(BUSINESS_LOCATIONS.ID),
                        ZoneId.of(record.get(BUSINESS_LOCATIONS.TIMEZONE))
                ));
    }

    public Set<UUID> findActiveServiceIds(UUID professionalId) {
        return dsl.select(SERVICE_PROFESSIONALS.SERVICE_ID)
                .from(SERVICE_PROFESSIONALS)
                .join(SERVICES).on(SERVICES.ID.eq(SERVICE_PROFESSIONALS.SERVICE_ID))
                .where(SERVICE_PROFESSIONALS.PROFESSIONAL_ID.eq(professionalId)
                        .and(SERVICE_PROFESSIONALS.IS_ACTIVE.isTrue())
                        .and(SERVICES.IS_ACTIVE.isTrue()))
                .fetchSet(SERVICE_PROFESSIONALS.SERVICE_ID);
    }

    public boolean overlapsActiveAppointment(UUID professionalId, OffsetDateTime startsAt) {
        return dsl.fetchExists(
                dsl.selectOne()
                        .from(APPOINTMENTS)
                        .where(APPOINTMENTS.PROFESSIONAL_ID.eq(professionalId)
                                .and(APPOINTMENTS.STATUS.in("PENDING_CONFIRMATION", "CONFIRMED"))
                                .and(APPOINTMENTS.STARTS_AT.le(startsAt))
                                .and(APPOINTMENTS.ENDS_AT.gt(startsAt)))
        );
    }

    public void replaceDate(
            UUID professionalId,
            UUID locationId,
            OffsetDateTime from,
            OffsetDateTime toExclusive,
            List<NewAvailabilityStart> starts
    ) {
        dsl.deleteFrom(PROFESSIONAL_AVAILABILITY_STARTS)
                .where(PROFESSIONAL_AVAILABILITY_STARTS.PROFESSIONAL_ID.eq(professionalId)
                        .and(PROFESSIONAL_AVAILABILITY_STARTS.STARTS_AT.ge(from))
                        .and(PROFESSIONAL_AVAILABILITY_STARTS.STARTS_AT.lt(toExclusive)))
                .execute();

        for (var start : starts) {
            dsl.insertInto(PROFESSIONAL_AVAILABILITY_STARTS)
                    .set(PROFESSIONAL_AVAILABILITY_STARTS.PROFESSIONAL_ID, professionalId)
                    .set(PROFESSIONAL_AVAILABILITY_STARTS.LOCATION_ID, locationId)
                    .set(PROFESSIONAL_AVAILABILITY_STARTS.RESTRICTED_SERVICE_ID, start.restrictedServiceId())
                    .set(PROFESSIONAL_AVAILABILITY_STARTS.STARTS_AT, start.startsAt())
                    .execute();
        }
    }

    public List<StoredAvailabilityStart> findStarts(
            UUID professionalId,
            OffsetDateTime from,
            OffsetDateTime toExclusive,
            ZoneId zone
    ) {
        return dsl.select(
                        PROFESSIONAL_AVAILABILITY_STARTS.ID,
                        PROFESSIONAL_AVAILABILITY_STARTS.STARTS_AT,
                        PROFESSIONAL_AVAILABILITY_STARTS.RESTRICTED_SERVICE_ID,
                        SERVICES.NAME
                )
                .from(PROFESSIONAL_AVAILABILITY_STARTS)
                .leftJoin(SERVICES)
                .on(SERVICES.ID.eq(PROFESSIONAL_AVAILABILITY_STARTS.RESTRICTED_SERVICE_ID))
                .where(PROFESSIONAL_AVAILABILITY_STARTS.PROFESSIONAL_ID.eq(professionalId)
                        .and(PROFESSIONAL_AVAILABILITY_STARTS.STARTS_AT.ge(from))
                        .and(PROFESSIONAL_AVAILABILITY_STARTS.STARTS_AT.lt(toExclusive)))
                .orderBy(PROFESSIONAL_AVAILABILITY_STARTS.STARTS_AT.asc())
                .fetch(record -> {
                    var local = record.get(PROFESSIONAL_AVAILABILITY_STARTS.STARTS_AT)
                            .atZoneSameInstant(zone);
                    return new StoredAvailabilityStart(
                            record.get(PROFESSIONAL_AVAILABILITY_STARTS.ID),
                            local.toLocalDate(),
                            local.toLocalTime(),
                            record.get(PROFESSIONAL_AVAILABILITY_STARTS.RESTRICTED_SERVICE_ID),
                            record.get(SERVICES.NAME)
                    );
                });
    }

    public record ScheduleContext(UUID locationId, ZoneId zone) {
    }

    public record NewAvailabilityStart(OffsetDateTime startsAt, UUID restrictedServiceId) {
    }

    public record StoredAvailabilityStart(
            UUID id,
            java.time.LocalDate date,
            java.time.LocalTime time,
            UUID restrictedServiceId,
            String restrictedServiceName
    ) {
    }
}
