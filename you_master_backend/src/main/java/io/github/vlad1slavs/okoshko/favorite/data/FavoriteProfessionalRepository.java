package io.github.vlad1slavs.okoshko.favorite.data;

import io.github.vlad1slavs.okoshko.professional.api.ProfessionalPreviewResponse;
import org.jooq.DSLContext;
import org.jooq.Field;
import org.jooq.impl.DSL;
import org.springframework.stereotype.Repository;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;

import static io.github.vlad1slavs.okoshko.jooq.Tables.BUSINESS_ACCOUNTS;
import static io.github.vlad1slavs.okoshko.jooq.Tables.BUSINESS_LOCATIONS;
import static io.github.vlad1slavs.okoshko.jooq.Tables.CLIENT_FAVORITE_PROFESSIONALS;
import static io.github.vlad1slavs.okoshko.jooq.Tables.PROFESSIONAL_PROFILES;
import static io.github.vlad1slavs.okoshko.jooq.Tables.SERVICE_CATEGORIES;
import static io.github.vlad1slavs.okoshko.jooq.Tables.SERVICES;

@Repository
public class FavoriteProfessionalRepository {

    private final DSLContext dsl;

    public FavoriteProfessionalRepository(DSLContext dsl) {
        this.dsl = dsl;
    }

    public List<String> findIds(UUID userId) {
        return dsl.select(PROFESSIONAL_PROFILES.SLUG)
                .from(CLIENT_FAVORITE_PROFESSIONALS)
                .join(PROFESSIONAL_PROFILES)
                .on(PROFESSIONAL_PROFILES.ID.eq(CLIENT_FAVORITE_PROFESSIONALS.PROFESSIONAL_ID))
                .where(CLIENT_FAVORITE_PROFESSIONALS.CLIENT_USER_ID.eq(userId)
                        .and(PROFESSIONAL_PROFILES.STATUS.eq("ACTIVE")))
                .orderBy(CLIENT_FAVORITE_PROFESSIONALS.CREATED_AT.desc())
                .fetch(PROFESSIONAL_PROFILES.SLUG);
    }

    public boolean add(UUID userId, String slug) {
        var professionalId = activeProfessionalId(slug);
        return dsl.insertInto(CLIENT_FAVORITE_PROFESSIONALS)
                .set(CLIENT_FAVORITE_PROFESSIONALS.CLIENT_USER_ID, userId)
                .set(CLIENT_FAVORITE_PROFESSIONALS.PROFESSIONAL_ID, professionalId)
                .onConflictDoNothing()
                .execute() > 0;
    }

    public void remove(UUID userId, String slug) {
        dsl.deleteFrom(CLIENT_FAVORITE_PROFESSIONALS)
                .where(CLIENT_FAVORITE_PROFESSIONALS.CLIENT_USER_ID.eq(userId)
                        .and(CLIENT_FAVORITE_PROFESSIONALS.PROFESSIONAL_ID.eq(
                                dsl.select(PROFESSIONAL_PROFILES.ID)
                                        .from(PROFESSIONAL_PROFILES)
                                        .where(PROFESSIONAL_PROFILES.SLUG.equalIgnoreCase(slug))
                        )))
                .execute();
    }

