package io.github.vlad1slavs.okoshko.favorite.application;

import io.github.vlad1slavs.okoshko.favorite.api.FavoriteIdsResponse;
import io.github.vlad1slavs.okoshko.favorite.api.FavoriteProfessionalsPageResponse;
import io.github.vlad1slavs.okoshko.favorite.api.FavoriteStateResponse;
import io.github.vlad1slavs.okoshko.favorite.data.FavoriteProfessionalRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class FavoriteProfessionalService {
    private final FavoriteProfessionalRepository repository;

    public FavoriteProfessionalService(FavoriteProfessionalRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    public FavoriteIdsResponse ids(UUID userId) {
        return new FavoriteIdsResponse(repository.findIds(userId));
    }

    @Transactional(readOnly = true)
    public FavoriteProfessionalsPageResponse page(UUID userId, int page, int size) {
        var total = repository.count(userId);
        return new FavoriteProfessionalsPageResponse(
                repository.findPage(userId, size, page * size), page, size, total,
                (long) (page + 1) * size < total
        );
    }

    @Transactional
    public FavoriteStateResponse add(UUID userId, String slug) {
        repository.add(userId, slug);
        return new FavoriteStateResponse(slug, true);
    }

    @Transactional
    public FavoriteStateResponse remove(UUID userId, String slug) {
        repository.remove(userId, slug);
        return new FavoriteStateResponse(slug, false);
    }
}
