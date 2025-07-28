package com.ouertatani.gestionproduit.service;

import com.ouertatani.gestionproduit.model.Livraison;
import com.ouertatani.gestionproduit.model.LivraisonDTO;
import com.ouertatani.gestionproduit.repository.LivraisonRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LivraisonService {

    private final LivraisonRepository livraisonRepository;

    public List<Livraison> getAll() {
        return livraisonRepository.findAll();
    }

    public List<LivraisonDTO> getAll_DTO() {
        return livraisonRepository.findAll().stream()
                .map(LivraisonDTO::new)
                .collect(Collectors.toList());
    }
    public Livraison getById(Long id) {
        return livraisonRepository.findById(id).orElse(null);
    }

    public Livraison updateStatut(Long id, Livraison.StatutLivraison statut) {
        Livraison livraison = livraisonRepository.findById(id).orElse(null);
        if (livraison != null) {
            livraison.setStatut(statut);
            return livraisonRepository.save(livraison);
        }
        return null;
    }
}
