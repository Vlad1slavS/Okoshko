package io.github.vlad1slavs.okoshko.professional.data;

import io.github.vlad1slavs.okoshko.professional.api.ProfessionalPreviewResponse;
import io.github.vlad1slavs.okoshko.professional.api.ProfessionalSort;
import org.jooq.Condition;
import org.jooq.DSLContext;
import org.jooq.Field;
import org.jooq.SortField;
import org.jooq.impl.DSL;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

import static io.github.vlad1slavs.okoshko.jooq.Tables.BUSINESS_ACCOUNTS;
import static io.github.vlad1slavs.okoshko.jooq.Tables.BUSINESS_LOCATIONS;
import static io.github.vlad1slavs.okoshko.jooq.Tables.PROFESSIONAL_PROFILES;
import static io.github.vlad1slavs.okoshko.jooq.Tables.SERVICE_CATEGORIES;
import static io.github.vlad1slavs.okoshko.jooq.Tables.SERVICES;

@Repository
public class ProfessionalCatalogRepository {

    private final DSLContext dsl;

    public ProfessionalCatalogRepository(DSLContext dsl) {
        this.dsl = dsl;
    }

    public List<ProfessionalPreviewResponse> findAll(
            String city,
            String category,
            String query,
            BigDecimal minimumRating,
            ProfessionalSort sort,
            int limit,
            int offset
    ) {
        var priceFrom = DSL.min(SERVICES.PRICE_MINOR).as("price_from_minor");
        var durationFrom = DSL.min(SERVICES.DURATION_MINUTES).as("duration_from_minutes");
        var durationTo = DSL.max(SERVICES.DURATION_MINUTES).as("duration_to_minutes");
        Field<String[]> categorySlugs = DSL.arrayAggDistinct(SERVICE_CATEGORIES.SLUG)
                .orderBy(SERVICE_CATEGORIES.SLUG)
                .as("category_slugs");

        return dsl.select(
                        PROFESSIONAL_PROFILES.SLUG,
                        PROFESSIONAL_PROFILES.DISPLAY_NAME,
                        PROFESSIONAL_PROFILES.DESCRIPTION,
                        PROFESSIONAL_PROFILES.AVATAR_URL,
                        PROFESSIONAL_PROFILES.RATING,
                        PROFESSIONAL_PROFILES.REVIEWS_COUNT,
                        priceFrom,
                        durationFrom,
                        durationTo,
                        categorySlugs
                )
                .from(PROFESSIONAL_PROFILES)
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
                .where(filters(city, category, query, minimumRating))
                .groupBy(
                        PROFESSIONAL_PROFILES.ID,
                        PROFESSIONAL_PROFILES.SLUG,
                        PROFESSIONAL_PROFILES.DISPLAY_NAME,
                        PROFESSIONAL_PROFILES.DESCRIPTION,
                        PROFESSIONAL_PROFILES.AVATAR_URL,
                        PROFESSIONAL_PROFILES.RATING,
                        PROFESSIONAL_PROFILES.REVIEWS_COUNT,
                        PROFESSIONAL_PROFILES.COMPLETED_APPOINTMENTS_COUNT
                )
                .orderBy(orderBy(sort, priceFrom))
                .limit(limit)
                .offset(offset)
                .fetch(record -> new ProfessionalPreviewResponse(
                        record.get(PROFESSIONAL_PROFILES.SLUG),
                        record.get(PROFESSIONAL_PROFILES.DISPLAY_NAME),
                        record.get(PROFESSIONAL_PROFILES.DESCRIPTION),
                        record.get(PROFESSIONAL_PROFILES.AVATAR_URL),
                        record.get(PROFESSIONAL_PROFILES.RATING),
                        record.get(PROFESSIONAL_PROFILES.REVIEWS_COUNT),
                        record.get(priceFrom),
                        record.get(durationFrom),
                        record.get(durationTo),
                        Arrays.asList(record.get(categorySlugs)),
                        null
                ));
    }

    public long count(String city, String category, String query, BigDecimal minimumRating) {
        var total = DSL.countDistinct(PROFESSIONAL_PROFILES.ID)
                .cast(Long.class)
                .as("total_items");

        return dsl.select(total)
                .from(PROFESSIONAL_PROFILES)
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
                .where(filters(city, category, query, minimumRating))
                .fetchOptional(total)
                .orElse(0L);
    }

    private Condition filters(
            String city,
            String category,
            String query,
            BigDecimal minimumRating
    ) {
        var condition = PROFESSIONAL_PROFILES.STATUS.eq("ACTIVE")
                .and(DSL.lower(BUSINESS_LOCATIONS.CITY).eq(city.toLowerCase(Locale.ROOT)))
                .and(PROFESSIONAL_PROFILES.RATING.ge(minimumRating));

        if (!query.isBlank()) {
            var normalizedQuery = query.toLowerCase(Locale.ROOT);
            var searchServices = SERVICES.as("search_services");
            condition = condition.and(
                    DSL.lower(PROFESSIONAL_PROFILES.DISPLAY_NAME).contains(normalizedQuery)
                            .or(DSL.lower(BUSINESS_ACCOUNTS.NAME).contains(normalizedQuery))
                            .orExists(
                                    DSL.selectOne()
                                            .from(searchServices)
                                            .where(searchServices.BUSINESS_ACCOUNT_ID.eq(BUSINESS_ACCOUNTS.ID)
                                                    .and(searchServices.IS_ACTIVE.isTrue())
                                                    .and(DSL.lower(searchServices.NAME).contains(normalizedQuery)))
                            )
            );
        }

        if (!category.isBlank()) {
            var filteredServices = SERVICES.as("filtered_services");
            var filteredCategories = SERVICE_CATEGORIES.as("filtered_categories");
            condition = condition.andExists(
                    DSL.selectOne()
                            .from(filteredServices)
                            .join(filteredCategories)
                            .on(filteredCategories.ID.eq(filteredServices.CATEGORY_ID))
                            .where(filteredServices.BUSINESS_ACCOUNT_ID.eq(BUSINESS_ACCOUNTS.ID)
                                    .and(filteredServices.IS_ACTIVE.isTrue())
                                    .and(filteredCategories.IS_ACTIVE.isTrue())
                                    .and(DSL.lower(filteredCategories.SLUG)
                                            .eq(category.toLowerCase(Locale.ROOT))))
            );
        }

        return condition;
    }

    private List<SortField<?>> orderBy(ProfessionalSort sort, Field<Long> priceFrom) {
        return switch (sort) {
            case PRICE -> List.of(
                    priceFrom.asc(),
                    PROFESSIONAL_PROFILES.RATING.desc(),
                    PROFESSIONAL_PROFILES.ID.asc()
            );
            case RATING -> List.of(
                    PROFESSIONAL_PROFILES.RATING.desc(),
                    PROFESSIONAL_PROFILES.REVIEWS_COUNT.desc(),
                    PROFESSIONAL_PROFILES.ID.asc()
            );
            case RECOMMENDED -> List.of(
                    PROFESSIONAL_PROFILES.RATING.desc(),
                    PROFESSIONAL_PROFILES.REVIEWS_COUNT.desc(),
                    PROFESSIONAL_PROFILES.COMPLETED_APPOINTMENTS_COUNT.desc(),
                    PROFESSIONAL_PROFILES.ID.asc()
            );
        };
    }
}
