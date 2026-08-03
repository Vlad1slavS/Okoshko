package io.github.vlad1slavs.okoshko.professional.data;

import io.github.vlad1slavs.okoshko.professional.api.ProfessionalPreviewResponse;
import io.github.vlad1slavs.okoshko.professional.api.ProfessionalSort;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.sql.Array;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

@Repository
public class ProfessionalCatalogRepository {

    private static final String FROM_AND_FILTERS = """
            from professional_profiles p
            join business_accounts b
              on b.solo_professional_id = p.id
             and b.status = 'ACTIVE'
            join business_locations l
              on l.business_account_id = b.id
             and l.is_active = true
            join services s
              on s.business_account_id = b.id
             and s.is_active = true
            join service_categories c
              on c.id = s.category_id
             and c.is_active = true
            where p.status = 'ACTIVE'
              and lower(l.city) = lower(:city)
              and (
                    :query = ''
                    or lower(p.display_name) like lower('%' || :query || '%')
                    or lower(b.name) like lower('%' || :query || '%')
                    or exists (
                        select 1 from services sq
                        where sq.business_account_id = b.id
                          and sq.is_active = true
                          and lower(sq.name) like lower('%' || :query || '%')
                    )
              )
              and p.rating >= :minimumRating
              and (
                    :category = ''
                    or exists (
                        select 1
                        from services sf
                        join service_categories cf on cf.id = sf.category_id
                        where sf.business_account_id = b.id
                          and sf.is_active = true
                          and cf.is_active = true
                          and lower(cf.slug) = lower(:category)
                    )
              )
            """;

    private final JdbcClient jdbcClient;

    public ProfessionalCatalogRepository(JdbcClient jdbcClient) {
        this.jdbcClient = jdbcClient;
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
        var orderBy = switch (sort) {
            case PRICE -> "price_from_minor asc, p.rating desc, p.id";
            case RATING -> "p.rating desc, p.reviews_count desc, p.id";
            case RECOMMENDED -> "p.rating desc, p.reviews_count desc, p.completed_appointments_count desc, p.id";
        };
        var sql = """
                select p.slug,
                       p.display_name,
                       p.description,
                       p.avatar_url,
                       p.rating,
                       p.reviews_count,
                       min(s.price_minor) as price_from_minor,
                       min(s.duration_minutes) as duration_from_minutes,
                       max(s.duration_minutes) as duration_to_minutes,
                       array_agg(distinct c.slug order by c.slug) as category_slugs
                """ + FROM_AND_FILTERS + """
                group by p.id
                order by """ + " " + orderBy + " limit :limit offset :offset";

        return parameters(jdbcClient.sql(sql), city, category, query, minimumRating)
                .param("limit", limit)
                .param("offset", offset)
                .query((resultSet, rowNumber) -> new ProfessionalPreviewResponse(
                        resultSet.getString("slug"),
                        resultSet.getString("display_name"),
                        resultSet.getString("description"),
                        resultSet.getString("avatar_url"),
                        resultSet.getBigDecimal("rating"),
                        resultSet.getInt("reviews_count"),
                        resultSet.getLong("price_from_minor"),
                        resultSet.getInt("duration_from_minutes"),
                        resultSet.getInt("duration_to_minutes"),
                        toStringList(resultSet.getArray("category_slugs")),
                        null
                ))
                .list();
    }

    public long count(String city, String category, String query, BigDecimal minimumRating) {
        var sql = "select count(distinct p.id) " + FROM_AND_FILTERS;
        return parameters(jdbcClient.sql(sql), city, category, query, minimumRating)
                .query(Long.class)
                .single();
    }

    private JdbcClient.StatementSpec parameters(
            JdbcClient.StatementSpec statement,
            String city,
            String category,
            String query,
            BigDecimal minimumRating
    ) {
        return statement
                .param("city", city)
                .param("category", category)
                .param("query", query)
                .param("minimumRating", minimumRating);
    }

    private List<String> toStringList(Array sqlArray) throws SQLException {
        return Arrays.stream((Object[]) sqlArray.getArray())
                .map(Object::toString)
                .toList();
    }
}