    public List<ProfessionalPreviewResponse> findPage(UUID userId, int limit, int offset) {
        var priceFrom = DSL.min(SERVICES.PRICE_MINOR).as("price_from_minor");
        var durationFrom = DSL.min(SERVICES.DURATION_MINUTES).as("duration_from_minutes");
        var durationTo = DSL.max(SERVICES.DURATION_MINUTES).as("duration_to_minutes");
        Field<String[]> categorySlugs = DSL.arrayAggDistinct(SERVICE_CATEGORIES.SLUG)
                .orderBy(SERVICE_CATEGORIES.SLUG).as("category_slugs");

        return dsl.select(
                        PROFESSIONAL_PROFILES.SLUG,
                        PROFESSIONAL_PROFILES.DISPLAY_NAME,
                        PROFESSIONAL_PROFILES.DESCRIPTION,
                        PROFESSIONAL_PROFILES.AVATAR_URL,
                        PROFESSIONAL_PROFILES.RATING,
                        PROFESSIONAL_PROFILES.REVIEWS_COUNT,
                        priceFrom, durationFrom, durationTo, categorySlugs,
                        CLIENT_FAVORITE_PROFESSIONALS.CREATED_AT
                )
                .from(CLIENT_FAVORITE_PROFESSIONALS)
                .join(PROFESSIONAL_PROFILES)
                .on(PROFESSIONAL_PROFILES.ID.eq(CLIENT_FAVORITE_PROFESSIONALS.PROFESSIONAL_ID)
                        .and(PROFESSIONAL_PROFILES.STATUS.eq("ACTIVE")))
                .join(BUSINESS_ACCOUNTS)
                .on(BUSINESS_ACCOUNTS.SOLO_PROFESSIONAL_ID.eq(PROFESSIONAL_PROFILES.ID)
                        .and(BUSINESS_ACCOUNTS.STATUS.eq("ACTIVE")))
                .join(BUSINESS_LOCATIONS)
                .on(BUSINESS_LOCATIONS.BUSINESS_ACCOUNT_ID.eq(BUSINESS_ACCOUNTS.ID)
                        .and(BUSINESS_LOCATIONS.IS_ACTIVE.isTrue()))
                .join(SERVICES)
                .on(SERVICES.BUSINESS_ACCOUNT_ID.eq(BUSINESS_ACCOUNTS.ID)
                        .and(SERVICES.IS_ACTIVE.isTrue()))
                .join(SERVICE_CATEGORIES)
                .on(SERVICE_CATEGORIES.ID.eq(SERVICES.CATEGORY_ID)
                        .and(SERVICE_CATEGORIES.IS_ACTIVE.isTrue()))
                .where(CLIENT_FAVORITE_PROFESSIONALS.CLIENT_USER_ID.eq(userId))
                .groupBy(PROFESSIONAL_PROFILES.ID, CLIENT_FAVORITE_PROFESSIONALS.CREATED_AT)
                .orderBy(CLIENT_FAVORITE_PROFESSIONALS.CREATED_AT.desc())
                .limit(limit).offset(offset)
                .fetch(record -> new ProfessionalPreviewResponse(
                        record.get(PROFESSIONAL_PROFILES.SLUG),
                        record.get(PROFESSIONAL_PROFILES.DISPLAY_NAME),
                        record.get(PROFESSIONAL_PROFILES.DESCRIPTION),
                        record.get(PROFESSIONAL_PROFILES.AVATAR_URL),
                        record.get(PROFESSIONAL_PROFILES.RATING),
                        record.get(PROFESSIONAL_PROFILES.REVIEWS_COUNT),
                        record.get(priceFrom), record.get(durationFrom), record.get(durationTo),
                        Arrays.asList(record.get(categorySlugs)), null
                ));
    }

    public long count(UUID userId) {
        return dsl.fetchCount(CLIENT_FAVORITE_PROFESSIONALS,
                CLIENT_FAVORITE_PROFESSIONALS.CLIENT_USER_ID.eq(userId));
    }

    private UUID activeProfessionalId(String slug) {
        return dsl.select(PROFESSIONAL_PROFILES.ID)
                .from(PROFESSIONAL_PROFILES)
                .where(PROFESSIONAL_PROFILES.SLUG.equalIgnoreCase(slug)
                        .and(PROFESSIONAL_PROFILES.STATUS.eq("ACTIVE")))
                .fetchOptional(PROFESSIONAL_PROFILES.ID)
                .orElseThrow(() -> new io.github.vlad1slavs.okoshko.shared.error.ResourceNotFoundException(
                        "Мастер не найден"));
    }
}
